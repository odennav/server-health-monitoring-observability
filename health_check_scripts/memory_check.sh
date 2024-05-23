#!/bin/bash

# This script checks the percentage of free memory in server

# Slack webhook url
SLACK_WEBHOOK_URL='https://hooks.slack.com/services/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'

# Server hostname
SERVER_HOSTNAME=$(hostname)


# The threshold for free memory usage
THRESHOLD_WARNING=35
THRESHOLD_ALERT=30
THRESHOLD_CRITICAL=10

physicalMemoryCheck() {



    # Total memory usage %
    TOTAL_MEM=$(free -h  | awk 'NR==2 {print $2}' | cut -d'G' -f1)

    FREE_MEM=$(free -h | awk 'NR==2 {print $4}' | cut -d'G' -f1)


    FREE_MEM_PERCENTAGE=$(echo "scale=2; ($FREE_MEM / $TOTAL_MEM) * 100" | bc )


    if [ -n "$FREE_MEM_PERCENTAGE" ]; then

        if (( $(echo "$FREE_MEM_PERCENTAGE > $THRESHOLD_WARNING" | bc) )); then
            MESSAGE_NORMAL=":heavy_check_mark: NOTICE - Free memory on $SERVER_HOSTNAME is at $FREE_MEM_PERCENTAGE%, this is within acceptable range."

            # Sending the alert message to Slack
            curl -X POST -H 'Content-type: application/json' --data "{'text':'$MESSAGE_NORMAL'}" "$SLACK_WEBHOOK_URL"



        elif (( $(echo "$FREE_MEM_PERCENTAGE <= $THRESHOLD_WARNING" | bc) )); then
            MESSAGE_WARNING=":warning: WARNING - Free memory on $SERVER_HOSTNAME is at $FREE_MEM_PERCENTAGE%, this is close to defined threshold."

            # Sending the alert message to Slack
            curl -X POST -H 'Content-type: application/json' --data "{'text':'$MESSAGE_WARNING'}" "$SLACK_WEBHOOK_URL"



        elif (( $(echo "$FREE_MEM_PERCENTAGE = $THRESHOLD_ALERT" | bc) )); then
            MESSAGE_ALERT=":exclamation: WARNING - Free memory on $SERVER_HOSTNAME is at $FREE_MEM_PERCENTAGE% and has reached defined threshold."

            # Sending the alert message to Slack
            curl -X POST -H 'Content-type: application/json' --data "{'text':'$MESSAGE_ALERT'}" "$SLACK_WEBHOOK_URL"



        elif (( $(echo "$FREE_MEM_PERCENTAGE < $THRESHOLD_ALERT" | bc) )); then
            MESSAGE_EMERGENCY=":fire: EMERGENCY - Free memory on $SERVER_HOSTNAME is at $FREE_MEM_PERCENTAGE%, this is below defined threshold."

            # Sending the alert message to Slack
            curl -X POST -H 'Content-type: application/json' --data "{'text':'$MESSAGE_EMERGENCY'}" "$SLACK_WEBHOOK_URL"




        elif (( $(echo "$FREE_MEM_PERCENTAGE < $THRESHOLD_CRITICAL" | bc) )); then
            MESSAGE_CRITICAL=":bangbang: CRITICAL - Free memory on $SERVER_HOSTNAME is at $FREE_MEM_PERCENTAGE% and has reached critical limit."

            # Sending the alert message to Slack
            curl -X POST -H 'Content-type: application/json' --data "{'text':'$MESSAGE_CRITICAL'}" "$SLACK_WEBHOOK_URL"

        fi

    fi

}


swapMemoryCheck() {



    # Total memory usage %
    TOTAL_SWAP_MEM=$(free -h / | awk 'NR==3 {print $2}' | cut -d'G' -f1)

    FREE_SWAP_MEM=$(free -h | awk 'NR==3 {print $4}' | cut -d'G' -f1)


    FREE_SWAP_MEM_PERCENTAGE=$(echo "scale=2; ($FREE_MEM / $TOTAL_MEM) * 100" | bc )


    if [ -n "$FREE_SWAP_MEM_PERCENTAGE" ]; then

        if (( $(echo "$FREE_SWAP_MEM_PERCENTAGE > $THRESHOLD_WARNING" | bc) )); then
            MESSAGE_NORMAL=":heavy_check_mark: NOTICE - Free memory on $SERVER_HOSTNAME is at $FREE_SWAP_MEM_PERCENTAGE%, this is within acceptable range."

            # Sending the alert message to Slack
            curl -X POST -H 'Content-type: application/json' --data "{'text':'$MESSAGE_NORMAL'}" "$SLACK_WEBHOOK_URL"



        elif (( $(echo "$FREE_SWAP_MEM_PERCENTAGE <= $THRESHOLD_WARNING" | bc) )); then
            MESSAGE_WARNING=":warning: WARNING - Free memory on $SERVER_HOSTNAME is at $FREE_SWAP_MEM_PERCENTAGE%, this is close to defined threshold."

            # Sending the alert message to Slack
            curl -X POST -H 'Content-type: application/json' --data "{'text':'$MESSAGE_WARNING'}" "$SLACK_WEBHOOK_URL"



        elif (( $(echo "$FREE_SWAP_MEM_PERCENTAGE = $THRESHOLD_ALERT" | bc) )); then
            MESSAGE_ALERT=":exclamation: WARNING - Free memory on $SERVER_HOSTNAME is at $FREE_SWAP_MEM_PERCENTAGE% and has reached defined threshold."

            # Sending the alert message to Slack
            curl -X POST -H 'Content-type: application/json' --data "{'text':'$MESSAGE_ALERT'}" "$SLACK_WEBHOOK_URL"



        elif (( $(echo "$FREE_SWAP_MEM_PERCENTAGE < $THRESHOLD_ALERT" | bc) )); then
            MESSAGE_EMERGENCY=":fire: EMERGENCY - Free memory on $SERVER_HOSTNAME is at $FREE_SWAP_MEM_PERCENTAGE%, this is below defined threshold."

            # Sending the alert message to Slack
            curl -X POST -H 'Content-type: application/json' --data "{'text':'$MESSAGE_EMERGENCY'}" "$SLACK_WEBHOOK_URL"




        elif (( $(echo "$FREE_SWAP_MEM_PERCENTAGE < $THRESHOLD_CRITICAL" | bc) )); then
            MESSAGE_CRITICAL=":bangbang: CRITICAL - Free memory on $SERVER_HOSTNAME is at $FREE_SWAP_MEM_PERCENTAGE% and has reached critical limit."

            # Sending the alert message to Slack
            curl -X POST -H 'Content-type: application/json' --data "{'text':'$MESSAGE_CRITICAL'}" "$SLACK_WEBHOOK_URL"

        fi

    fi

}



# Main script

physicalMemoryCheck
swapMemoryCheck
