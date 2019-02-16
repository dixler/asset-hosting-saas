import os
from decimal import Decimal
import hashlib
import time
import datetime
import random
import json
import boto3
from boto3.dynamodb.conditions import Key, Attr

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

class DDBCache:
    dynamodb = boto3.resource('dynamodb')

    def __init__(self, TableName, RangeKey=None):
        '''initializes the table using the table's name, 
        if the table has a range key, the range key
        must be provided'''
        self.table = self.dynamodb.Table(TableName)
        key_schema = self.table.key_schema
        self.PrimaryKey = key_schema[0]['AttributeName']
        self.RangeKey = None
        if len(key_schema) > 1:
            self.RangeKey = key_schema[1]['AttributeName']
            if RangeKey == None:
                raise Exception('missing range key')
            self.RangeKeyValue = RangeKey


    def __getitem__(self, key):
        '''allow bracket access on primary key, returns a dictionary'''
        try:
            Key = {self.PrimaryKey: key}

            if self.RangeKey != None:
                Key[self.RangeKey] = self.RangeKeyValue

            return self.table.get_item(Key=Key)['Item']
        except Exception:
            return None

    def __setitem__(self, key, value):
        '''allow bracket modification on primary key, must store as a dictionary'''
        if not isinstance(value, dict):
            value = {key: value}
        item = {**value, **{self.PrimaryKey: key}}
        return self.table.put_item(Item=item)

    def __delitem__(self, key):
        return self.table.delete_item(Key={self.PrimaryKey: key})

    def __contains__(self, key):
        return self[key] != None


def replace_decimals(obj):
    if isinstance(obj, list):
        for i in range(len(obj)):
            obj[i] = replace_decimals(obj[i])
        return obj
    elif isinstance(obj, dict):
        for k in obj:
            obj[k] = replace_decimals(obj[k])
        return obj
    elif isinstance(obj, Decimal):
        if obj % 1 == 0:
            return int(obj)
        else:
            return float(obj)
    else:
        return obj

def retrieveDynamoDB(tableName, key):
    try:
        dynamodb = boto3.resource('dynamodb')
        table = dynamodb.Table(tableName)
        response = table.get_item(Key=key)
        result = response['Item']
        return result
    except Exception:
        print('['+tableName+']'+'failed to retrieve', json.dumps(key))
    return None

def insertDynamoDB(tableName, item):
    try:
        dynamodb = boto3.resource('dynamodb')
        table = dynamodb.Table(tableName)
        response = table.put_item(Item=item)
    except Exception:
        print('['+tableName+']'+'failed to insert', json.dumps(item))
    return

def getNetId(token):
    "convert session token to netid"
    try:
        entry = retrieveDynamoDB(os.environ['TOKENS_TABLE_NAME'], {'token': token})
        return entry['netid']
    except Exception:
        print('failed to getNetId', token)
    return None

def getTokenId(netid):
    "convert netid to a tokenized id. Very Secret"
    try:
        entry = retrieveDynamoDB(os.environ['USERS_TABLE_NAME'], {'netid': netid})
        return entry['tokenid']
    except Exception:
        print('failed to getTokenId', netid)
    return None

def isOwner(token, assetId, assignmentId):
    "we're only determining if we're the owner of an asset."
    try:
        entry = retrieveDynamoDB(os.environ['SUBMISSIONS_TABLE_NAME'], {'assetId': assetId, 'assignmentId': assignmentId})
        netid = getNetId(token)
        return entry['netid'] == netid
    except Exception:
        print('failed to determine owner for', token, assetId, assignmentId)
    return None

def isAdmin(token):
    token_entry = retrieveDynamoDB(os.environ['TOKENS_TABLE_NAME'], {'token': token})
    netid = token_entry['netid']
    user_entry = retrieveDynamoDB(os.environ['USERS_TABLE_NAME'], {'netid': netid})
    return user_entry['admin']

def genHash(salt):
    'improperly named, generates a random token'
    data = str(salt) + str(time.time()) + str(random.randint(0, 2**256))
    return hashlib.sha256(bytes(data, 'utf-8')).hexdigest()
def getTimestamp():
    now = datetime.datetime.utcnow()
    return now.isoformat()
