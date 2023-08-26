terraform {
  backend "s3" {
    bucket         = "my-terraform-state-bucket-offsetmax"
    key            = "eks-test-Graphql-db-dev/terraform.tfstate"
    region         = "ap-south-1"
      
  }
}
