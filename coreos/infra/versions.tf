terraform {
  required_version = ">= 1.0"
  required_providers {
    ct = {
      source  = "poseidon/ct"
      version = "~> 0.13.0"
    }
  }
}

provider "ct" {}
