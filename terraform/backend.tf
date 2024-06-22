terraform {
  backend "s3" {
    bucket         = "my-interncareertask213"
    key            = "terraform.tfstate"
    region         = "ap-south-1"
    access_key = "My_ACCESS_KEY"
    secret_key = "MY_SECRTE_KEY"
  }
}