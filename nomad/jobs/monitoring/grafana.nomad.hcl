job "grafana" {
  datacenters = ["homelab"]
  type = "service"

  group "grafana" {
    count = 1

    network {
      port "grafana_ui" {
        static = 3000
      }
    }

    service {
      name = "grafana"
      port = "grafana_ui"

      check {
        type     = "http"
        path     = "/api/health"
        interval = "10s"
        timeout  = "3s"
      }
    }

    task "grafana" {
      driver = "podman"

      config {
        image = "docker.io/grafana/grafana:latest"
        ports = ["grafana_ui"]
        volumes = [
          "local/grafana.ini:/etc/grafana/grafana.ini"
        ]
      }

      env {
        GF_SECURITY_ADMIN_PASSWORD = "admin"
        GF_USERS_ALLOW_SIGN_UP = "false"
      }

      template {
        data = <<EOF
[server]
http_port = 3000

[security]
admin_user = admin

[users]
allow_sign_up = false

[auth.anonymous]
enabled = false
EOF
        destination = "local/grafana.ini"
      }

      resources {
        cpu    = 500
        memory = 512
      }
    }
  }
}
