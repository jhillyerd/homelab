job "inbucket" {
  datacenters = ["skynet"]
  type = "service"

  group "backend" {
    count = 1

    # Canary is not compatible with sticky storage.
    # update {
    #   canary = 1
    #   auto_promote = true
    # }

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
        "traefik.http.routers.nomad-http.entrypoints=websecure",
        "traefik.http.routers.nomad-http.rule=Host(`nomad.bytemonkey.org`) && PathPrefix(`/inbucket`)",
        "traefik.http.routers.nomad-http.tls.certresolver=letsencrypt",
      ]

      check {
        name = "Inbucket HTTP Check"
        type = "http"
        path = "/"
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
        image = "inbucket/inbucket:latest"
        ports = ["http", "smtp"]

        volumes = [
          "../alloc/data/inbucket_storage:/storage"
        ]
      }

      env {
        INBUCKET_LOGLEVEL = "warn"
        INBUCKET_WEB_BASEPATH = "/inbucket"
        INBUCKET_STORAGE_RETENTIONPERIOD = "168h"
      }

      resources {
        cpu = 300 # MHz
        memory = 128 # MB
      }

      logs {
        max_files = 10
        max_file_size = 5
      }
    }
  }
}
