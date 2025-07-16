#!/bin/bash

echo "Creating DynamoDB table..."

DYNAMODB_ENDPOINT="http://dynamodb-local:8000"

# Create Quiz table with GSI
aws dynamodb create-table --endpoint-url $DYNAMODB_ENDPOINT --region ap-northeast-1 --table-name Quiz --attribute-definitions AttributeName=PK,AttributeType=S AttributeName=SK,AttributeType=S AttributeName=category,AttributeType=S AttributeName=id,AttributeType=S --key-schema AttributeName=PK,KeyType=HASH AttributeName=SK,KeyType=RANGE --global-secondary-indexes 'IndexName=category-id-index,KeySchema=[{AttributeName=category,KeyType=HASH},{AttributeName=id,KeyType=RANGE}],Projection={ProjectionType=ALL},ProvisionedThroughput={ReadCapacityUnits=5,WriteCapacityUnits=5}' --provisioned-throughput ReadCapacityUnits=5,WriteCapacityUnits=5

if [ $? -eq 0 ]; then
    echo "Quiz table created successfully!"
else
    echo "Failed to create Quiz table"
    exit 1
fi