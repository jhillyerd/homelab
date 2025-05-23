job "grafana" {
  datacenters = ["skynet"]
  type = "service"

  constraint {
    attribute = "${attr.kernel.name}"
    value     = "linux"
  }

  group "grafana" {
    count = 1

    network {
      mode = "host"
      port "http" {
        to = 3000
      }
    }

    volume "grafana" {
      type = "host"
      source = "grafana-storage"
      read_only = false
    }

    service {
      name = "grafana"
      port = "http"

      tags = [
        "http",
        "traefik.enable=true",
        "traefik.http.routers.grafana-http.entrypoints=websecure",
        "traefik.http.routers.grafana-http.rule=Host(`grafana.bytemonkey.org`)",
        "traefik.http.routers.grafana-http.tls.certresolver=letsencrypt",
        "traefik.http.routers.grafana-http.middlewares=authelia@file",
        "traefik.http.routers.grafana-xhttp.entrypoints=extweb",
        "traefik.http.routers.grafana-xhttp.rule=Host(`grafana.x.bytemonkey.org`)",
        "traefik.http.routers.grafana-xhttp.tls.certresolver=letsencrypt",
        "traefik.http.routers.grafana-xhttp.middlewares=authelia@file",
      ]

      check {
        name = "Grafana HTTP Check"
        type = "http"
        path = "/"
        interval = "10s"
        timeout  = "2s"
      }
    }

    task "grafana" {
      driver = "docker"

      config {
        image = "grafana/grafana-oss:11.3.4"
        ports = ["http"]
      }

      volume_mount {
        volume = "grafana"
        destination = "/var/lib/grafana"
        read_only = false
      }

      logs {
        max_files     = 10
        max_file_size = 15
      }

      resources {
        cpu    = 1000 # MHz
        memory = 512 # MB
      }

      env {
        GF_SERVER_ROOT_URL = "https://grafana.bytemonkey.org/"
        GF_LOG_LEVEL = "info"
        GF_LOG_MODE = "console"
        GF_PATHS_PROVISIONING = "/local/grafana/provisioning"
        GF_AUTH_PROXY_ENABLED = "true"
        GF_AUTH_PROXY_HEADER_NAME = "Remote-User"
        GF_AUTH_PROXY_HEADERS = "Email:Remote-Email,Name:Remote-Name"
        GF_AUTH_PROXY_WHITELIST = "192.168.128.11"
      }

      template {
        data = <<EOT
apiVersion: 1
datasources:
  - name: homeassistant influxdb
    type: influxdb
    database: homeassistant
    url: http://metrics.home.arpa:8086
    user: homeassistant
    secureJsonData:
      password: "{{key "secrets/influxdb/homeassistant"}}"

  - name: telegraf-hosts influxdb
    type: influxdb
    database: telegraf-hosts
    url: http://metrics.home.arpa:8086
    user: telegraf
    secureJsonData:
      password: "{{key "secrets/influxdb/telegraf"}}"

  - name: "syslogs loki"
    type: loki
    access: proxy
    url: "http://metrics.home.arpa:3100"
    jsonData:
      maxLines: 1000
EOT

        destination = "/local/grafana/provisioning/datasources/datasources.yml"
      }
    }
  }
}
