#!/usr/bin/env python
import os
import json
import boto3
import requests
import urllib.parse
from boto3.dynamodb.conditions import Attr, Key
import utils
from utils import DDBCache
import datetime

"""
      SUBMISSIONS_TABLE_NAME
      SCOREBOARD_TABLE_NAME
      ASSETS_TABLE_NAME
      TOKENS_TABLE_NAME
      USERS_TABLE_NAME
      CONFIGURATION_TABLE_NAME
      DOCUMENTS_BUCKET_NAME
      GRADING_QUEUE_NAME
"""

def get_confirm_token(response):
    for key, value in response.cookies.items():
        if key.startswith('download_warning'):
            return value

    return None

def save_response_content(response, s3URI):
    s3 = boto3.client('s3')
    s3.put_object(Body=response.content, 
          Bucket=os.environ['ASSETS_BUCKET_NAME'], 
          Key=s3URI,
          ACL='public-read',
          ContentType='application/pdf',
          ContentDisposition='inline',
    )

def download_file_from_google_drive(link, s3URI):
    id = link.split('/')[5]
    URL = "https://docs.google.com/document/u/1/export"

    session = requests.Session()

    response = session.get(URL, params = { 'id' : id, 'format' : 'pdf' }, stream = True)
    token = get_confirm_token(response)
    if token:
        params = { 'id' : id, 'confirm' : token }
        response = session.get(URL, params = params, stream = True)

    save_response_content(response, s3URI)

def createAsset(token, assetId, googleDocsURL, label, extension):
    import base64
    "we are going to use tagging to track metadata such as the number of entries"
    # perform validation
    tokens = DDBCache(os.environ['TOKENS_TABLE_NAME'])
    assets = DDBCache(os.environ['ASSETS_TABLE_NAME'])
    users = DDBCache(os.environ['USERS_TABLE_NAME'])

    
    if token not in tokens:
        return {'message': 'invalid token'}

    userId = tokens[token]['userId']
    user = users[userId]


    if assetId == None:
       # TODO transact
       if user['file_count'] >= user['file_limit']:
           return {'message': 'reached file limit'}
       user['file_count'] += 1

       assetId = utils.genHash(token) + '.' + extension

       while assetId in assets:
          # we have a conflict reroll
          assetId = utils.genHash(token)

       format_tuple = (
             urllib.parse.quote_plus(os.environ['ASSETS_BUCKET_NAME']),
             urllib.parse.quote_plus(userId),
             urllib.parse.quote_plus(assetId))

       s3Path = 'https://s3.amazonaws.com/%s/%s/%s' % format_tuple

       asset = {
             "assetId": assetId,
             "userId": user['userId'],
             "dateModified": utils.getTimestamp(),
             "googleDocsURL": googleDocsURL,
             "label": label,
             "version": 1,
             "s3Path": s3Path
       }
    else:
       asset = assets[assetId]
       asset['dateModified'] = utils.getTimestamp()
       asset['version'] += 1
    s3Key = '%s/%s' % (asset['userId'], asset['assetId'])


    # could also have conflict later on, but we can play it by ear
    # TODO transactional


    # begin to upload the file to s3
    download_file_from_google_drive(googleDocsURL, s3Key)
    users[userId] = user
    assets[assetId] = asset
    return {'message': 'success'}

def function(params):
    "is a dynamodb stream event"
    assetId = params['assetId'] if 'assetId' in params else None
    label = params['label'] if 'label' in params else 'untitled'
    extension = params['extension'] if 'extension' in params else 'pdf'

    return createAsset(params['token'], assetId, params['googleDocsURL'], label, extension)

def lambda_handler(event, context):
    '''
    submitAssignment(token, assignmentId, asset)
    {
    }
    '''
    # params are in body
    print(json.dumps(event))
    params = json.loads(event['body'])
    data = function(utils.replace_decimals(params))

    print(json.dumps(data))

    response = {
          'statusCode': "200",
          'headers': {
             'Content-Type': 'application/json',
             'Access-Control-Allow-Origin': '*'
             },

          'body': json.dumps(utils.replace_decimals(data))
          }
    return response



