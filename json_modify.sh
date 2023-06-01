#!bin/bash

compareDB_data=$(cat compareDBs.json)
compareDB_data=$(jq '.connection1.host = "${SOURCE_SERVER_NAME}"' <<< "$compareDB_data")
compareDB_data=$(jq '.connection1.database = "${SOURCE_DATABASE_NAME}"' <<< "$compareDB_data")
compareDB_data=$(jq '.connection1.user = "${SOURCE_USERNAME}"' <<< "$compareDB_data") 
compareDB_data=$(jq '.connection1.password = "${SOURCE_PASSWORD}"' <<< "$compareDB_data") 
compareDB_data=$(jq '.connection2.host = "${TARGET_SERVER_NAME}"' <<< "$compareDB_data") 
compareDB_data=$(jq '.connection2.database = "$(TARGET_DATABASE_NAME)"' <<< "$compareDB_data") 
compareDB_data=$(jq '.connection2.user = "${TARGET_USERNAME}"' <<< "$compareDB_data") 
compareDB_data=$(jq '.connection2.password = "${TARGET_PASSWORD}"' <<< "$compareDB_data" > compareDBs.json) 

cat compareDBs.json