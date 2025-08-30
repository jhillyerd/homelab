job "nodered" {
  datacenters = ["skynet"]
  type = "service"

  group "nodered" {
    count = 1

    network {
      mode = "bridge"
      port "http" { to = 1880 }
    }

    volume "data" {
      type = "host"
      source = "nodered-data"
      read_only = false
    }

    service {
      name = "nodered"
      connect {
        sidecar_service {
          proxy {
            upstreams {
              destination_name = "homeassistant-api"
              local_bind_port = 8123
            }
          }
        }
      }
    }

    service {
      name = "nodered-http"
      port = "http"

      tags = [
        "http",
        "traefik.enable=true",
        "traefik.http.routers.nodered-http.entrypoints=websecure",
        "traefik.http.routers.nodered-http.rule=Host(`nodered.bytemonkey.org`)",
        "traefik.http.routers.nodered-http.tls.certresolver=letsencrypt",
      ]

      check {
        name = "HTTP Check"
        type = "http"
        path = "/"
        interval = "10s"
        timeout = "2s"
      }
    }

    task "nodered" {
      driver = "docker"

      config {
        image = "nodered/node-red:4.0.9"
        ports = ["http"]
      }

      volume_mount {
        volume = "data"
        destination = "/data"
        read_only = false
      }

      resources {
        cpu = 200 # MHz
        memory = 256 # MB
        memory_max = 512 # MB
      }

      logs {
        max_files = 10
        max_file_size = 5
      }

      template {
        data = "NODE_RED_CREDENTIAL_SECRET={{key \"secrets/nodered/credential\"}}"
        destination = "nodered.env"
        env = true
      }
    }
  }
}
