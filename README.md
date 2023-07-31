# README: Deployment Automation with Jenkins Pipeline

This README document provides step-by-step instructions on how to set up an automated deployment pipeline using Jenkins, Terraform, Ansible, and Helm to provision an EC2 instance on AWS, configure MicroK8s on the instance, and deploy SonarQube on the MicroK8s cluster. We will go through the code snippets to understand each component and its role in the deployment process. Please follow the pre-requisites and steps below to run the pipeline successfully.

## Pre-requisites

1. Jenkins Server: Ensure you have a Jenkins server up and running to execute the pipeline.
2. AWS IAM User: Create an IAM user in AWS with the necessary permissions to create EC2 instances and security groups. Obtain the `AWS_ACCESS_KEY_ID` and `AWS_SECRET_ACCESS_KEY` for this user.
3. SSH Key Pair: Generate an SSH key pair and add the public key to your AWS account. Save the private key (`security_compass_key.pem`) securely on your Jenkins server.
4. Helm: Install Helm on your Jenkins server to deploy SonarQube to the MicroK8s cluster.
5. Ansible: Install Ansible on your Jenkins server to configure the EC2 instance and set up MicroK8s.

## Jenkins Pipeline Configuration

1. Open your Jenkins web interface and create a new pipeline job.
2. In the pipeline configuration, specify the Git repository URL where this project's Jenkinsfile is located (e.g., https://github.com/your_username/your_repo.git).
3. Configure the credentials in Jenkins for AWS (`aws-credentials`) and the SSH key (`My_SSH_Credentials`) used for the EC2 instance.
4. Save the pipeline configuration.

## Pipeline Execution

1. When you trigger the Jenkins pipeline, it will start executing the following stages:

### Stage 1: Git Clone
This stage will clone the Git repository containing the Terraform configuration, Ansible playbook, and Helm chart. We use `git` step in the Jenkinsfile to fetch the required files from the repository.

### Stage 2: Configure AWS CLI
This stage will configure the AWS CLI on the Jenkins server with the provided AWS credentials. We use `withCredentials` block to securely access and set AWS credentials.

### Stage 3: Terraform Provisioning
This stage will use Terraform to provision an EC2 instance on AWS. The instance will meet the specified requirements, including Ubuntu 18.04 LTS, t2.large instance type, and an appropriate security group. We define the EC2 instance configuration in the `main.tf` Terraform file.

### Stage 4: Ansible Configuration
This stage will use Ansible to configure the provisioned EC2 instance and set up MicroK8s on it. It will install necessary packages, dependencies, and MicroK8s. The `playbook.yml` Ansible playbook defines the tasks required for configuration. Here's an explanation of some tasks:

- `Update apt cache`: This task uses the Ansible `apt` module to update the package cache on the EC2 instance, ensuring the latest packages are available.

- `Install required packages`: This task uses the Ansible `apt` module to install required packages, including 'apt-transport-https', 'ca-certificates', 'curl', 'software-properties-common', 'python3', and 'python3-pip'.

- `Install MicroK8s`: This task uses the Ansible `shell` module to execute a series of commands in a shell on the remote EC2 instance. It installs MicroK8s using the `snap` package manager and adds the `ubuntu` user to the `microk8s` group.

- `Ensure ~/.kube directory exists`: This task ensures that the `.kube` directory exists in the home directory of the `ubuntu` user.

- `Create Kubernetes config file`: This task uses the Ansible `command` module to run the `microk8s config` command and save the output to `/home/ubuntu/.kube/config` file. It ensures the Kubernetes configuration file is available for the user.

- `Set correct permissions for the config file`: This task sets the appropriate permissions (mode 0600) for the Kubernetes configuration file to restrict access to the user.

- `Wait for MicroK8s to start`: This task uses the Ansible `shell` module to run the `microk8s status --wait-ready` command, waiting for MicroK8s to be ready.

- `Access Kubernetes`: This task uses the Ansible `shell` module to run the `microk8s kubectl get nodes` command, verifying the connection to the Kubernetes cluster.

- `Enable MicroK8s addons`: This task uses the Ansible `shell` module to run the `microk8s enable dns storage ingress` command to enable necessary MicroK8s addons.

- `Create .bash_aliases file if not exist`: This task ensures that the `.bash_aliases` file exists in the home directory of the `ubuntu` user.

- `Add kubectl alias`: This task uses the Ansible `lineinfile` module to add an alias for `kubectl` in the `.bash_aliases` file, making it easier to use `microk8s kubectl` as `kubectl`.

### Stage 5: Helm Deploy SonarQube
This stage will use Helm to deploy SonarQube on the MicroK8s cluster. It will add the SonarQube Helm repository, update the repository, and deploy SonarQube with the specified configurations. SonarQube will be exposed on port 80 via an ingress. We execute these steps using shell commands in Jenkins.

2. The pipeline will handle any errors encountered during execution and display appropriate messages or notifications.

## Assumptions

1. The Jenkins server has access to the required AWS resources (e.g., VPC, subnet, IAM roles).
2. The Jenkins server has the necessary permissions to execute Terraform, Ansible, and Helm commands on the remote instances and Kubernetes cluster.
3. The provided Terraform configuration, Ansible playbook, and Helm chart are tested and working correctly.
4. The specified AWS region (`us-east-1`) is appropriate for your deployment. If not, modify the `AWS_DEFAULT_REGION` in the Jenkinsfile accordingly.

## Important Notes

1. Ensure that you have taken the necessary security measures to protect sensitive information like AWS credentials and SSH keys.
2. Test the pipeline in a controlled environment before deploying to production to avoid any unintended consequences.

## Conclusion

Following the steps and pre-requisites mentioned in this README will enable you to set up an automated deployment pipeline using Jenkins, Terraform, Ansible, and Helm. This pipeline will provision an EC2 instance, configure MicroK8s, and deploy SonarQube on the MicroK8s cluster.

Happy deploying!
