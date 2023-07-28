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
                sh 'ansible-galaxy install -r requirements.yml'
                ansiblePlaybook playbook: 'playbook.yml', inventory: 'ec2.py', colorized: true, extras: "-u ubuntu -e 'ansible_python_interpreter=/usr/bin/python3'"
            }
        }

        stage('Helm Deploy SonarQube') {
            steps {
                sh 'helm repo add stable https://charts.helm.sh/stable'
                sh 'helm repo update'

                sh 'helm install sonarqube stable/sonarqube --set sonar.web.port=80 --set sonar.web.context=/ --set sonar.web.javaOpts="-Xmx512m -Xms128m -XX:+HeapDumpOnOutOfMemoryError" --set postgresql.postgresqlUsername=sonar --set postgresql.postgresqlPassword=sonar --set persistence.storageClass=standard --set ingress.enabled=true'
            }
        }
    }

    post {
        always {
            sh 'terraform destroy -auto-approve'
        }
    }
}
