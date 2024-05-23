#!/bin/bash

# This script creates a large file repeatedly to simulate disk space issues.

while true; do

  # dd used to create file named 'bigfile' in /tmp with block size of 1M and count of 10000, results in a file of approximately 10 GB.	
  dd if=/dev/zero of=/tmp/bigfile bs=1M count=10000

  # 1 second wait before repeating the process.
  sleep 1

done
