terraform {
  backend "s3" {
    bucket         = "my-terraform-state-eks-infra" # Use the newly created bucket
    key            = "simpleApp/terraform.tfstate" # Path to the state file in the bucket
    region         = var.region                    # Read the region from the variable
    encrypt        = true                          # Encrypt the state file
  }
}