# simpleAppInfraCode

This repository contains Terraform code for setting up a basic infrastructure on AWS using Amazon Elastic Kubernetes Service (EKS) to run a Node.js application in a containerized environment.

## Table of Contents
- [Overview](#overview)
- [Prerequisites](#prerequisites)
- [Setup Instructions](#setup-instructions)
- [Configuration Files](#configuration-files)
- [Infrastructure Diagram](#infrastructure-diagram)
- [Improvements with Terragrunt and ArgoCD](#improvements-with-terragrunt-and-argocd)
- [Cleanup](#cleanup)

## Overview

The infrastructure setup involves:

+ Provisioning a Virtual Private Cloud (VPC) and security groups on AWS.
+ Configuring Amazon EKS to orchestrate containerized applications.
+ Managing resources and configurations via Terraform for automation and consistency.

## Prerequisites

Ensure the following tools are installed and properly configured:

+ **AWS CLI**: Configure it with the necessary permissions to access AWS resources.
+ **Terraform**: To define and manage the infrastructure resources.
+ **Terragrunt**: For managing Terraform configurations across environments.
+ **kubectl**: For interacting with the EKS cluster.

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

3. Initialize and apply Terragrunt:

```bash
terragrunt init
terragrunt plan
terragrunt apply
```

Note: Review the output for any important details, including the URL to access your EKS cluster and other relevant resource identifiers, and enter "yes" to confirm.

4. Deploy to EKS: Use kubectl to apply your Kubernetes configurations for deploying the app. Ensure the correct directory for your YAML files:

```bash
kubectl apply -f kubernets/    # Ensure the path is correct
```

## Configuration Files

+ `main.tf`: Core Terraform script to set up the AWS environment.
+ `variables.tf`: Contains configurable variables for easy customization.
+ `outputs.tf`: Defines outputs to be displayed after terraform apply.
+ `terragrunt.hcl`: Manages Terraform configurations and remote state.
+ `buildspec.yaml`: Specifies build instructions, including placeholders for AWS account numbers.

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

## Improvements with Terragrunt and ArgoCD

### Terragrunt
Terragrunt is used to manage Terraform configurations across environments. It provides the following benefits:

- **DRY (Don't Repeat Yourself) configurations**: Reuse common Terraform code across environments.
- **Remote state management**: Automatically configure and manage remote state.
- **Dependency management**: Handle dependencies between Terraform modules.

The Terragrunt configuration is defined in `terragrunt.hcl` and includes:
- Input variables for the infrastructure
- Remote state configuration for S3 backend
- Module dependencies

### Modular Architecture
The infrastructure is organized into reusable modules:

- **VPC Module**: Creates the networking infrastructure including VPC, subnets, and routing.
- **EKS Module**: Sets up the Kubernetes cluster and node groups.

This modular approach allows for:
- Better code organization
- Reusability across environments
- Easier maintenance and updates

### ArgoCD
ArgoCD is used to automate the deployment of Kubernetes manifests. The ArgoCD application is defined in `kubernets/argocd-application.yaml`.

To apply the ArgoCD application:
```bash
kubectl apply -f kubernets/argocd-application.yaml
```

## Cleanup

To destroy the infrastructure and avoid incurring charges:

```bash
terragrunt destroy
```

Review the output and enter "yes" to confirm the destruction of resources.
