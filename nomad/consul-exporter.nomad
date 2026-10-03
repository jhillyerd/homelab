job "consul-exporter" {
  datacenters = ["skynet"]
  type = "service"

  constraint {
    attribute = "${attr.kernel.name}"
    value     = "linux"
  }

  group "exporter" {
    count = 1

    network {
      mode = "host"

      # Static so Prometheus can target consul-exporter.service.consul:9107.
      port "http" {
        static = 9107
        to     = 9107
      }
    }

    consul {
      # Use server default task identity.
    }

    service {
      name = "consul-exporter"
      port = "http"

      check {
        name     = "consul-exporter metrics"
        type     = "http"
        path     = "/metrics"
        interval = "30s"
        timeout  = "3s"
      }
    }

    task "exporter" {
      driver = "docker"

      config {
        image = "prom/consul-exporter:v0.13.0"
        ports = ["http"]

        args = [
          # Consul server via DNS (round-robins the 3 servers, works from any
          # nomad client regardless of local consul agent); allow_stale keeps
          # catalog reads cheap.
          "--consul.server=http://consul.service.consul:8500",
          "--consul.allow_stale",
        ]
      }

      # Read-only agent/node/service token, see consul/consul-metrics-policy.hcl.
      template {
        data        = <<EOT
CONSUL_HTTP_TOKEN={{ with nomadVar "nomad/jobs/consul-exporter" }}{{ .token }}{{ end }}
EOT
        destination = "secrets/env"
        env         = true
      }

      logs {
        max_files     = 5
        max_file_size = 10
      }

      resources {
        cpu    = 100 # MHz
        memory = 64 # MB
      }
    }
  }
}
