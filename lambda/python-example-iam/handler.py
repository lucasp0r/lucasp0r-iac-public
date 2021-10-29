import boto3

# Note: It's always preferable to define your boto3 outside of your functions
client = boto3.client('lambda')

def hello(event, context):
    response = client.list_functions()
    return response
