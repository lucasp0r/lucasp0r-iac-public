import boto3


def hello(event, context):
    client = boto3.client('s3')
    return client.list_bucket()
