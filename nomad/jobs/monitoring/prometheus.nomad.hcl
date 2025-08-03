job "prometheus" {
  datacenters = ["homelab"]
  type = "service"

  group "monitoring" {
    count = 1

    network {
      port "prometheus_ui" {
        static = 9090
      }
    }

    service {
      name = "prometheus"
      port = "prometheus_ui"

      check {
        type     = "http"
        path     = "/-/healthy"
        interval = "10s"
        timeout  = "3s"
      }
    }

    task "prometheus" {
      driver = "podman"

      config {
        image = "docker.io/prom/prometheus:latest"
        ports = ["prometheus_ui"]
        volumes = [
          "local/prometheus.yml:/etc/prometheus/prometheus.yml"
        ]
        args = [
          "--config.file=/etc/prometheus/prometheus.yml",
          "--storage.tsdb.path=/prometheus",
          "--web.console.libraries=/etc/prometheus/console_libraries",
          "--web.console.templates=/etc/prometheus/consoles",
          "--web.enable-lifecycle"
        ]
      }

      template {
        data = <<EOF
global:
  scrape_interval: 15s

scrape_configs:
  - job_name: 'prometheus'
    static_configs:
      - targets: ['localhost:9090']

  - job_name: 'nomad'
    consul_sd_configs:
      - server: '{{ env "NOMAD_IP_prometheus_ui" }}:8500'
        services: ['nomad-client', 'nomad']

  - job_name: 'consul'
    static_configs:
      - targets: ['{{ env "NOMAD_IP_prometheus_ui" }}:8500']
EOF
        destination = "local/prometheus.yml"
      }

      resources {
        cpu    = 500
        memory = 256
      }
    }
  }
}
