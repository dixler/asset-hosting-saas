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

def retrieveAsset(assetId, identity, params):
    "we are going to use tagging to track metadata such as the number of entries"
    # perform validation
    assets = DDBCache(os.environ['ASSETS_TABLE_NAME'])
    if assetId not in assets:
       # let's log failures too
       timeseries = DDBCache(os.environ['TIMESERIES_TABLE_NAME'], RangeKey='failures')
       timeseries[timestamp] = identity
       return {'message': 'asset not found', 'success': False}

    timeseries = DDBCache(os.environ['TIMESERIES_TABLE_NAME'], RangeKey=assetId)

    timestamp = utils.getTimestamp()

    timeseries[timestamp] = {**identity, **params}
    asset = assets[assetId]
    return {'Location': asset['s3Path'], 'success': True}

def function(params):
    "is a dynamodb stream event"
    '''
        "identity": {
            "cognitoIdentityPoolId": null,
            "accountId": null,
            "cognitoIdentityId": null,
            "caller": null,
            "sourceIp": "127.0.0.1",
            "accessKey": null,
            "cognitoAuthenticationType": null,
            "cognitoAuthenticationProvider": null,
            "userArn": null,
            "userAgent": "PostmanRuntime/7.6.0",
            "user": null
        },
    '''
    getParams = params['queryStringParameters']
    assetId = getParams['assetId']
    identity = params['requestContext']['identity']
    identity = {
          'userAgent': identity['userAgent'],
          'sourceIp': identity['sourceIp'],
    }

    return retrieveAsset(assetId, identity, getParams)

def lambda_handler(event, context):
    '''
    submitAssignment(token, assignmentId, asset)
    {
    }
    '''
    # params are in body
    print(json.dumps(event))
    params = event
    data = function(utils.replace_decimals(params))
    if not data['success']:
       return {
          'statusCode': '404',
          'headers': {},
          'body': json.dumps(utils.replace_decimals(data))
       }

    response = {
          'statusCode': '302',
          'headers': {
             'Location': data['Location']
          },
    }
    return response



