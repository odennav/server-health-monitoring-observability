#!/bin/bash

# Server hostname
SERVER_HOSTNAME=$(hostname)

# Slack webhook url
SLACK_WEBHOOK_URL='webhook_url'

THRESHOLD_WARNING=70
THRESHOLD_ALERT=80
THRESHOLD_EMERGENCY=90
THRESHOLD_CRITICAL=98


# CPU system monitoring
cpuUsageCheck() {

    SYS_TIME=$(top -b -n 1 | awk -F'[:, ]+' '/%Cpu\(s\)/  {print $4}' )
    
    if [ ! -z "$SYS_TIME" ]; then
        if (( $(echo "$SYS_TIME =< $THRESHOLD_WARNING" | bc) )); then
            MESSAGE_NORMAL=":white_check_mark: NOTICE - CPU usage on $SERVER_HOSTNAME is in good condition."
            # Sending the alert message to Slack
            curl -X POST -H 'Content-type: application/json' --data "{'text':'$MESSAGE_NORMAL'}" "$SLACK_WEBHOOK_URL"

        elif (( $(echo "$SYS_TIME > $THRESHOLD_WARNING" | bc) )); then
            MESSAGE_WARNING=":warning: NOTICE - CPU usage on $SERVER_HOSTNAME is at $SYS_TIME%."
            # Sending the alert message to Slack
            curl -X POST -H 'Content-type: application/json' --data "{'text':'$MESSAGE_WARNING'}" "$SLACK_WEBHOOK_URL"

        elif (( $(echo "$SYS_TIME > $THRESHOLD_ALERT" | bc) )); then
            MESSAGE_ALERT=":exclamation: NOTICE - CPU usage on $SERVER_HOSTNAME is at $SYS_TIME%."
            # Sending the alert message to Slack
            curl -X POST -H 'Content-type: application/json' --data "{'text':'$MESSAGE_ALERT'}" "$SLACK_WEBHOOK_URL"

        elif (( $(echo "$SYS_TIME >= $THRESHOLD_EMERGENCY" | bc) )); then
            MESSAGE_EMERGENCY=":fire: NOTICE - CPU usage on $SERVER_HOSTNAME is at $SYS_TIME%."
            # Sending the alert message to Slack
            curl -X POST -H 'Content-type: application/json' --data "{'text':'$MESSAGE_EMERGENCY'}" "$SLACK_WEBHOOK_URL"


        elif (( $(echo "$SYS_TIME >= $THRESHOLD_CRITICAL" | bc) )); then
            MESSAGE_CRITICAL=":bangbang: NOTICE - CPU usage on $SERVER_HOSTNAME is at $SYS_TIME%."
            # Sending the alert message to Slack
            curl -X POST -H 'Content-type: application/json' --data "{'text':'$MESSAGE_CRITICAL'}" "$SLACK_WEBHOOK_URL"

    else
        echo "CPU system time not received"

    fi

}



# Load average monitoring
loadAvgCheck() {

    CPU_CORES=$(nproc)
    LOAD_AVG_1=$(uptime | awk -F'[:, ]+' '{print $9}')
    LOAD_AVG_5=$(uptime | awk -F'[:, ]+' '{print $10}')
    LOAD_AVG_15=$(uptime | awk -F'[:, ]+' '{print $11}')

    if [ (! -z "$CPU_CORES") &&  (! -z "$LOAD_AVG_1") && (! -z "$LOAD_AVG_5") && (! -z "$LOAD_AVG_15") ]; then
        if (( $(echo "$LOAD_AVG_1 < $CPU_CORES" | bc) && $(echo "$LOAD_AVG_5 < $CPU_CORES" | bc) && $(echo "$LOAD_AVG_15 < $CPU_CORES" | bc) )); then
        MESSAGE_NORMAL=":heavy_check_mark: NOTICE - Load average on $SERVER_HOSTNAME is $LOAD_AVG_1, $LOAD_AVG_5, $LOAD_AVG_15. System workload is fine."
            # Sending the alert message to Slack
            curl -X POST -H 'Content-type: application/json' --data "{'text':'$MESSAGE_NORMAL'}" "$SLACK_WEBHOOK_URL"

        elif (( $(echo "$LOAD_AVG_1 > $CPU_CORES" | bc) && $(echo "$LOAD_AVG_5 > $CPU_CORES" | bc) && $(echo "$LOAD_AVG_15 > $CPU_CORES" | bc) )); then
        MESSAGE_ALERT=":exclamation: NOTICE - Load average on $SERVER_HOSTNAME is $LOAD_AVG_1, $LOAD_AVG_5, $LOAD_AVG_15. System is under heavy load."
            # Sending the alert message to Slack
            curl -X POST -H 'Content-type: application/json' --data "{'text':'$MESSAGE_ALERT'}" "$SLACK_WEBHOOK_URL"
         
        elif (( $(echo "$LOAD_AVG_1 > $CPU_CORES" | bc) && $(echo "$LOAD_AVG_5 > $CPU_CORES" | bc) && $(echo "$LOAD_AVG_15 > $CPU_CORES" | bc) && $(echo "$LOAD_AVG_5 < $LOAD_AVG_1" | bc) && $(echo "$LOAD_AVG_5 < $LOAD_AVG_15" | bc) )); then
        MESSAGE_EMERGENCY=":: NOTICE - Load average on $SERVER_HOSTNAME is $LOAD_AVG_1, $LOAD_AVG_5, $LOAD_AVG_15. Spikes of heavy load observed."
            # Sending the alert message to Slack
            curl -X POST -H 'Content-type: application/json' --data "{'text':'$MESSAGE_EMERGENCY'}" "$SLACK_WEBHOOK_URL"

        elif (( $(echo "$LOAD_AVG_1 > $CPU_CORES" | bc) && $(echo "$LOAD_AVG_5 > $CPU_CORES" | bc) && $(echo "$LOAD_AVG_15 > $CPU_CORES" | bc) && $(echo "$LOAD_AVG_1 < $LOAD_AVG_5" | bc) && $(echo "$LOAD_AVG_5 < $LOAD_AVG_15" | bc) )); then
        MESSAGE_CRITICAL=":: NOTICE - Load average on $SERVER_HOSTNAME is $LOAD_AVG_1, $LOAD_AVG_5, $LOAD_AVG_15. System is consistently overloaded."
            # Sending the alert message to Slack
            curl -X POST -H 'Content-type: application/json' --data "{'text':'$MESSAGE_CRITICAL'}" "$SLACK_WEBHOOK_URL"

        fi

    fi

}



# Main script
cpuUsageCheck
loadAvgCheck

