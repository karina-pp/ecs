terraform {
  backend "s3" {
    bucket = "bucket-karina-training"
    key    = "terraform.tfstate"
    region = "eu-west-1"
  }
}

