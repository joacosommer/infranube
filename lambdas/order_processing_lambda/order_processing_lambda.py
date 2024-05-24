import json
import boto3

def lambda_handler(event, context):
    # Log the received event
    print(f"Received event: {json.dumps(event)}")

    # Process each record (assuming the event is from an S3 trigger)
    for record in event['Records']:
        # Get the bucket name and key from the S3 event
        bucket = record['s3']['bucket']['name']
        key = record['s3']['object']['key']
        print(f"Processing file {key} from bucket {bucket}")
        
        # Load the order data from the S3 object
        order_data = json.loads(get_s3_object(bucket, key))
        
        # Process the order data
        process_order(order_data)
        
    return {
        'statusCode': 200,
        'body': json.dumps('Order processed successfully')
    }

def process_order(order_data):
    # Implement your order processing logic here
    print(f"Processing order for provider ID: {order_data['id_proveedor']} on date {order_data['fecha']}")
    for item in order_data['pedido']:
        print(f"Processing item {item['id_item']} with quantity {item['cantidad']} and note {item['nota']}")
    # Here you would typically insert the order into a database or send a notification
    # For this example, we'll just log the order items

def get_s3_object(bucket, key):
    # Create an S3 client
    s3 = boto3.client('s3')
    
    # Get the object from the S3 bucket
    response = s3.get_object(Bucket=bucket, Key=key)
    
    # Return the object data
    return response['Body'].read().decode('utf-8')
