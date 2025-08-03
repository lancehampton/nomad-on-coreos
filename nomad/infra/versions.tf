terraform {
  required_version = ">= 1.6.0"

  required_providers {
    nomad = {
      source  = "hashicorp/nomad"
      version = "2.5.0"
    }
  }
}

provider "nomad" {
  address = "http://${var.nomad_address}"
  region  = var.nomad_region
}
