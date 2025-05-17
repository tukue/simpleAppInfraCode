# simpleAppInfraCode

This repository contains Terraform code for setting up a basic infrastructure on AWS using Amazon Elastic Kubernetes Service (EKS) to run a Node.js application in a containerized environment.

## Table of Contents
- [Overview](#overview)
- [Prerequisites](#prerequisites)
- [Setup Instructions](#setup-instructions)
- [Configuration Files](#configuration-files)
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



