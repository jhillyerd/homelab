job "homeassistant" {
  datacenters = [ "skynet" ]
  type = "service"

  constraint {
    attribute = "${attr.kernel.name}"
    value = "linux"
  }

  constraint {
    attribute = "${attr.kernel.arch}"
    value = "x86_64"
  }

  group "homeassistant" {
    count = 1

    network {
      mode = "bridge"
      port "http" { to = "8123" }
      port "sonos" { static = "1400" }
    }

    service {
      name = "homeassistant"
      connect {
        sidecar_service {
          proxy {
            upstreams {
              destination_name = "zwavejs-ws"
              local_bind_port = 3000
            }
          }
        }
      }
    }

    service {
      name = "homeassistant-ui"
      port = "http"
      tags = [
        "traefik",
        "traefik.enable=true",
        "traefik.http.routers.homeassistant-ui.entrypoints=websecure",
        "traefik.http.routers.homeassistant-ui.rule=Host(`homeassistant.bytemonkey.org`)",
        "traefik.http.routers.homeassistant-ui.tls.certresolver=letsencrypt",
      ]
    }

    volume "homeassistant-data" {
      type = "host"
      read_only = false
      source = "homeassistant-data"
    }

    task "homeassistant" {
      driver = "docker"

      config {
        image = "homeassistant/home-assistant:2023.12.4"
        ports = [ "http", "sonos" ]
      }

      env {
        TZ = "America/Los_Angeles"
      }

      volume_mount {
        volume = "homeassistant-data"
        destination = "/config"
        read_only = false
      }

      resources {
        cpu = 300 # MHz
        memory = 700 # MB
      }
    }
  }
}
