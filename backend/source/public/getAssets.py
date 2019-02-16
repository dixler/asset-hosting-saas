#!/usr/bin/env python
#!/usr/bin/env python
import os
import json
import boto3
from boto3.dynamodb.conditions import Attr, Key
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

def getAssets(token):
    tokens = DDBCache(os.environ['TOKENS_TABLE_NAME'])
    if token not in tokens:
        return {"message": "permission denied"}

    userId = tokens[token]['userId']

    dynamodb = boto3.resource('dynamodb')
    table = dynamodb.Table(os.environ['ASSETS_TABLE_NAME'])
    response = table.scan(
        FilterExpression=Key('userId').eq(userId)
    )

    return response['Items']

def function(params):
    return getAssets(params['token'])


def lambda_handler(event, context):
    '''
    getAssets(token)->
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


