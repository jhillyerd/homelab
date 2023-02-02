job "inbucket" {
  datacenters = ["skynet"]
  type = "service"

  group "inbucket" {
    count = 1

    update {
      # Canary is not compatible with sticky ephemeral_disk.
      canary = 0
      auto_promote = false
      auto_revert = true
      healthy_deadline = "2m"
      progress_deadline = "5m"
    }

    network {
      port "http" { to = 9000 }
      port "smtp" { to = 2500 }
    }

    service {
      name = "inbucket-http"
      port = "http"

      tags = [
        "http",
        "traefik.enable=true",
        "traefik.http.routers.inbucket-http.entrypoints=websecure",
        "traefik.http.routers.inbucket-http.rule=Host(`inbucket.bytemonkey.org`)",
        "traefik.http.routers.inbucket-http.tls.certresolver=letsencrypt",
      ]

      check {
        name = "Inbucket HTTP Check"
        type = "http"
        path = "/status"
        interval = "10s"
        timeout = "2s"
      }
    }

    service {
      name = "inbucket-smtp"
      port = "smtp"

      tags = [
        "smtp",
        "traefik.enable=true",
        "traefik.tcp.routers.nomad-smtp.rule=HostSNI(`*`)",
        "traefik.tcp.routers.nomad-smtp.entrypoints=smtp",
      ]

      check {
        name = "Inbucket SMTP Check"
        type = "tcp"
        port = "smtp"
        interval = "30s"
        timeout = "2s"
      }
    }

    ephemeral_disk {
      sticky = true
      migrate = true
      size = 150 # MB
    }

    task "inbucket" {
      driver = "docker"

      config {
        # :latest for stable releases, :edge to track development.
        image = "inbucket/inbucket:sha-5d18d79"
        ports = ["http", "smtp"]

        volumes = [
          "../alloc/data/inbucket_storage:/storage"
        ]
      }

      env {
        INBUCKET_LOGLEVEL = "info" # TODO set to warn after lua
        INBUCKET_STORAGE_RETENTIONPERIOD = "168h"
      }

      resources {
        cpu = 200 # MHz
        memory = 48 # MB
      }

      logs {
        max_files = 10
        max_file_size = 5
      }
    }
  }
}
