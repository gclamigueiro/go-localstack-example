#!/usr/bin/env bash

# This script uploads a sample file to the S3 bucket for processing.
# it should trigger the SQS queue for processing.

AWS_ENDPOINT_URL=http://localhost:4566
AWS_REGION=us-east-1
BUCKET_NAME="awesome-bucket"
S3_PATH="new-files/sample.txt"

FILE_CONTENT="This is a sample file"

# Create a temp file with the content
TMP_FILE=$(mktemp)
echo "$FILE_CONTENT" > "$TMP_FILE"

# Upload the file to S3
aws \
  --region $AWS_REGION \
  --endpoint-url $AWS_ENDPOINT_URL \
  s3api put-object \
  --bucket "$BUCKET_NAME" \
  --key "$S3_PATH" \
  --body "$TMP_FILE"

# Clean up the temp file
rm "$TMP_FILE"