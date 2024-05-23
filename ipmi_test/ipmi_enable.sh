#!/bin/bash

# Load IPMI modules
sudo modprobe ipmi_si
sudo modprobe ipmi_devintf

# Check if IPMI device exists
ipmiTest() {

    if [ -e /dev/ipmi0 ]; then
        echo "IPMI device found. Querying power metrics..."
        ipmitool sensor | grep -i power
	ipmitool sdr type "Power Supply"
    else
        echo "IPMI device node not found. Ensure IPMI is enabled and modules are loaded."
    fi

}

# Main script
ipmiTest
