#!/bin/bash

# This script checks the elasticsearch health status in central servers

# Server hostname
SERVER_HOSTNAME=$(hostname)

# Slack webhook url
SLACK_WEBHOOK_URL=''

# Elasticsearch health check endpoint
ELK_ENDPOINT=localhost:9200/_cluster/health?delta

elkHealthCheck() {
    ELK_ENDPOINT_DATA=$(curl -s "$ELK_ENDPOINT")

    if [ -n "$ELK_ENDPOINT_DATA" ]; then
        ELK_STATUS=$(echo "$ELK_ENDPOINT_DATA" | sed -n 's/.*"status" : "\(.*\)",/\1/p')


        case "$ELK_STATUS" in

            green ) MESSAGE_NORMAL=":white_check_mark: NOTICE - Elasticsearch health status on $SERVER_HOSTNAME is in good condition." ;;

            yellow ) MESSAGE_WARNING=":warning: WARNING - Elasticsearch health status on $SERVER_HOSTNAME not great. All primary shards are active, but not all replica shards are allocated." ;;

            red ) MESSAGE_ALERT=":fire: ALERT - Elasticsearch health status on $SERVER_HOSTNAME not great. Some primary shards are not active, indicating data loss for the missing primary shards." ;;

            unassigned ) MESSAGE_UNASSIGNED=":question: UNKNOWN - Elasticsearch health status on $SERVER_HOSTNAME is unassigned. Shards are not assigned to any node in the cluster." ;;

        esac


        # Sending the alert message to Slack based on status
        if [ -n "$MESSAGE_NORMAL" ]; then
            curl -X POST -H 'Content-type: application/json' --data "{'text':'$MESSAGE_NORMAL'}" "$SLACK_WEBHOOK_URL"
        elif [ -n "$MESSAGE_WARNING" ]; then
            curl -X POST -H 'Content-type: application/json' --data "{'text':'$MESSAGE_WARNING'}" "$SLACK_WEBHOOK_URL"
        elif [ -n "$MESSAGE_ALERT" ]; then
            curl -X POST -H 'Content-type: application/json' --data "{'text':'$MESSAGE_ALERT'}" "$SLACK_WEBHOOK_URL"
        elif [ -n "$MESSAGE_UNASSIGNED" ]; then
            curl -X POST -H 'Content-type: application/json' --data "{'text':'$MESSAGE_UNASSIGNED'}" "$SLACK_WEBHOOK_URL"
        fi

    else
        echo "Error: Unable to retrieve data from the Elasticsearch health check endpoint."

    fi

}

# Main script
elkHealthCheck
