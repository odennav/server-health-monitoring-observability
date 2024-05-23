#!/bin/bash

# This script checks the status and synchronization with the NTP server

# Server hostname
SERVER_HOSTNAME=$(hostname)

# Slack webhook url
SLACK_WEBHOOK_URL='https://hooks.slack.com/services/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'


ntpEnabledCheck() {
    NTP_DATA=$(timedatectl status)

    if [ -n "$NTP_DATA" ]; then
        NTP_STATUS=$(echo "$NTP_DATA" | sed -n 's/.*NTP enabled: \(.*\)/\1/p')

        case "$NTP_STATUS" in
            yes ) MESSAGE_NORMAL=":white_check_mark: NOTICE - NTP is enabled on $SERVER_HOSTNAME" ;;

            no ) MESSAGE_WARNING=":warning: WARNING - NTP is disabled on $SERVER_HOSTNAME" ;;

             * ) MESSAGE_UNKNOWN=":question: UNKNOWN - Unable to determine NTP status on $SERVER_HOSTNAME" ;;

        esac

        # Sending the alert message to Slack based on status
        if [ -n "$MESSAGE_NORMAL" ]; then
            curl -X POST -H 'Content-type: application/json' --data "{'text':'$MESSAGE_NORMAL'}" "$SLACK_WEBHOOK_URL"
        elif [ -n "$MESSAGE_WARNING" ]; then
            curl -X POST -H 'Content-type: application/json' --data "{'text':'$MESSAGE_WARNING'}" "$SLACK_WEBHOOK_URL"
        elif [ -n "$MESSAGE_UNKNOWN" ]; then
            curl -X POST -H 'Content-type: application/json' --data "{'text':'$MESSAGE_UNKNOWN'}" "$SLACK_WEBHOOK_URL"

        fi
    else
        echo "Error: Unable to retrieve ntp data from $SERVER_HOSTNAME."
    fi
}

ntpSyncCheck() {
    NTP_DATA=$(timedatectl status)

    if [ -n "$NTP_DATA" ]; then
        NTP_STATUS=$(echo "$NTP_DATA" | sed -n 's/.*NTP synchronized: \(.*\)/\1/p')

        case "$NTP_STATUS" in
            yes ) MESSAGE_NORMAL=":white_check_mark: NOTICE - NTP is synchronized on $SERVER_HOSTNAME" ;;

            no ) MESSAGE_WARNING=":warning: WARNING - NTP is not synchronized on $SERVER_HOSTNAME" ;;

             * ) MESSAGE_UNKNOWN=":question: UNKNOWN - Unable to determine NTP synchronized status on $SERVER_HOSTNAME" ;;

        esac

        # Sending the alert message to Slack based on status
        if [ -n "$MESSAGE_NORMAL" ]; then
            curl -X POST -H 'Content-type: application/json' --data "{'text':'$MESSAGE_NORMAL'}" "$SLACK_WEBHOOK_URL"
        elif [ -n "$MESSAGE_WARNING" ]; then
            curl -X POST -H 'Content-type: application/json' --data "{'text':'$MESSAGE_WARNING'}" "$SLACK_WEBHOOK_URL"
        elif [ -n "$MESSAGE_UNKNOWN" ]; then
            curl -X POST -H 'Content-type: application/json' --data "{'text':'$MESSAGE_UNKNOWN'}" "$SLACK_WEBHOOK_URL"

        fi
    else
        echo "Error: Unable to retrieve ntp data from $SERVER_HOSTNAME."
    fi
}

# Main script
ntpEnabledCheck
ntpSyncCheck


