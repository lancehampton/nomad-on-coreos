job "whoami" {
  datacenters = ["${datacenter}"]
  type = "service"

  group "demo" {
    count = 2

    network {
      port "http" {
        to = 80
      }
    }

    service {
      name = "whoami"
      port = "http"

      tags = [
        "traefik.enable=true",
        "traefik.http.routers.whoami.rule=Host(`whoami.local`)",
      ]

      check {
        type     = "http"
        path     = "/"
        interval = "10s"
        timeout  = "3s"
      }
    }

    task "server" {
      driver = "podman"

      config {
        image = "docker.io/traefik/whoami:latest"
        ports = ["http"]
      }

      resources {
        cpu    = 50
        memory = 64
      }
    }
  }
}
