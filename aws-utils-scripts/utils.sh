#!/usr/bin/env bash

# List Queues
aws sqs list-queues \
  --endpoint-url http://localhost:4566 \
  --region us-east-1

# Receive messages from the SQS queue
aws sqs receive-message \
  --queue-url http://localhost:4566/000000000000/customer1-sqs \
  --endpoint-url http://localhost:4566 \
  --region us-east-1

# List kms keys
aws kms list-keys \
 --endpoint-url http://localhost:4566 \
 --region us-east-1

# List all files in the S3 bucket
aws s3 ls s3://awesome-bucket \
  --recursive \
  --endpoint-url http://localhost:4566 \
  --region us-east-1


# list sns topics
aws sns list-topics \
  --endpoint-url http://localhost:4566 \
  --region us-east-1

# send an sns notification
aws sns publish \
  --topic-arn "arn:aws:sns:us-east-1:000000000000:awesome-sns-topic" \
  --message "Hello subscribers" \
  --endpoint-url http://localhost:4566 \
  --region us-east-1