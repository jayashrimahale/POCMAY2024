terraform {
  required_providers {
    aws = {
      source  = "hashicorp/aws"
      version = "~>4"
    }
  }
}

provider "aws" {
  profile = "default"
  region  = "ap-south-1"

}

/*provider "vault" {
  address = "http://127.0.0.1:8300"
}

data "vault_generic_secret" "db_credentials" {
  path = "secret/three-tier-db"
}
