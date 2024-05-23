#!/bin/bash

updateYum() {
sudo yum update -y    #Update package manager
sudo yum upgrade
}


#Get Python version and extract major and minor version numbers
pyInstall() {                                                      
python_version=$(python3 -V 2>&1 | awk '{print $2}')
python_major=$(echo $python_version | cut -d. -f1)
python_minor=$(echo $python_version | cut -d. -f2)

    if [ "$python_major" -eq 3 ] && [ "$python_minor" -gt 9 ] && [ "$python_minor" -lt 11 ]; then    #Check if Python version is within the specified range
        echo "Python version is already upgraded"

    else
        echo "Python is not in version 3" 
        echo "Upgrading to required python version"
        sudo yum update -y    #Update yum, package manager for RPM-based operating systems.
        sudo yum install python3.11 -y    #Install python 3
    
        #Create symbolic link and point to Python 3 as the default.
        sudo ln -sf /usr/bin/python3.11 /usr/bin/python
        sudo ln -sf /usr/bin/python3.11 /usr/bin/python3

        sudo yum install python3-pip -y    #Install package installer for python3.
        sudo pip3 install --upgrade pip -y
        sudo yum install python3.11-devel -y    #Install Python 3 and development tools
        sudo yum install python3.11-libs python3.11-pip python3.11-setuptools -y   # Install the Python 3.6 venv module
        sudo yum install -y net-tools     #Install net-tools
fi
}

#Checking python version
pyVersionCheck() {                                                
python_version=$(python3 -V 2>&1 | awk '{print $2}')
python_major=$(echo $python_version | cut -d. -f1)
python_minor=$(echo $python_version | cut -d. -f2)

    if [ "$python_major" -eq 3 ] && [ "$python_minor" -gt 10 ]; then
        echo "Python version is now python 3.11"
    else
        echo "Please ensure python3.11 is installed." >&2
    fi
}


#MAIN SCRIPT

version=$(awk -F'[".]' '/VERSION_ID=/ {print $2}' /etc/os-release)
id=$(awk -F'[".]' '/REDHAT_SUPPORT_PRODUCT_VERSION=/ {print $2}' /etc/os-release)


if [ "$version" -eq 9 ]; then
  echo "Begin function calls"
  
  if [ "$id" = "CentOS Stream" ]; then
    echo "Update package manager"
    updateYum
    echo "Install Python dependencies for provisioning tasks"
    pyInstall
    echo "Confirming python version"
    pyVersionCheck
  fi  
else
  echo "Linux version not compatible" >&2
fi

