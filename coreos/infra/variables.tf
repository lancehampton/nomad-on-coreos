variable "target_host" {
  description = "Target host for uCore deployment"
  type        = string
}

variable "target_user" {
  description = "Target user for deployment"
  type        = string
  default     = "core"
}

variable "password_hash" {
  description = "Password hash for target_user (generate with: openssl passwd -6)"
  type        = string
  sensitive   = true
}

variable "ssh_public_key" {
  description = "SSH public key content for target_user"
  type        = string
  sensitive   = true
}
