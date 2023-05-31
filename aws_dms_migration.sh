#!/bin/bash

# Set variables
INSTANCE_IDENTIFIER="replication-instance-gworks"
INSTANCE_CLASS="dms.t3.micro"
STORAGE_SIZE=50

# TF_OUTPUT=$(terraform -chdir=terraform output -json)
# SUBNET_ID_1=$(echo "$TF_OUTPUT" | jq -r '.subnet_a.value')
# SUBNET_ID_2=$(echo "$TF_OUTPUT" | jq -r '.subnet_b.value')

SUBNET_GROUP_IDENTIFIER="my-subnet-group"

SOURCE_ENDPOINT_IDENTIFIER="${PROJECT_NAME}source01endpoint"
SOURCE_ENGINE_NAME="postgres"


TARGET_ENDPOINT_IDENTIFIER="${PROJECT_NAME}target01endpoint"
TARGET_ENGINE_NAME="postgres"


# Create source endpoint
if [ `aws dms describe-endpoints --query "Endpoints[?EndpointIdentifier=='$SOURCE_ENDPOINT_IDENTIFIER'].EndpointIdentifier" --output text` ]; then
  echo "AWS DMS Endpoint already exists..."
else
  echo "AWS DMS doesn't exists..."
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
if [ `aws dms describe-endpoints --query "Endpoints[?EndpointIdentifier=='$TARGET_ENDPOINT_IDENTIFIER'].EndpointIdentifier" --output text` ]; then
  echo "AWS DMS Endpoint already exists..."
else
  echo "AWS DMS doesn't exists..."
  aws dms create-endpoint \
    --endpoint-identifier "$TARGET_ENDPOINT_IDENTIFIER" \
    --endpoint-type "target" \
    --engine-name "$TARGET_ENGINE_NAME" \
    --server-name "$TARGET_SERVER_NAME" \
    --database-name "$TARGET_DATABASE_NAME" \
    --port "5432" \
    --username "$TARGET_USERNAME" \
    --password "$TARGET_PASSWORD"
fi

TASK_IDENTIFIER="my-replication-task-gworks"
SOURCE_ENDPOINT_ARN="`aws dms describe-endpoints --query "Endpoints[?EndpointIdentifier=='$SOURCE_ENDPOINT_IDENTIFIER'].EndpointArn" --output text`"
TARGET_ENDPOINT_ARN="`aws dms describe-endpoints --query "Endpoints[?EndpointIdentifier=='$TARGET_ENDPOINT_IDENTIFIER'].EndpointArn" --output text`"
MIGRATION_TYPE="full-load"
TABLE_MAPPINGS_FILE="table_mapping.json"
echo ${SOURCE_ENDPOINT_ARN}
echo $TARGET_ENDPOINT_ARN

if [ `aws dms describe-replication-instances --query "ReplicationInstances[?ReplicationInstanceIdentifier=='$INSTANCE_IDENTIFIER'].ReplicationInstanceIdentifier" --output text` ]; then
  echo "Instance Already Exists..."
else
# Create replication instance
  aws dms create-replication-instance \
    --replication-instance-identifier "$INSTANCE_IDENTIFIER" \
    --replication-instance-class "$INSTANCE_CLASS" \
    --allocated-storage "$STORAGE_SIZE" \
    --engine-version "3.4.7"
fi

if [ `aws dms describe-replication-tasks --query "ReplicationTasks[?ReplicationTaskIdentifier=='$TASK_IDENTIFIER'].ReplicationTaskIdentifier" --output text` ]; then
  echo "Replication Task already exists..."
else
# Create replication task
  aws dms create-replication-task \
    --replication-task-identifier "$TASK_IDENTIFIER" \
    --source-endpoint-arn "$SOURCE_ENDPOINT_ARN" \
    --target-endpoint-arn "$TARGET_ENDPOINT_ARN" \
    --replication-instance-arn "`aws dms describe-replication-instances --query "ReplicationInstances[?ReplicationInstanceIdentifier=='$INSTANCE_IDENTIFIER'].ReplicationInstanceArn" --output text`" \
    --migration-type "$MIGRATION_TYPE" \
    --table-mappings "file://./$TABLE_MAPPINGS_FILE" 
fi

REPLICATION_TASK_ARN="`aws dms describe-replication-tasks --query "ReplicationTasks[?ReplicationTaskIdentifier=='$TASK_IDENTIFIER'].ReplicationTaskArn" --output text`"
echo $REPLICATION_TASK_ARN
# Start replication task
aws dms start-replication-task \
  --start-replication-task-type "start-replication" \
  --replication-task-arn "$REPLICATION_TASK_ARN"

# Monitor migration progress
while true; do
  STATUS="$(aws dms describe-replication-tasks --query "ReplicationTasks[?ReplicationTaskIdentifier=='$TASK_IDENTIFIER'].Status" --output text)"
  echo "Migration status: $STATUS"
  if [ "$STATUS" = "stopped" ] || [ "$STATUS" = "failed" ] || [ "$STATUS" = "ready" ]; then
    break
  fi
  sleep 30
done
