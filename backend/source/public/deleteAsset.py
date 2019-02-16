#!/usr/bin/env python
import os
import json
import boto3
import requests
from boto3.dynamodb.conditions import Attr, Key
import utils
from utils import DDBCache
import datetime
"""
      ASSETS_TABLE_NAME
      TOKENS_TABLE_NAME
      USERS_TABLE_NAME
      CONFIGURATION_TABLE_NAME
      DOCUMENTS_BUCKET_NAME
      GRADING_QUEUE_NAME
"""

def deleteAsset(token, assetId):
    import base64
    "we are going to use tagging to track metadata such as the number of entries"
    # perform validation
    tokens = DDBCache(os.environ['TOKENS_TABLE_NAME'])
    assets = DDBCache(os.environ['ASSETS_TABLE_NAME'])
    users = DDBCache(os.environ['USERS_TABLE_NAME'])
    bucket = boto3.client('s3')

    if token not in tokens:
        return {'message': 'invalid token'}


    # get asset information and verify that it is owned properly

    if assetId not in assets:
        return {'message': 'invalid asset'}
    token = tokens[token]
    asset = assets[assetId]
    userId = token['userId']

    if asset['userId'] != userId:
       # handle wrong owner
       return {'message': 'invalid token'}

    
    user = users[userId]

    if user['file_count'] > user['file_limit']:
        return {'message': 'reached file limit'}

    # TODO transactional
    try:
       del assets[assetId]
       user['file_count'] += -1
       users[userId] = user
       bucket.delete_object(
           Bucket=os.environ['ASSETS_BUCKET_NAME'],
           Key=asset['s3Path'],
       )
    except Exception:
       return {'message': 'failed'}

    return {'message': 'success'}


def function(params):
    "is a dynamodb stream event"
    return deleteAsset(params['token'], params['assetId'])

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



