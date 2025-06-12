#!/usr/bin/env bash

AWS_ENDPOINT_URL=http://localhost:4566
AWS_REGION=us-east-1

BUCKET_NAME="awesome-bucket"
aws s3 --region $AWS_REGION --endpoint-url $AWS_ENDPOINT_URL rm s3://$BUCKET_NAME --recursive

QUEUES=("customer1-sqs" "customer2-sqs" "customer3-sqs")
for QUEUE_NAME in "${QUEUES[@]}"; do
  QUEUE_URL=$(aws --region $AWS_REGION --endpoint-url $AWS_ENDPOINT_URL sqs get-queue-url --queue-name "$QUEUE_NAME" --query QueueUrl --output text)
  aws sqs --region $AWS_REGION --endpoint-url $AWS_ENDPOINT_URL purge-queue --queue-url $QUEUE_URL
done

echo "S3 bucket and SQS queues purged successfully."
