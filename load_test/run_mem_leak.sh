#!/bin/bash

# This script runs mem_leak.py scrip 20 times in the background

for i in {1..20}; do
    python3 mem_leak.py &

done


