pipeline {
    agent any
    
    environment {
        TF_VERSION = '0.15.0' // Set your desired Terraform version here
        AWS_REGION = 'us-east-1' // Replace with your desired AWS region
    }
    
    stages {
        stage('Git Clone') {
            steps {
                git url: 'https://github.com/oladaolu/sec_project_1.git', branch: 'main'
            }
        }
        
        stage('Terraform Provisioning') {
            steps {
                sh 'curl -O https://releases.hashicorp.com/terraform/${TF_VERSION}/terraform_${TF_VERSION}_linux_amd64.zip'
                sh 'unzip terraform_${TF_VERSION}_linux_amd64.zip'
                sh 'chmod +x terraform'
                sh './terraform init'
                sh './terraform apply -auto-approve -var "aws_region=${AWS_REGION}"'
                
                script {
                    // Capture the EC2 public IP/DNS for Ansible dynamic inventory
                    def ec2PublicIP = sh(script: './terraform output ec2_public_ip', returnStdout: true).trim()
                    writeFile file: 'ansible/ec2_public_ip.txt', text: ec2PublicIP
                }
            }
        }
        
        stage('Ansible Configuration') {
        steps {
            withCredentials([
                [
                    $class: 'AmazonWebServicesCredentialsBinding',
                    credentialsId: 'aws-credentials', // Make sure this matches the ID
                    accessKeyVariable: 'AWS_ACCESS_KEY_ID',
                    secretKeyVariable: 'AWS_SECRET_ACCESS_KEY'
                ]
            ]) {
                sh 'ansible-galaxy install -r ansible/requirements.yml'
                ansiblePlaybook playbook: 'ansible/playbook.yml', inventory: 'ansible/ec2_public_ip.txt', colorized: true, extras: "-u ubuntu -e 'ansible_python_interpreter=/usr/bin/python3'"
            }
        }
    }

        
        stage('Helm Deployment') {
            steps {
                sh 'helm repo add SonarSource https://SonarSource.github.io/helm-chart-sonarqube'
                sh 'helm repo update'
                sh 'helm upgrade --install sonarqube SonarSource/sonarqube'
            }
        }
    }
    
    post {
        always {
            cleanWs()
        }
    }
}
