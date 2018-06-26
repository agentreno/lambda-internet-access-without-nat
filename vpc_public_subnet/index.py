from botocore.vendored import requests


def lambda_handler(event, context):
    resp = requests.get('https://icanhazip.com')
    return resp.text
