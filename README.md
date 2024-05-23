# Server Health Monitoring and Observability 

This project is intended to simulate automated monitoring and observability of Cellusys machines(linux servers) running CentOS by retrieving information on system utilization (CPU, Memory, Disk) with Bash and Python.

The Linux servers are classified as:

- Central servers
- Message processors

Ansible is used to setup deployment of resurce monitoring scripts in all central servers and message processors.

System resource usage messages are sent to a Slack channel for real-time observability of resources.


# Getting Started

Supported systems:

- RedHat
- CentOS


We'll implement workflow below:

- Provision Servers
- User Configuration on Linux servers
- Docker Installation
- Slack Setup
- Jenkins Installation and Configuration
- SonarQube Installation and Setup
- Gogs Installation and Configuration
- Trivy Installation and Integration
- Ansible Setup and Deployment
- Install Plugins
- Pipeline Setup with Jenkinsfile

-----

## Provision Servers

Eight linux servers are provisioned with Vagrant in this lab.
Use Vagrantfile in this repository.

**Install Vagrant**

If you haven't installed Vagrant, download it [here](https://developer.hashicorp.com/vagrant/install) and follow the installation instructions for your OS.

If you encounter an issue with Windows, you might get a blue screen upon attempt to bring up a VirtualBox VM with Hyper-V enabled.

To use VirtualBox on Windows, ensure Hyper-V is not enabled. Then turn off the feature with the following Powershell commands:

```console
Disable-WindowsOptionalFeature -Online -FeatureName Microsoft-Hyper-V-All
bcdedit /set hypervisorlaunchtype off
```

After reboot of your local machine, run:

```bash
vagrant up
```

-----

## User Configuration on Linux Servers

**Add New User**

We'll use `cs1` virtual machine as our build machine.
Integrations to pipeline is implemented on this server

1. Change password for root user

Login to Vagrant VM

```bash
vagrant ssh cs1
```

```bash
sudo passwd
```

Switch to root user. Add new user 'odennav' to sudo group.
```bash
sudo useradd odennav
sudo usermod -aG wheel odennav
```

Notice the prompt to enter your user password. To disable password prompt for every sudo command, implement the following:

Add sudoers file for odennav-admin

```bash
echo "odennav ALL=(ALL) NOPASSWD: ALL" | sudo tee /etc/sudoers.d/odennav
```

Ensure correct permissions for sudoers file

```bash
sudo chmod 0440 /etc/sudoers.d/odennav
sudo chown root:root /etc/sudoers.d/odennav
```

Test sudo privileges by switching to new user

```bash
su - odennav
sudo ls -la /root
```

To change the `PermitRootLogin` setting, modify the SSH server configuration file `/etc/ssh/sshd_config` as shown below:

```text
PermitRootLogin no:
```

Please note you'll have to repeat this user setup for each server provisioned.


-----

## Docker Installation

Uninstall any older versions before installing a new version, along with associated dependencies

```bash
sudo yum remove docker \
                  docker-client \
                  docker-client-latest \
                  docker-common \
                  docker-latest \
                  docker-latest-logrotate \
                  docker-logrotate \
                  docker-engine
```

Install the `yum-utils` package and set up the repository

```bash
sudo yum install -y yum-utils
sudo yum-config-manager --add-repo https://download.docker.com/linux/centos/docker-ce.repo
```

Install Docker Engine, containerd, and Docker Compose

```bash
sudo yum install docker-ce docker-ce-cli containerd.io docker-buildx-plugin docker-compose-plugin
```

Start Docker after installation

```bash
sudo systemctl start docker
```

Verify successful Docker engine installation

```bash
sudo docker run hello-world
```

-----

## Slack Setup

Slack is the communication platform on our local machine we'll use to receive resource usage notifications from monitored servers.

**Procedure**

- Download Slack here for [Windows](https://slack.com/downloads/windows), [Mac](https://slack.com/downloads/mac) or [Linux](https://slack.com/downloads/linux)

- Create new workspace

- Setup new group channel in your workspace

- Enable and create incoming webhooks to your group channel. Use this guide for further [reference](https://api.slack.com/messaging/webhooks)

- Select the channel your slack app will post to and a  Webhook URL will be generated as shown.

This URL is used in our monitoring script for HTTP POST requests.

-----


## Jenkins Installation and Configuration

 **Install Jenkins**

We'll use the long term support release which is installed from redhat-stable yum repository.

```bash
sudo wget -O /etc/yum.repos.d/jenkins.repo \
    https://pkg.jenkins.io/redhat-stable/jenkins.repo
sudo rpm --import https://pkg.jenkins.io/redhat-stable/jenkins.io-2023.key
sudo yum upgrade
# Add required dependencies for the jenkins package
sudo yum install fontconfig java-17-openjdk
sudo yum install jenkins
sudo systemctl daemon-reload
```

Enable jenkins service
```bash
sudo systemctl enable jenkins
```
Start jenkins service
```bash
sudo systemctl start jenkins
```

Confirm jenkins service is active and running
```bash
sudo systemctl status jenkins
```

**Post Installation Setup**

Next we use the post-installation setup wizard to unlock jenkins, customize plugins and create first admin user required to continue accessing jenkins.

1. Browse to 192.168.10.6:8080 to see the**Unlock Jenkins** page.

2. Obtain the automatically-generated alphanumeric password
    
```bash
sudo cat /var/jenkins_home/secrets/initialAdminPassword
```

3. Paste this password into the `Administrator password` field and click `Continue` to access jenkin's main UI.


**Customize Jenkins with Plugins**


After unlocking Jenkins, the **Customize Jenkins** page appears. 

Here you can install any number of useful plugins as part of your initial setup.

Click on `Install suggested plugins` to install the recommended set of plugins, which are based on most common use cases.


**Create First Administrator User**

Finally, after customizing Jenkins with plugins, Jenkins asks you to create your first administrator user.

1. When the **Create First Admin User** page appears, specify the details for your administrator user in the respective fields and click `Save and Continue`.

2. When the Jenkins is ready page appears, click Start using Jenkins.
Notes:

This page may indicate Jenkins is almost ready! instead and if so, click `Restart`.

If the page does not automatically refresh after a minute, use your web browser to refresh the page manually.

3. If required, log in to Jenkins with the credentials of the user you just created and you are ready to start using Jenkins.

-------------------------------------------------------------------------------------------

## SonarQube Installation and Setup

SonarQube is a code quality assurance tool that collects and analyzes source code, providing reports for the code quality of our project.

It enables us to deploy clean code consistently and reliably.

We'll run the long term community version of sonarqube's image.

**Install SonarQube Container**

```bash
docker run -d --name sonar -p 9000:9000 sonarqube:lts-community
```

Confirm container is running
```bash
docker ps -a --filter "name=sonar"
```

Browse to UI of SonarQube at `192.168.10.1:9000`

Use `admin` for default username and password. Update to new password when requested.


**Generate Token**

Go to **Administration** tab and select `Security` tab.

From the drop down, click on `Users`.

This section is used to create and administer individual users.

Click on button at far right under `Tokens` column.

Enter `Token Name` as `sonar-token` and click on `Generate`. Note period of expiry.

Copy this access code, we'll use it to create credential for SonarQube in jenkins.


**Create SonarQube Secret**

Go to `Jenkins` dashboard and select `Manage Jenkins`.

Under the `Security` section, select `Credentials`

Click on `(global)` domain of jenkins `System` store

Next, click on blue button `+ Add Credentials` at top right

Assign the following:

Kind -------------------------> Secret text

Scope ------------------------> Global

Secret -----------------------> `sonar-token`

Description ------------------> sonar


**Configure SonarQube Server**

Go to `Jenkins` dashboard and select `Manage Jenkins`.

Under the `System Configuration` section, select `Configure System`

Scroll down and search for **SonarQube servers** and `SonarQube installatons`

Click `Add SonarQube` and assign the following:

Name ---------------------------------> sonar-server

Server URL ---------------------------> 192.168.10.1:9000/

Server authentication token ----------> sonar

Click on `Save`

-----

## Gogs Installation and Configuration

Build a simple, stable and extensible self-hosted Git service.

Pull image from Docker Hub.

```bash
docker pull gogs/gogs
```

Create local directory for volume.

```bash
mkdir -p /opt/gogs
```
Use `docker run` for the first time.

```bash
docker run --name gogs --restart always -p 10022:22 -p 3880:3000 -v /opt/gogs:/data gogs/gogs
```

It is important to map the SSH service from the container to the host and set the appropriate SSH Port and URI settings when setting up Gogs for the first time.

To access and clone Git repositories with the above configuration you would use:

```bash
git clone ssh://git@192.168.10.101:10022/odennav/server-health-monitoring.git
```

Files will be store in local path of build-machine instance, /opt/gogs in my case.

For first-time run installation, install gogs with mysqllite3

Initialize local repository and create README
```bash
git init
touch README.md
echo "Server Health Monitoring" > README.md
```

```bash
git config --global user.email "odennav@odennav.com"
git config --global user.name "odennav-gogs"
git config --global credentials.helper store
```

Add all changes to staging area and commit

```bash
git add .
git commit -m "first commit"
```

Connect local repo with remote repository

```bash
git remote add origin https://192.168.10.101:3880/odennav/server-health-monitoring.git
```

Push commits to remote repository
```bash
git push -u origin master
```

Set tracking information for this branch
```bash
git branch --set-upstream-to=origin/master master
```

**Add Public SSH Key to Gogs Server**

We'll add RSA public key to Gogs to ensure SSH authentication with Jenkins.

1. Generate RSA key pair
```bash
ssh-keygen
```

Select the defaults for all three prompts by hitting the Enter key at each prompt.

By default, ssh-keygen will save the key pair to `~/.ssh` directory

In that directory, two files `id_rsa` and `id_rsa.pub` corresponding to the private and public keys, respectively will be present.


2. Go to Gogs settings page at `http://192.168.10.1:3880/user/settings`
   
   Select `SSH Keys` tab and click on `Add Key` on `Manage SSH Keys` tab

3. Enter `Key Name` as `id_rsa`

Copy your public key, paste into `Content` field and click `Add Key`

```bash
cat ~/.ssh/id_rsa.pub | tr -d '\n'
```


**Add Private Key as Gogs Credential to Jenkins**

Here we'll add private RSA key generated on `cs1` where jenkins-master is installed and add to Jenkins.

Go to `Jenkins` dashboard and select `Manage Jenkins`.

Under this section, select `Credentials`

Click on `(global)` domain of jenkins `System` store

Next, click on blue button `+ Add Credentials` at top right

Assign the following:


Kind -------------------------------> SSH Username with private key

Scope ------------------------------> Global

Description ------------------------> private-key

Username ---------------------------> odennav-gogs

Select radio button `Enter directly` for `Private Key`

Click on `Add` button on the right and paste the copied private key as new secret into `key` field.

Select `Create` to save credential.

-----

## Trivy Installation and Integration

Trivy is an open source security scanner used to find vulnerabilities and Iac misconfigurations.

It's used to scan the following:

- Container images

- Filesystem

- Virtual machine image

- Git repository remote

- Kubernetes cluster

- Cloud infrastructure


**Install using package manager**

```bash
cat << EOF | sudo tee -a /etc/yum.repos.d/trivy.repo
[trivy]
name=Trivy repository
baseurl=https://aquasecurity.github.io/trivy-repo/rpm/releases/\$basearch/
gpgcheck=1
enabled=1
gpgkey=https://aquasecurity.github.io/trivy-repo/rpm/public.key
EOF
sudo yum -y update
sudo yum -y install trivy
```

If you intend to use trivy as container image, mount docker.sock as from the host into the Trivy container.

**Integrate Trivy to Jenkins with Bash Script**

The bash script below is used in our groovy pipeline script to scan and analyze gogs repositrory with Trivy for vulnerabilities.


```bash
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
```

When jenkins pipelne is executed, if there are any vulnerabilities, the next steps in deploy pipeline will be stopped from running.


-----

## Ansible Setup and Deployment

**Install Ansible**

To install ansibe without upgrading current python version, we'll make use of the `yum` packae manager

```bash
sudo yum update
```

Install EPEL repository
```bash
sudo yum install epel-release
```
Verify installation of EPEL repository
```bash
sudo yum repolist
```

Install Ansible
```bash
sudo yum install ansible
```

Confirm installation
```bash
ansible --version
```

Another approach to install Ansible, we'll be to use bash script to upgrade current python version. Check this repository for python script `python_upgrade.sh`

Upgrade python
```bash
./python_upgrade.sh
```

Confirm new python version
```bash
python3 -V
```

Install Ansible with pip
```bash
python3 -m pip install --user ansible
```

Install `ansible-core` package
```bash
$ python3 -m pip install --user ansible-core
```

Confirm installation
```bash
ansible --version
```

**Configure Ansible Vault**

Ansible communicates with target remote servers using SSH and usually we generate RSA key pair and copy the public key to each remote server, instead we'll use username and password credentials of `odennav` user.

This credentials are added to inventory host file but encrypted with `ansible-vault`

Ensure all IPv4 addresses and user variables  of remote servers are in the inventory file as shown

View `ansible-vault/values.yml` which has the secret password
```bash
cat /server-health-monitoring/ansible-vault/values.yml
```

Generate vault password file
```bash
openssl rand -base64 2048 > /server-health-monitoring/ansible-vault/secret-vault.pass
```

Create ansible vault with vault password file
```bash
ansible-vault create /server-health-monitoring/ansible-vault/values.yml --vault-password-file=/server-health-monitoring/ansible-vault/secret-vault.pass
```

View content of ansible vault 
```bash
ansible-vault view /server-health-monitoring/ansible-vault/values.yml --vault-password-file=/server-health-monitoring/ansible-vault/secret-vault.pass
```

Read ansible vault password from environment variable
```bash
export ANSIBLE_VAULT_PASSWORD_FILE=/server-health-monitoring/ansible-vault/secret-vault.pass
```

Confirm environment variable has been exported
```bash
export ANSIBLE_VAULT_PASSWORD_FILE
```

Test Ansible by pinging all remote servers in inventory list
```bash
ansible all -m ping
```

**Run ansible playbook**

This playbook will implement the following tasks in remote servers:

- Create directories for each monitoring role
- Copy shell scripts to remote hosts for monitoring
- Setup cron jobs to execute scripts in remote hosts
- Restart cron service

```bash
cd /server-health-monitoring/ansible
ansible-palybook --inventory inventory  deploy_bundle/deploy_bundle.yml -e @/server-health-monitoring/ansible-vault/values.yml  
```

-----


## Install Plugins 

Plugins are required to integrate tools to Jenkins and execute in our pipeline script.

Go to `Plugin Manager` under `Manage Jenkins` section of Jenkins dasboard

Our next task is to search and install the following plugins below:

- Eclipse Temurin installer

- Docker

- Docker Pipeline

- docker-build-step

- CloudBees Docker Build and Publish

- Gogs

- Trivy

- Ansible

Select `Install without restart` at bottom left


**Configure Other Global Tools**

Go to `Global Tool Configuration` under `Manage Jenkins` section of Jenkins dasboard

Note procedures to configure jdk and docker as global tools.

**Procedure - JDK**
Scroll down  and search for **JDK** and `JDK installations`

Click on `Add JDK`

Enter or select the following:

- Name -----------------------------> jdk11

- Install automatically ------------> ✔️

- Add Installer --------------------> Install from adoptium.net

- Version --------------------------> jdk-11.0.19+7


**Procedure - Docker**
Scroll down  and search for **Docker** and `Docker installations`

Click on `Add Docker`

Enter or select the following:

- Name -----------------------------> docker

- Install automatically ------------> ✔️

- Add Installer --------------------> Download from docker.com

- Docker version --------------------------> latest

Click on `Apply` to save configuration.

Note, we'll need to also configure global tools for Trivy and Ansible.

-----


## Pipeline Setup with Jenkinsfile

Jenkins Pipeline is a suite of plugins which supports implementing and integrating continuous delivery pipelines into Jenkins.

A continuous delivery (CD) pipeline is an automated expression of our process for getting the monitoring scripts from Gogs right through to our remote hosts.

Every change committed in source control goes through a repeated and reliable process on its way to being released.

The pipeline block below defines all the work done throughout our entire Pipeline.

```text

pipeline {
    agent any
    tools{
        jdk 'jdk11'
    }
    environment{
        SCANNER_HOME= tool 'sonar-scanner'
        TRIVY_SCRIPT_PATH="/opt/gogs/server-health-monitoring/trivy"
        ANSIBLE_DEPLOY_SCRIPT_PATH="/opt/gogs/server-health-monitoring/deploy_bundle/deploy_bundle.yml"    
        ANSIBLE_VAULT_PATH="\"@/server-health-monitoring/ansible-vault/values.yml\""
}


    stages {
        stage('Git Checkout') {
            steps {
                //
            }
        }
         stage('SonarQube Scan') {
            steps {
                withSonarQubeEnv('sonar-server'){
                    sh '''$SCANNER_HOME/bin/sonar-scanner -Dsonar.projectName=Server-Health-Monitoring \ 
                    -Dsonar.java.binaries=. \
                    -Dsonar.projectKey=Server-Health-Monitoring'''
                }    
            }
        }
        stage('Trivy Vulnerability Scan') {
            steps {
                sh "sudo bash $TRIVY_SCRIPT_PATH/trivy_repo_scan.sh"    
            }
        }
        stage('Ansible Deployment') {
            steps {
                sh "ansible-playbook --inventory hosts.inventory  $ANSIBLE_DEPLOY_SCRIPT_PATH -e $ANSIBLE_VAULT_PATH"     
            }
        }
    }
    post {
        always {
            archiveArtifacts artifacts: "trivy_report_*.html", fingerprint: true
                
            publishHTML (target: [
                allowMissing: false,
                alwaysLinkToLastBuild: false,
                keepAll: true,
                reportDir: '.',
                reportFiles: 'trivy_report_*.html',
                reportName: 'Trivy Scan',
                ])
            }
        }
}
```

When all SAST scans are passed, the Ansible Deployment stage will proceed to setup cron jobs for health monitoring scripts in remote hosts.


**SAST Reports**

To view reports generated by SonarQube:

- Browse to `192.168.10.1:9000` and click on **Projects** tab.

- Select project we created in pipeline script `Server-Monitoring`

- View bugs, vulnerabilities, code smells, duplications and hotspots reviews.


To view scan reports from Trivy:

- Select pipeline job created

- Scroll down and click on 'Trivy Scan' tab on the left bar

- View vulnerabilities found with different severity levels.


-----

## Jenkins Slave Setup(Optional)

We'll use this node `cs2` to run Sonarqube with Docker and implement test pipeline.

Login to `cs2` node with 192.168.10.6 assigned as its IPv4 address in Vagrantfile.
```bash
vagrant ssh cs2
```

Switch to root user
```bash
su -
```

Install Java 
```bash
sudo yum install fontconfig java-17-openjdk
```

Make root working directory for Jenkins
```bash
cd ~
sudo mkdir jenkins-slave
```

Change permissions of directory
```bash
sudo chmod 755 ~/jenkins-slave
```

Generate RSA key pair
```bash
ssh-keygen
```

Select the defaults for all three prompts by hitting the Enter key at each prompt.

Note two files `id_rsa` and `id_rsa.pub` — corresponding to the private and public keys, respectively in `~/.ssh/` directory.

Private key `id_rsa` should never be shared.

View the contents of the public key
```bash
~/.ssh/id_rsa.pub
```

Copy public key to `authorized_key`
```bash
cat id_rsa.pub >> ~/.ssh/authorized_key
```

View the contents of the private key
```bash
~/.ssh/id_rsa
```

Copy content of private key.

Go to `Jenkins` dashboard and select `Manage Jenkins`.

Under this section, select `Credentials`

Click on `(global)` domain of jenkins `System` store

Next, click on blue button `+ Add Credentials` at top right

Choose from the dropdown, `SSH Username with private key` as our kind of global credential.

Enter `private-key` as its `Description`

Scroll down to `Username` field and enter `root`

Select radio button `Enter directly` for `Private Key`

Click on `Add` button on the right and paste the copied private key as new secret into input field.

Select `Create` to save credential.


**Add Jenkins Slave Node**

Net, we add `cs2` to agent pool.

Go back to `Manage Jenkins` and select 'Manage Nodes and Clouds`

Click on blue button `+ New Node` 

Enter node name as `Slave-Node` and select Type, `Permanent Agent`

Select `Create`

In the next page shown, fill in the following:

Number of executors ----------> 3

Root root directory ----------> /home/root/jenkins-slave/

Labels -----------------------> slave

Launch method ----------------> Launch agent via SSH

Host -------------------------> 192.168.10.6

Credentials ------------------> root (private-key)

Host Key Verification Strategy --------> Non Verifying Verification Strategy

Availability --------------------------> Keep this agent online as much as possible

Select `Save` 


-----

Enjoy!
