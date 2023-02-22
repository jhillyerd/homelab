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
      port "http" { to = "8123" }
    }

    service {
      name = "homeassistant"
      port = "http"
      tags = [
        "traefik",
        "traefik.enable=true",
        "traefik.http.routers.homeassistant.entrypoints=websecure",
        "traefik.http.routers.homeassistant.rule=Host(`homeassistant.bytemonkey.org`)",
        "traefik.http.routers.homeassistant.tls.certresolver=letsencrypt",
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
        image = "homeassistant/home-assistant:2023.2"
        ports = [ "http" ]
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
        cpu = 100 # MHz
        memory = 600 # MB
      }
    }
  }
}
