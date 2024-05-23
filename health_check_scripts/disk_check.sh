#!/bin/bash

# This script checks disk usage of partitions mounted on / and /var directories

# slack webhook url
SLACK_WEBHOOK_URL='webhook_url'

# Server hostname
SERVER_HOSTNAME=$(hostname)

# The thresholds for disk usage 
THRESHOLD_WARNING=65
THRESHOLD_ALERT=70
THRESHOLD_CRITICAL=95

diskCheckRoot() {

    # Current disk usage %
    DISK_USAGE=$(df -h / | awk 'NR==6 {print $5}' | cut -d'%' -f1)

    if [ -n "$DISK_USAGE" ]; then
    
        if [ "$DISK_USAGE" -le "$THRESHOLD_WARNING" ]; then
            MESSAGE_NORMAL=":heavy_check_mark: NOTICE - Disk usage of root partition on $SERVER_HOSTNAME is at $DISK_USAGE%, this is within acceptable range."

            # Sending the alert message to Slack
            curl -X POST -H 'Content-type: application/json' --data "{'text':'$MESSAGE_NORMAL'}" "$SLACK_WEBHOOK_URL"



        if [ ("$DISK_USAGE"=="$THRESHOLD_WARNING") && ("$DISK_USAGE" -ge "$THRESHOLD_WARNING") ]; then
            MESSAGE_WARNING=":warning: WARNING - Disk usage of root partition on $SERVER_HOSTNAME is at $DISK_USAGE%, this is close to defined threshold."

            # Sending the alert message to Slack
            curl -X POST -H 'Content-type: application/json' --data "{'text':'$MESSAGE_WARNING'}" "$SLACK_WEBHOOK_URL"
       


        elif [ "$DISK_USAGE"=="$THRESHOLD_ALERT" ]; then
            MESSAGE_ALERT=":exclamation: WARNING - Disk usage of root partition on $SERVER_HOSTNAME is at $DISK_USAGE% and has reached defined threshold."

            # Sending the alert message to Slack
            curl -X POST -H 'Content-type: application/json' --data "{'text':'$MESSAGE_ALERT'}" "$SLACK_WEBHOOK_URL"



        elif [ "$DISK_USAGE" -ge "$THRESHOLD_ALERT" ]; then
            MESSAGE_EMERGENCY=":fire: EMERGENCY - Disk usage of root partition on $SERVER_HOSTNAME is at $DISK_USAGE%, this is above defined threshold."

            # Sending the alert message to Slack
            curl -X POST -H 'Content-type: application/json' --data "{'text':'$MESSAGE_EMERGENCY'}" "$SLACK_WEBHOOK_URL"




        elif [ "$DISK_USAGE" -ge "$THRESHOLD_CRITICAL" ]; then
            MESSAGE_CRITICAL=":bangbang: CRITICAL - Disk usage of root partition on $SERVER_HOSTNAME is at $DISK_USAGE% and has reached critical limit."

            # Sending the alert message to Slack
            curl -X POST -H 'Content-type: application/json' --data "{'text':'$MESSAGE_CRITICAL'}" "$SLACK_WEBHOOK_URL"
        
        fi

    fi

}


diskCheckLogs() {

    # Current disk usage %
    DISK_USAGE_LOGS=$(df -h /var | awk 'NR==10 {print $5}' | cut -d'%' -f1)

    if [ -n "$DISK_USAGE_LOGS" ]; then
    
        if [ "$DISK_USAGE_LOGS" -le "$THRESHOLD_WARNING" ]; then
            MESSAGE_NORMAL=":heavy_check_mark: NOTICE - Disk usage of partition mounted on /var in $SERVER_HOSTNAME is at $DISK_USAGE_LOGS%, this is within acceptable range."

            # Sending the alert message to Slack
            curl -X POST -H 'Content-type: application/json' --data "{'text':'$MESSAGE_NORMAL'}" "$SLACK_WEBHOOK_URL"



        if [ ("$DISK_USAGE_LOGS"=="$THRESHOLD_WARNING") && ("$DISK_USAGE_LOGS" -ge "$THRESHOLD_WARNING") ]; then
            MESSAGE_WARNING=":warning: WARNING - Disk usage of partition mounted on /var in $SERVER_HOSTNAME is at $DISK_USAGE_LOGS%, this is close to defined threshold."

            # Sending the alert message to Slack
            curl -X POST -H 'Content-type: application/json' --data "{'text':'$MESSAGE_WARNING'}" "$SLACK_WEBHOOK_URL"
       


        elif [ "$DISK_USAGE_LOGS"=="$THRESHOLD_ALERT" ]; then
            MESSAGE_ALERT=":exclamation: WARNING - Disk usage of partition mounted on /var in $SERVER_HOSTNAME is at $DISK_USAGE_LOGS% and has reached defined threshold."

            # Sending the alert message to Slack
            curl -X POST -H 'Content-type: application/json' --data "{'text':'$MESSAGE_ALERT'}" "$SLACK_WEBHOOK_URL"



        elif [ "$DISK_USAGE_LOGS" -ge "$THRESHOLD_ALERT" ]; then
            MESSAGE_EMERGENCY=":fire: EMERGENCY - Disk usage of partition mounted on /var in $SERVER_HOSTNAME is at $DISK_USAGE_LOGS%, this is above defined threshold."

            # Sending the alert message to Slack
            curl -X POST -H 'Content-type: application/json' --data "{'text':'$MESSAGE_EMERGENCY'}" "$SLACK_WEBHOOK_URL"



        elif [ "$DISK_USAGE_LOGS" -ge "$THRESHOLD_CRITICAL" ]; then
            MESSAGE_CRITICAL=":bangbang: CRITICAL - Disk usage of partition mounted on /var in $SERVER_HOSTNAME is at $DISK_USAGE_LOGS% and has reached critical limit."

            # Sending the alert message to Slack
            curl -X POST -H 'Content-type: application/json' --data "{'text':'$MESSAGE_CRITICAL'}" "$SLACK_WEBHOOK_URL"
        
        fi

    fi

}


# Main script

diskCheckRoot
diskCheckLogs
