terraform {
  required_version = ">= 1.6.0"

  backend "s3" {
    bucket  = "my-terraform-state-eks-infra"
    key     = "simpleApp/terraform.tfstate"
    region  = "eu-north-1"
    encrypt = true
  }
}
