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

        mount = {
          type     = "bind"
          source   = "/mnt/nomad-volumes/syncthing"
          target   = "/var/syncthing"
          readonly = false
        }
      }

      env {
        PUID = 3003
        PGID = 3003
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
