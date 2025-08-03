# Whoami Demo Service
resource "nomad_job" "whoami" {
  jobspec = templatefile("${path.module}/../jobs/services/whoami.nomad.hcl", {
    datacenter = var.nomad_datacenter
  })

  purge_on_destroy = false
}

# Traefik Load Balancer
resource "nomad_job" "traefik" {
  jobspec = file("${path.module}/../jobs/services/traefik.nomad.hcl")

  purge_on_destroy = false
}

