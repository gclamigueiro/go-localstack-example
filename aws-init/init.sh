#!/bin/bash

# Documentation:
# https://docs.localstack.cloud/getting-started/


# KMS Key
# awslocal kms create-key --tags '[{"TagKey":"_custom_id_","TagValue":"00000000-0000-0000-0000-000000000001"}]'

# Create S3 bucket
BUCKET_NAME="awesome-bucket"
awslocal s3 mb s3://$BUCKET_NAME

# SNS Topic to receive the S3 event notification
TOPIC_NAME="awesome-sns-topic"
TOPIC_ARN=$(awslocal sns create-topic --name $TOPIC_NAME --query TopicArn --output text)

# Set SNS policy to allow S3 to send messages
awslocal sns set-topic-attributes \
  --topic-arn "$TOPIC_ARN" \
  --attribute-name Policy \
  --attribute-value '{
    "Version": "2012-10-17",
    "Statement": [
      {
        "Sid": "AllowS3ToPublish",
        "Effect": "Allow",
        "Principal": {
          "Service": "s3.amazonaws.com"
        },
        "Action": "SNS:Publish",
        "Resource": "'"$TOPIC_ARN"'"
      }
    ]
  }'

# Configure the S3 bucket to send events to SNS only for PUT-created '.txt' files in 'new-files/' folder
awslocal s3api put-bucket-notification-configuration \
  --bucket "$BUCKET_NAME" \
  --notification-configuration '{
    "TopicConfigurations": [
      {
        "TopicArn": "'"$TOPIC_ARN"'",
        "Events": ["s3:ObjectCreated:Put"],
        "Filter": {
          "Key": {
            "FilterRules": [
              {
                "Name": "prefix",
                "Value": "new-files/"
              },
              {
                "Name": "suffix",
                "Value": ".txt"
              }
            ]
          }
        }
      }
    ]
  }'

# Create and subscribe SQS queues to the SNS topic
QUEUES=("customer1-sqs" "customer2-sqs" "customer3-sqs")

for QUEUE_NAME in "${QUEUES[@]}"; do
  QUEUE_URL=$(awslocal sqs create-queue --queue-name "$QUEUE_NAME" --query QueueUrl --output text)
  QUEUE_ARN=$(awslocal sqs get-queue-attributes --queue-url "$QUEUE_URL" --attribute-names QueueArn --query "Attributes.QueueArn" --output text)

  # set VisibilityTimeout: 
    # Visibility timeout is the duration (in seconds) that a message will be invisible to other consumers after being received.
    # Values from 0 to 43200 seconds (12 hours). Default is 30 seconds.
  # set ReceiveMessageWaitTimeSeconds: 
    # is to set long polling, when calling ReceiveMessage, it will wait up to the specified time for a message 
    # to arrive before returning an empty response.
    # if set ReceiveMessageWaitTimeSeconds to 0 is short polling, it will return immediately even if no messages are available.
    # Values from 0 to 20 seconds. Default is 0 seconds.
  # **NOTE** You can override these values in the consumer code  
  TIMEOUT_ATTRS='
    "VisibilityTimeout": "30",
    "ReceiveMessageWaitTimeSeconds": "20"
  '
  # Allow SNS to send messages to the queue
  POLICY_ATTR='
  "Policy": "{
    \"Version\": \"2012-10-17\",
    \"Statement\": [
      {
        \"Effect\": \"Allow\",
        \"Principal\": \"*\",
        \"Action\": \"sqs:SendMessage\",
        \"Resource\": \"'"$QUEUE_ARN"'\",
        \"Condition\": {
          \"ArnEquals\": {
            \"aws:SourceArn\": \"'"$TOPIC_ARN"'\"
          }
        }
      }
    ]
  }"
  '

  ATTRIBUTES_JSON="{${TIMEOUT_ATTRS},${POLICY_ATTR}}"

  awslocal sqs set-queue-attributes \
    --queue-url "$QUEUE_URL" \
    --attributes "$ATTRIBUTES_JSON"

  # Subscribe the queue to the SNS topic
  awslocal sns subscribe \
    --topic-arn "$TOPIC_ARN" \
    --protocol sqs \
    --notification-endpoint "$QUEUE_ARN"
done
