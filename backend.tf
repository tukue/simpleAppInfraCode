terraform {
  backend "s3" {
    bucket         = "my-terraform-state-eks-infra" # Use the newly created bucket
    key            = "simpleApp/terraform.tfstate"  # Path to the state file in the bucket
    region         = "eu-north-1"                   # Region where the S3 bucket is located
    encrypt        = true                          # Encrypt the state file
  }
}