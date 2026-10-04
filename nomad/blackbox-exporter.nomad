# NFS path monitoring: ICMP + TCP probes from every nomad client to the
# NAS (mininas) and the gateway, scraped by Prometheus on the metrics host
# via /probe. See nfs-path-monitoring-plan in jhillyerd/planning.
#
# quirk: quay.io is not mirrored, so the tag is pinned and bumped by hand.
job "blackbox-exporter" {
  datacenters = ["skynet"]
  type        = "system"

  constraint {
    attribute = "${attr.kernel.name}"
    value     = "linux"
  }

  constraint {
    attribute = "${attr.kernel.arch}"
    value     = "x86_64"
  }

  group "exporter" {
    network {
      mode = "host"

      # Static so Prometheus can target each client via consul DNS:
      # blackbox-exporter.service.consul:9115.
      port "http" {
        static = 9115
        to     = 9115
      }
    }

    service {
      name = "blackbox-exporter"
      port = "http"

      check {
        name     = "blackbox-exporter metrics"
        type     = "http"
        path     = "/metrics"
        interval = "30s"
        timeout  = "3s"
      }
    }

    task "exporter" {
      driver = "docker"

      config {
        image = "quay.io/prometheus/blackbox-exporter:v0.28.0"
        ports = ["http"]

        # ICMP probes need raw sockets; net_raw is already in the docker
        # driver capability allowlist (roles/nomad.nix).
        cap_add = ["NET_RAW"]

        mount {
          type     = "bind"
          source   = "secrets/blackbox.yml"
          target   = "/etc/blackbox_exporter/config.yml"
          readonly = true
        }
      }

      template {
        data = <<EOT
modules:
  # Measure loss/RTT from each client to the NAS. If the gateway target
  # degrades the same way, the problem is client->router; if only the NAS
  # target degrades, it is the router->NAS segment or the NAS itself.
  icmp:
    prober: icmp
    icmp:
      preferred_ip_protocol: ip4
      ip_protocol_fallback: false

  # TCP connect to the nfsd port catches thread starvation that leaves
  # ICMP clean.
  tcp_connect:
    prober: tcp
    tcp:
      preferred_ip_protocol: ip4
      ip_protocol_fallback: false
EOT
        destination = "secrets/blackbox.yml"
      }

      resources {
        cpu    = 100 # MHz
        memory = 64 # MB
      }

      logs {
        max_files     = 5
        max_file_size = 10
      }
    }
  }
}
