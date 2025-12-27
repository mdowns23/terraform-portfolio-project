terraform {
    backend "s3" {
        bucket = "md-my-tf-website-state"
        key = "global/s3/terraform.tfstate"
        region = "us-west-2"
        dynamodb_table = "md-my-tf-website-table"
    }
}