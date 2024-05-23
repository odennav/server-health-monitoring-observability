#!/bin/bash

# Server hostname
SERVER_HOSTNAME=$(hostname)

# Slack webhook url
SLACK_WEBHOOK_URL=''

pwrSupplyCheck() {
  
    if [ -e /dev/ipmi0 ]; then
        SDR_POWER=$(ipmitool sdr type "Power Supply")

        MESSAGE_POWER=":electric_plug: View sensor data records for power supplies on $SERVER_HOSTNAME\n\`\`\`\n$SDR_POWER\n\`\`\`"

            # Sending the alert message to Slack
            curl -X POST -H 'Content-type: application/json' --data "{'text':'$MESSAGE_POWER'}" "$SLACK_WEBHOOK_URL"

    else
        echo "IPMI device node not found. Ensure IPMI is enabled and modules are loaded."
    fi

}


# Main script
pwrSupplyCheck

