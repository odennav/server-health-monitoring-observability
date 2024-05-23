#!/bin/bash

# Function to create "tasks" folder in each specified directory
create_tasks_folders() {
    # List of directories
    directories="cpu_usage_check/ elk_health_check/ memory_usage_check/ old_files_check/ disk_space_check/ ipmi_check/ ntp_check/"

    # Loop through each directory and create the "tasks" folder
    for dir in $directories; do
        mkdir -p "${dir}/tasks"
    done
}

# Main script
create_tasks_folders

