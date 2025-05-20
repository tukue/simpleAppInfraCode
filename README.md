# simpleAppInfraCode

This repository contains Terraform code for setting up a basic infrastructure on AWS using Amazon Elastic Kubernetes Service (EKS) to run a Node.js application in a containerized environment.

## Table of Contents
- [Overview](#overview)
- [Prerequisites](#prerequisites)
- [Setup Instructions](#setup-instructions)
- [Configuration Files](#configuration-files)
- [Ansible Integration](#ansible-integration)
- [Cleanup](#cleanup)

## Overview

The infrastructure setup involves:

+ Provisioning a Virtual Private Cloud (VPC) and security groups on AWS.
+ Configuring Amazon EKS to orchestrate containerized applications.
+ Managing resources and configurations via Terraform for automation and consistency.
+ Optional Ansible configuration for EKS worker nodes.

## Prerequisites

Ensure the following tools are installed and properly configured:

+ **AWS CLI**: Configure it with the necessary permissions to access AWS resources.
+ **Terraform**: To define and manage the infrastructure resources.
+ **kubectl**: For interacting with the EKS cluster.
+ **Ansible**: For automated configuration management (optional).

## Setup Instructions   

1. Clone the repository:

```bash
git clone https://github.com/tukue/simpleAppInfraCode.git
cd simpleAppInfraCode
```

2. Configure AWS CLI: Make sure AWS CLI is configured with the correct credentials:

```bash
aws configure
```

3. Initialize Terraform:

```bash
terraform init
```

4. Set up the infrastructure: Apply the Terraform configurations to create the required AWS resources:

```bash
terraform apply
```

Note: Review the output for any important details, including the URL to access your EKS cluster and other relevant resource identifiers, and enter "yes" to confirm.

5. Deploy to EKS: Use kubectl to apply your Kubernetes configurations for deploying the app. Ensure the correct directory for your YAML files:

```bash
kubectl apply -f kubernets/    # Ensure the path is correct
```

## Configuration Files

+ `main.tf`: Core Terraform script to set up the AWS environment.
+ `variables.tf`: Contains configurable variables for easy customization.
+ `outputs.tf`: Defines outputs to be displayed after terraform apply.
+ `buildspec.yaml`: Specifies build instructions, including placeholders for AWS account numbers.
+ `ansible-playbook.yml`: Main Ansible playbook for configuring EKS nodes.
+ `ansible-inventory.tf`: Terraform file to generate Ansible inventory and run the playbook.

## Ansible Integration

This project includes optional Ansible integration for automated configuration of EKS worker nodes. 

### Enabling/Disabling Ansible

To enable or disable Ansible configuration, set the `enable_ansible` variable in your `terraform.tfvars` file:

```hcl
enable_ansible = true  # Set to false to disable Ansible
```

You can also override this setting during apply:

```bash
terraform apply -var="enable_ansible=true"
```

### Configuration Details

When enabled, Ansible will:
- Update all packages on the worker nodes
- Install required packages (Docker, Git, Python, etc.)
- Configure Docker and Kubernetes components
- Set up proper node labels and configurations

## Infrastructure Diagram

```markdown
graph TD
    subgraph AWS
        VPC["VPC"]
        IGW["Internet Gateway"]   
        RT["Route Table"]
        Subnet1["Public Subnet 1"]
        Subnet2["Public Subnet 2"]
        SG["Security Group"]
        EKS["EKS Cluster"]
        NodeGroup["Node Group"]
    end

    VPC --> IGW
    VPC --> RT
    RT --> Subnet1
    RT --> Subnet2
    Subnet1 --> EKS
    Subnet2 --> EKS
    EKS --> SG
    EKS --> NodeGroup
```

## Improvements with ArgoCD and Terragrunt

### ArgoCD
ArgoCD is used to automate the deployment of Kubernetes manifests. The ArgoCD application is defined in `kubernets/argocd-application.yaml`.

To apply the ArgoCD application:
```bash
kubectl apply -f kubernets/argocd-application.yaml
```

## Cleanup

To avoid incurring unnecessary costs, remember to destroy the resources when they are no longer needed:

```bash
terraform destroy
```

Confirm by typing "yes" when prompted.