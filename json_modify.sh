#!/bin/bash

cat compareDBs.json
DB_DATA=`cat compareDBs.json`
DB_DATA=`jq ".connection1.host = \"$SOURCE_SERVER_NAME\"" <<< "$DB_DATA"`
DB_DATA=`jq ".connection1.database = \"$SOURCE_DATABASE_NAME\"" <<< "$DB_DATA"`
DB_DATA=`jq ".connection1.user = \"$SOURCE_USERNAME\"" <<< "$DB_DATA"` 
DB_DATA=`jq ".connection1.password = \"$SOURCE_PASSWORD\"" <<< "$DB_DATA"` 
DB_DATA=`jq ".connection2.host = \"$TARGET_SERVER_NAME\"" <<< "$DB_DATA"` 
DB_DATA=`jq ".connection2.database = \"$TARGET_DATABASE_NAME\"" <<< "$DB_DATA"` 
DB_DATA=`jq ".connection2.user = \"$TARGET_USERNAME\"" <<< "$DB_DATA"` 
DB_DATA=`jq ".connection2.password = \"$TARGET_PASSWORD\"" <<< "$DB_DATA" > compareDBs.json` 

cat compareDBs.json