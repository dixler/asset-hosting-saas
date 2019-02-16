#!/usr/bin/env python
import os
import json
import boto3
from boto3.dynamodb.conditions import Attr, Key
import utils
import datetime
"""
      SUBMISSIONS_TABLE_NAME
      SCOREBOARD_TABLE_NAME
      ASSIGNMENTS_TABLE_NAME
      TOKENS_TABLE_NAME
      USERS_TABLE_NAME
      CONFIGURATION_TABLE_NAME
      DOCUMENTS_BUCKET_NAME
      S3_HOSTING_BUCKET
      GRADING_QUEUE_NAME
      API_GATEWAY_URL
"""

def login(code, this_url):
   try:
      import requests
      url = 'https://www.googleapis.com/oauth2/v4/token'
      headers = {
            'content-type': 'application/x-www-form-urlencoded'
      }

      redirect_uri = 'https://' + this_url + '/dev/login'
      client_id = os.environ['OAUTH_ID']
      client_secret = os.environ['OAUTH_SECRET']

      data='code=%s&redirect_uri=%s&client_id=%s&client_secret=%s&scope=&grant_type=authorization_code' % (code, redirect_uri, client_id, client_secret)
      resp = requests.post(url, headers=headers, data=data).json()

      print('google\'s response')
      print(resp)
      access_token = resp['access_token']
      # determine success or failure
      url = 'https://www.googleapis.com/oauth2/v2/userinfo'
      headers = {
            'Authorization': 'Bearer %s' % (access_token)
      }

      resp = requests.get(url, headers=headers).json()
      email = resp['email']
      # login section

      users = utils.DDBCache(os.environ['USERS_TABLE_NAME'])
      tokens = utils.DDBCache(os.environ['TOKENS_TABLE_NAME'])

      newToken = utils.genHash(access_token)

      if email not in users:
         if os.environ['PREFIX'] == 'dev':
            return {'message': 'restricted user list', 'success': False}
         # new user
         user = {
            'file_count': 0,
            'file_limit': 2
         }
         users[email] = user

      tokens[newToken] = {'userId': email}
      return {'message': 'new user', 'token': newToken, 'success': True}

   except Exception:
      return {'message': 'failure', 'success': False}

def function(params, url):
    "is a dynamodb stream event"
    print(json.dumps(params))
    return login(params['code'], url)

def lambda_handler(event, context):
    '''
    submitAssignment(token, assignmentId, asset)
    {
    }
    '''
    # params are in body
    print(json.dumps(event))
    url = event['headers']['Host']
    params = event['queryStringParameters']

    data = function(params, url)

    print(json.dumps(data))
    if data['success']:
       token = data['token']
       redirect_url = '%s?token=%s' % (os.environ['S3_HOSTING_BUCKET'], token)

       response = {
             'statusCode': "302",
             'headers': {
                'Content-Type': 'text/html',
                'Access-Control-Allow-Origin': '*'
             },
             'body': '''
<!DOCTYPE html>
<html>
   <body>
      <script>window.location.replace('%s')</script>
   </body>
</html>
''' % (redirect_url)
       }
    else:
       response = {
             'statusCode': "200",
             'headers': {
                'Content-Type': 'application/json',
                'Access-Control-Allow-Origin': '*'
             },

             'body': json.dumps(data)
       }

    return response

