#!/bin/bash

# This script counts the number of old files and the size of elasticsearch index files

# Server hostname
SERVER_HOSTNAME=$(hostname)

# Slack webhook url
SLACK_WEBHOOK_URL=''

# The directory to search for old files
TARGET_DIR="/var/lib/elasticsearch/sfw-name/nodes/0/indices"

# Expected number of files older than 180 days
ZERO_FILES=0

# Base size of log
ZERO_SIZE=0

# Size threshold of logs from elasticsearch
SIZE_LIMIT=50000
SIZE_THRESHOLD="50GB"


oldFilesCheck() {

    if [ -d $TARGET_DIR ]; then
        OLD_FILES_NUMBER=$(find $TARGET_DIR -type f -mtime +180 | awk 'END { print NR }')

          if [ -n "$OLD_FILES_NUMBER" ]; then

              if [ "$OLD_FILES_NUMBER" -eq "$ZERO_FILES" ]; then

                  MESSAGE_NORMAL=":heavy_check_mark: NOTICE - No old files found on $SERVER_HOSTNAME."
                  
                  # Sending the alert message to Slack
                  curl -X POST -H 'Content-type: application/json' --data "{'text':'$MESSAGE_NORMAL'}" "$SLACK_WEBHOOK_URL"


              elif [ "$OLD_FILES_NUMBER" -gt $ZERO_FILES ]; then
                  MESSAGE_ALERT=":warning: NOTICE - $OLD_FILES_NUMBER old files found on $SERVER
_HOSTNAME."   
                  # Sending the alert message to Slack
                  curl -X POST -H 'Content-type: application/json' --data "{'text':'$MESSAGE_ALERT'}" "$SLACK_WEBHOOK_URL"
 
              fi

           fi

    fi
}



fileSizeCheck() {

    if [ -d $TARGET_DIR ]; then
        LARGE_FILES_NUMBER=$(du -sm $TARGET_DIR | awk -v limit="$SIZE_LIMIT" '$1 > limit' | wc -l )

          if [ -n "$LARGE_FILES_NUMBER" ]; then

              if [ "$LARGE_FILES_NUMBER" -eq "$ZERO_SIZE" ]; then

                  MESSAGE_NORMAL=":heavy_check_mark: NOTICE - None of the log files from elasticsearch on $SERVER_HOSTNAME are over 50GB."

                  # Sending the alert message to Slack
                  curl -X POST -H 'Content-type: application/json' --data "{'text':'$MESSAGE_NORMAL'}" "$SLACK_WEBHOOK_URL"


              elif [ "$LARGE_FILES_NUMBER" -gt $ZERO_SIZE ]; then
                  MESSAGE_ALERT=":warning: NOTICE - $LARGE_FILES_NUMBER log files from elasticsearch on $SERVER_HOSTNAME are over $SIZE_THRESHOLD."
              
                  # Sending the alert message to Slack
                  curl -X POST -H 'Content-type: application/json' --data "{'text':'$MESSAGE_ALERT'}" "$SLACK_WEBHOOK_URL"


              fi

           fi
    fi
}




# Main script

oldFilesCheck
fileSizeCheck
