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
      name = "homeassistant-api"
      port = "http"

      # Allows sidecar to connect.
      address_mode = "alloc"
      connect {
        sidecar_service {
          proxy {
            upstreams {
              destination_name = "piper-wyoming"
              local_bind_port = 10200
            }
            upstreams {
              destination_name = "whisper-wyoming"
              local_bind_port = 10300
            }
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
        image = "homeassistant/home-assistant:2024.9.3"
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

  group "piper" {
    count = 1

    network {
      mode = "bridge"
    }

    volume "piper-data" {
      type = "host"
      read_only = false
      source = "piper-data"
    }

    service {
      name = "piper-wyoming"
      port = 10200

      tags = ["wyoming"]

      # Allows sidecar to connect.
      address_mode = "alloc"
      connect {
        sidecar_service {}
      }

      # TCP checks are not valid for connect services.
    }

    task "piper" {
      driver = "docker"

      config {
        image = "lscr.io/linuxserver/piper:1.4.0"
        ports = [ 10200 ]
      }

      env {
        PUID = 1024
        PGID = 1000
        TZ = "America/Los_Angeles"
        PIPER_VOICE = "en_US-ryan-medium"
      }

      volume_mount {
        volume = "piper-data"
        destination = "/config"
        read_only = false
      }

      resources {
        cpu = 2000 # MHz
        memory = 200 # MB
      }
    }
  }

  group "whisper" {
    count = 1

    network {
      mode = "bridge"
    }

    volume "whisper-data" {
      type = "host"
      read_only = false
      source = "whisper-data"
    }

    service {
      name = "whisper-wyoming"
      port = 10300

      tags = ["wyoming"]

      # Allows sidecar to connect.
      address_mode = "alloc"
      connect {
        sidecar_service {}
      }

      # TCP checks are not valid for connect services.
    }

    task "faster-whisper" {
      driver = "docker"

      config {
        image = "linuxserver/faster-whisper:2.0.0"
        ports = [ 10300 ]
      }

      env {
        PUID = 1024
        PGID = 1000
        TZ = "America/Los_Angeles"
        WHISPER_MODEL = "tiny"
        WHISPER_LANG = "en"
        #WHISPER_BEAM = 5
      }

      volume_mount {
        volume = "whisper-data"
        destination = "/config"
        read_only = false
      }

      resources {
        cpu = 8000 # MHz
        memory = 1000 # MB
      }
    }
  }
}
