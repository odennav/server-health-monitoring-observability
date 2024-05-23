#!/bin/bash

# This script reads data from a large file repeatedly to test disk read performance.

while true; do

    # dd used to read from /tmp/bigfile & write to /dev/null with block size of 1M and count of 10000.	
    dd if=/tmp/bigfile of=/dev/null bs=1M count=10000
    
    # 1 second wait before repeating the processs
    sleep 1
done
