output "ignition_config" {
  description = "Rendered Ignition configuration"
  value       = data.ct_config.ignition.rendered
  sensitive   = false
}
