pipeline {
    agent any

    environment {
        AWS_DEFAULT_REGION = 'us-east-1' // Replace 'us-east-1' with your desired AWS region
    }

    stages {
        stage('Git Clone') {
            steps {
                git url: 'https://github.com/oladaolu/sec_project_1.git', branch: 'main'
            }
        }

        stage('Configure AWS CLI') {
            steps {
                withCredentials([
                    [
                        $class: 'AmazonWebServicesCredentialsBinding',
                        credentialsId: 'aws-credentials',
                        accessKeyVariable: 'AWS_ACCESS_KEY_ID',
                        secretKeyVariable: 'AWS_SECRET_ACCESS_KEY'
                    ]
                ]) {
                    sh 'aws configure set aws_access_key_id $AWS_ACCESS_KEY_ID'
                    sh 'aws configure set aws_secret_access_key $AWS_SECRET_ACCESS_KEY'
                    sh "aws configure set region ${AWS_DEFAULT_REGION}"
                }
            }
        }

        stage('Terraform Provisioning') {
            steps {
                sh 'terraform init'
                sh 'terraform apply -auto-approve'
            }
        }

        stage('Ansible Configuration') {
            steps {
                withCredentials([sshUserPrivateKey(credentialsId: 'My_SSH_Credentials', keyFileVariable: 'SSH_KEY')]) {
                // sh "ssh -i /home/ubuntu/.ssh/security_compass_key.pem ubuntu@44.203.170.242"
                // Wait for 30 seconds before running the Ansible playbook
                // sleep 300
                sh 'ansible-galaxy install -r requirements.yml'
                ansiblePlaybook playbook: 'playbook.yml', inventory: 'inventory.yml', colorized: true, extras: "-u ubuntu -e 'ansible_python_interpreter=/usr/bin/python3' --private-key=${SSH_KEY}"
                }
            }
        }

        stage('Helm Deploy SonarQube') {
            steps {
                sh 'helm repo add bitnami https://charts.bitnami.com/bitnami'
                // sh 'helm repo add sonarqube https://SonarSource.github.io/helm-chart-sonarqube'
                sh 'helm repo update'
                // sh 'kubectl create namespace sonarqube'
                sh 'helm upgrade --install my-sonarqube sonarqube/sonarqube --set sonar.web.port=80'
            }
        }
    }

    // post {
    //     always {
    //         sh 'terraform destroy -auto-approve'
    //     }
    // }
}
