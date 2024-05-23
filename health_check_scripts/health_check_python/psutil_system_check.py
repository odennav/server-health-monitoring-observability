#!/usr/bin/env python3

import psutil
import requests

SLACK_WEBHOOK_URL = ''


def send_slack_message(message):
    payload = {"text": message}
    headers = {'Content-type': 'application/json'}
    response = requests.post(SLACK_WEBHOOK_URL, json=payload, headers=headers)
    if response.status_code != 200:
        raise ValueError(f"Request to Slack returned an error {response.status_code}, the response is:\n{response.text}")


def getLoadAvg():
    loadavg = psutil.getloadavg()
    loadavgpercentages = [x / psutil.cpu_count() * 100 for x in loadavg]
    message = f"Load average of system is {loadavgpercentages}"
    send_slack_message(message)


def memCheck():
    mem = psutil.virtual_memory()
    FREE_MEMORY_THRESHOLD = 2000 * 1024 * 1024  # 2GB
    if mem.available <= FREE_MEMORY_THRESHOLD:
        message = "WARNING - Free memory on server is below threshold."
        send_slack_message(message)


def swapCheck():
    swapstats = psutil.swap_memory()
    FREE_SWAP_THRESHOLD = 80
    if swapstats.percent >= FREE_SWAP_THRESHOLD:
        message = "WARNING - Free swap memory on server is below threshold."
        send_slack_message(message)


def diskCheck():
    diskstats = psutil.disk_usage('/')
    FREE_DISK_PERCENTAGE_THRESHOLD = 80
    if diskstats.percent >= FREE_DISK_PERCENTAGE_THRESHOLD:
        message = "WARNING - Free disk space on root partition is below threshold."
        send_slack_message(message)


if __name__ == "__main__":
    getLoadAvg()
    memCheck()
    swapCheck()
    diskCheck()

