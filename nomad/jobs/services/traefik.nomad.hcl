job "traefik" {
  datacenters = ["homelab"]
  type = "service"

  group "traefik" {
    count = 1

    network {
      port "http" {
        static = 8080
      }
      port "web" {
        static = 80
      }
    }

    service {
      name = "traefik"
      port = "http"

      check {
        type     = "http"
        path     = "/ping"
        interval = "10s"
        timeout  = "3s"
      }
    }

    task "traefik" {
      driver = "podman"

      config {
        image = "docker.io/traefik:latest"
        ports = ["http", "web"]
        network_mode = "host"
        args = [
          "--api.dashboard=true",
          "--api.insecure=true",
          "--entrypoints.web.address=:80",
          "--entrypoints.traefik.address=:8080",
          "--providers.consulcatalog=true",
          "--providers.consulcatalog.prefix=traefik",
          "--providers.consulcatalog.exposedbydefault=false",
          "--ping=true"
        ]
      }

      resources {
        cpu    = 100
        memory = 128
      }
    }
  }
}
