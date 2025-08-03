output "nomad_ui" {
  description = "URL to access the Nomad web UI"
  value       = "http://${var.nomad_address}"
}

output "traefik_dashboard" {
  description = "URL to access the Traefik dashboard"
  value       = "http://nomad-node.local:8080"
}

output "whoami_service" {
  description = "Load balanced whoami service URL"
  value       = "http://whoami.local"
}
