#!/usr/bin/env python
import os
import json
import boto3
import utils
from utils import DDBCache
"""
      SUBMISSIONS_TABLE_NAME
      SCOREBOARD_TABLE_NAME
      ASSIGNMENTS_TABLE_NAME
      TOKENS_TABLE_NAME
      USERS_TABLE_NAME
      CONFIGURATION_TABLE_NAME
      DOCUMENTS_BUCKET_NAME
      GRADING_QUEUE_NAME
"""

def getUser(token):
    tokens = DDBCache(os.environ['TOKENS_TABLE_NAME'])
    users = DDBCache(os.environ['USERS_TABLE_NAME'])
    if token not in tokens:
        return {'message': 'invalid token'}

    userId = tokens[token]['userId']

    user = users[userId]
    return user

def function(params):
    return getUser(params['token'])

def lambda_handler(event, context):
    '''
    getUser(token)->
        {
           "userId": "something",
           "file_count": "666666666",
           "tokenid": "c1f8b18730737be44ea82b2a9ffd887729bd9ded1960e4b38bf49492fb0d1fa3",
        }
        {
    '''
    # params are in body
    params = json.loads(event['body'])
    print(json.dumps(params, sort_keys=True, indent=4, separators=(',', ': ')))

    data = function(utils.replace_decimals(params))

    response = {
          'statusCode': "200",
          'headers': {
             'Content-Type': 'application/json',
             'Access-Control-Allow-Origin': '*'
             },

          'body': json.dumps(utils.replace_decimals(data))
          }
    return response

