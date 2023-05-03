import json
import boto3

def lambda_handler(event, context):
    s3_resource = boto3.resource('s3')
    batch_client = boto3.client('batch')

    object_key = event['Records'][0]['s3']['object']['key'] 
    if object_key == 'input.json':
        # Get the bucket and key from the S3 event
        bucket_name = event['Records'][0]['s3']['bucket']['name']
        
        # Read the input.json file from S3
        obj = s3_resource.Object(bucket_name, object_key)
        input_json = obj.get()['Body'].read().decode('utf-8')
        
        # Parse the input.json content
        input_data = json.loads(input_json)
        
        # Submit the Batch job
        try:
            submit_job_response = batch_client.submit_job(
                jobName='my-batch-job',
                jobQueue='lab1-queue',
                jobDefinition='lab1-def:8',
                parameters={
                    'input': input_data
                }
            )
        except Exception as e:
            raise e
        
        return {
            'statusCode': 200,
            'body': json.dumps(f'Batch job submitted: {submit_job_response["jobName"]}')
        }
    else:
        print("Another file with a .json suffix notified this lambda, doing nothing.")