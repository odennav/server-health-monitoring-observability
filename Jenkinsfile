
pipeline {
    agent any
    tools{
        jdk 'jdk11'
    }
    environment{
        SCANNER_HOME= tool 'sonar-scanner'
        HEALTH_CHECK_SCRIPTS_PATH="/opt/gogs/server-health-monitoring/health_check_scripts"
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
        stage('Slack Webhook Integration') {
            steps {
                withCredentials([string(credentialsId: 'slack_webhook_url', variable: 'URL')])
                sh "sed -i 's|webhook_url|${URL}|g' $HEALTH_CHECK_SCRIPTS_PATH/*.sh   
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