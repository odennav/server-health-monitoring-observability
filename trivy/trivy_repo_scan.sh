#!/bin/bash


# Environment variables
TEMPLATE_PATH="@/home/odennav/opt/gogs/trivy/html.tpl"
DATE=$(date +"%Y-%m-%d_%H-%M")


echo "Starting Trivy Scan"

vulnScan() {

# Trivy scan command on filesystem for gogs repository on cs1
    trivy fs --security-checks vuln,secret,misconfig /opt/gogs/ --format template --template ${TEMPLATE_PATH} --output trivy_report_$DATE.html

    exit_code=$?
    echo "Exit code from Trivy scan: $exit_code"

    if [ "$exit_code" -eq 1 ]; then
        echo "Vulnerability scan of server monitoring scripts failed"
        exit 1;
    else
        echo "No vulnerabilities found"
    fi
}

#Main script

vulnScan

