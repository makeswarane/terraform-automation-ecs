terraform {
  backend "s3" {
    bucket         = "piedpipers-tf-state"      # your bucket
    key            = "infra/terraform.tfstate"  # path inside bucket
    region         = "ap-south-1"
    dynamodb_table = "piedpipers-tf-lock"       # or remove if you didn't create it
    encrypt        = true
  }
}
