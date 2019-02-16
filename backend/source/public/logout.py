#!/usr/bin/env python
import os
import json
import boto3
from boto3.dynamodb.conditions import Attr, Key
import utils
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

def logout(token):
    tokensTable = utils.DDBCache(os.environ['TOKENS_TABLE_NAME'])
    if tokensTable[token] == None:
        # guard against fake session
        return {'message': 'invalid token'}
    try:
        del tokensTable[token]
    except Exception:
        return {'message': 'failed logout'}
    return {'message': 'success'}

def function(params):
    return logout(params['token'])


def lambda_handler(event, context):
    '''
    logout(token)->
        {
            "token": "251"
        }
    '''
    # params are in body
    params = json.loads(event['body'])
    print(json.dumps(params, sort_keys=True, indent=4, separators=(',', ': ')))

    data = function(utils.replace_decimals(params))
    print(data)
    response = {
          'statusCode': "200",
          'headers': {
             'Content-Type': 'application/json',
             'Access-Control-Allow-Origin': '*'
             },

          'body': json.dumps(utils.replace_decimals(data))
          }
    return response

