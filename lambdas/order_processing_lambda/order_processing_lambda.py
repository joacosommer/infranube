import json
import boto3
import os

s3_client = boto3.client('s3')
sns_client = boto3.client('sns')
sns_topic_arn = os.environ['SNS_TOPIC_ARN']

def lambda_handler(event, context):
    print(f"Received event: {json.dumps(event)}")

    for record in event['Records']:
        bucket = record['s3']['bucket']['name']
        key = record['s3']['object']['key']
        print(f"Processing file {key} from bucket {bucket}")
        
        order_data = json.loads(get_s3_object(bucket, key))
        
        process_order(order_data)
        
        sns_client.publish(
            TopicArn=sns_topic_arn,
            Message=f"Processed order for provider ID: {order_data['id_proveedor']} on date {order_data['fecha']}",
            Subject="Order Processed"
        )
        
    return {
        'statusCode': 200,
        'body': json.dumps('Order processed successfully')
    }

def process_order(order_data):
    print(f"Processing order for provider ID: {order_data['id_proveedor']} on date {order_data['fecha']}")
    for item in order_data['pedido']:
        print(f"Processing item {item['id_item']} with quantity {item['cantidad']} and note {item['nota']}")


def get_s3_object(bucket, key):    
    response = s3_client.get_object(Bucket=bucket, Key=key)
    
    return response['Body'].read().decode('utf-8')
