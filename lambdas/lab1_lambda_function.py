import boto3
import json


def lambda_handler(event, context):
    s3_resource = boto3.resource('s3')
    batch_client = boto3.client('batch')

    object_key = event['Records'][0]['s3']['object']['key'] 
    if object_key == 'input.json':
        bucket_name = event['Records'][0]['s3']['bucket']['name']
        
        # Read the input.json file from S3
        obj = s3_resource.Object(bucket_name, object_key)
        input_json = obj.get()['Body'].read().decode('utf-8')
        
        # Parse the input.json content
        input_data = json.loads(input_json)
        
        # Submit the Batch job
        try:
            submit_job_response = batch_client.submit_job(
                jobName=input_data['jobName'],
                jobQueue=input_data['jobQueue'],
                jobDefinition=input_data['jobDefinition'],
                containerOverrides=input_data['containerOverrides'],
                retryStrategy=input_data['retryStrategy']
            )
        except Exception as e:
            raise e
        
        return {
            'statusCode': 200,
            'body': json.dumps(f'Batch job submitted: {submit_job_response["jobName"]}')
        }
    else:
        print("Another file with a .json suffix notified this lambda, doing nothing.")
        