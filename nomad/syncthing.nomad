job "syncthing" {
  datacenters = ["skynet"]
  type = "service"

  group "syncthing" {
    count = 1

    update {
      canary = 0
      auto_promote = false
      auto_revert = true
      healthy_deadline = "2m"
      progress_deadline = "5m"
    }

    network {
      mode = "bridge"
      port "http" { to = 8384 }
      port "discovery" { static = 21027 }
      port "sync" { static = 22000 }
    }

    volume "syncthing" {
      type = "host"
      source = "syncthing-data"
      read_only = false
    }

    service {
      name = "syncthing-http"
      port = "http"

      tags = [
        "http",
        "traefik.enable=true",
        "traefik.http.routers.syncthing-http.entrypoints=websecure",
        "traefik.http.routers.syncthing-http.rule=Host(`syncthing.bytemonkey.org`)",
        "traefik.http.routers.syncthing-http.tls.certresolver=letsencrypt",
      ]

      check {
        name = "Syncthing HTTP Check"
        type = "http"
        path = "/rest/noauth/health"
        interval = "10s"
        timeout = "2s"
      }
    }

    task "syncthing" {
      driver = "docker"

      config {
        image = "ghcr.io/syncthing/syncthing:1.29.3"
        ports = ["http", "discovery", "sync"]
      }

      volume_mount {
        volume = "syncthing"
        destination = "/var/syncthing"
        read_only = false
      }

      env {
        PUID = 1024
        PGID = 1000
      }

      resources {
        cpu = 500 # MHz
        memory = 128 # MB
      }

      logs {
        max_files = 10
        max_file_size = 5
      }
    }
  }
}
