# Nomad Infrastructure Variables

variable "nomad_address" {
  type        = string
  description = "The IP address or hostname of the Nomad cluster"
}

variable "nomad_region" {
  type        = string
  description = "The Nomad region to target for job deployment"
  default     = "global"
}

variable "nomad_datacenter" {
  type        = string
  description = "The Nomad datacenter to target for job deployment"
  default     = "homelab"
}
