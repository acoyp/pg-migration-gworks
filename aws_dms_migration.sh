#!/bin/bash

# Set variables
INSTANCE_IDENTIFIER="Replication_Instance_gWorks"
INSTANCE_CLASS="dms.t3.micro"
STORAGE_SIZE=50

TF_OUTPUT=$(terraform output -json)
SUBNET_ID_1=$(echo "$TF_OUTPUT" | jq -r '.subnet_a.value')
SUBNET_ID_2=$(echo "$TF_OUTPUT" | jq -r '.subnet_b.value')

SUBNET_GROUP_IDENTIFIER="my-subnet-group"

SOURCE_ENDPOINT_IDENTIFIER="${PROJECT_NAME}SourceEndpoint"
SOURCE_ENGINE_NAME="postgresql"


TARGET_ENDPOINT_IDENTIFIER="${PROJECT_NAME}TargetEndpoint"
TARGET_ENGINE_NAME="postgresql"


# Create source endpoint
if [[ `aws dms describe-endpoints --query "Endpoints[?EndpointIdentifier=='$SOURCE_ENDPOINT_IDENTIFIER'].EndpointArn" --output text` == $SOURCE_ENDPOINT_IDENTIFIER ]]; then
    echo "AWS DMS Endpoint already exists..."
else
    aws dms create-endpoint \
    --endpoint-identifier "$SOURCE_ENDPOINT_IDENTIFIER" \
    --endpoint-type "source" \
    --engine-name "$SOURCE_ENGINE_NAME" \
    --server-name "$SOURCE_SERVER_NAME" \
    --port "5432" \
    --database-name "$SOURCE_DATABASE_NAME" \
    --username "$SOURCE_USERNAME" \
    --password "$SOURCE_PASSWORD"

fi

# Create target endpoint
if [[ `aws dms describe-endpoints --query "Endpoints[?EndpointIdentifier=='$TARGET_ENDPOINT_IDENTIFIER'].EndpointArn" --output text` == $TARGET_ENDPOINT_IDENTIFIER ]]; then
    echo "AWS DMS Endpoint already exists..."

else
  aws dms create-endpoint \
    --endpoint-identifier "$TARGET_ENDPOINT_IDENTIFIER" \
    --endpoint-type "target" \
    --engine-name "$TARGET_ENGINE_NAME" \
    --server-name "$TARGET_SERVER_NAME" \
    --database-name "$TARGET_DATABASE_NAME" \
    --username "$TARGET_USERNAME" \
    --password "$TARGET_PASSWORD"

TASK_IDENTIFIER="my-replication-task"
SOURCE_ENDPOINT_ARN=`aws dms describe-endpoints --query "Endpoints[?EndpointIdentifier=='$SOURCE_ENDPOINT_IDENTIFIER'].EndpointArn" --output text`
TARGET_ENDPOINT_ARN=`aws dms describe-endpoints --query "Endpoints[?EndpointIdentifier=='$TARGET_ENDPOINT_IDENTIFIER'].EndpointArn" --output text`
MIGRATION_TYPE="full-load"
TABLE_MAPPINGS_FILE="table-mappings.json"


# Create replication instance
aws dms create-replication-instance \
  --replication-instance-identifier "$INSTANCE_IDENTIFIER" \
  --replication-instance-class "$INSTANCE_CLASS" \
  --allocated-storage "$STORAGE_SIZE" \
  --replication-instance-engine-version "3.4.7"

# Create replication subnet group
aws dms create-replication-subnet-group \
  --replication-subnet-group-identifier "$SUBNET_GROUP_IDENTIFIER" \
  --subnet-ids "$SUBNET_ID_1" "$SUBNET_ID_2"

# Create replication task
aws dms create-replication-task \
  --replication-task-identifier "$TASK_IDENTIFIER" \
  --source-endpoint-arn "$SOURCE_ENDPOINT_ARN" \
  --target-endpoint-arn "$TARGET_ENDPOINT_ARN" \
  --migration-type "$MIGRATION_TYPE" \
  --table-mappings "file://./$TABLE_MAPPINGS_FILE" \
  --recovery-type "SCHEMA_CONVERSION"

# Start replication task
aws dms start-replication-task \
  --replication-task-arn "$(aws dms describe-replication-tasks --filters "Name=replication-task-identifier,Values=$TASK_IDENTIFIER" --query "ReplicationTasks[0].ReplicationTaskArn" --output text)"

# Monitor migration progress
while true; do
  STATUS="$(aws dms describe-replication-tasks --filters "Name=replication-task-identifier,Values=$TASK_IDENTIFIER" --query "ReplicationTasks[0].Status" --output text)"
  echo "Migration status: $STATUS"
  if [[ "$STATUS" == "stopped" || "$STATUS" == "failed" || "$STATUS" == "ready" ]]; then
    break
  fi
  sleep 30
done
