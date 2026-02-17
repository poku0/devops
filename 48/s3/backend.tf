terraform {
  backend "s3" {
    bucket = "aws-sam-cli-managed-default-samclisourcebucket-hfz5mvmzd4fz"
    key    = "48/terraform.tfstate"
    region = "eu-central-1"
  }
}
