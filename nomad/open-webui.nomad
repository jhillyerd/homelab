job "open-webui" {
  datacenters = ["skynet"]
  type = "service"

  group "open-webui" {
    count = 1

    update {
      canary = 0
      auto_promote = false
      auto_revert = true
      healthy_deadline = "10m"
      progress_deadline = "15m"
    }

    network {
      port "http" { to = 8080 }
    }

    service {
      name = "open-webui"
      port = "http"

      tags = [
        "http",
        "traefik.enable=true",
        "traefik.http.routers.open-webui.entrypoints=websecure",
        "traefik.http.routers.open-webui.rule=Host(`openwebui.bytemonkey.org`)",
        "traefik.http.routers.open-webui.tls.certresolver=letsencrypt",
      ]

      check {
        name = "Open WebUI HTTP Check"
        type = "http"
        path = "/health"
        interval = "10s"
        timeout = "2s"
      }
    }

    task "open-webui" {
      driver = "docker"

      config {
        image = "ghcr.io/open-webui/open-webui:v0.8.3"
        ports = ["http"]

        mount {
          type     = "bind"
          source   = "/mnt/nomad-volumes/open-webui/data"
          target   = "/app/backend/data"
          readonly = false
        }
      }

      env {
        WEBUI_URL = "https://openwebui.bytemonkey.org"
        PORT = "8080"
        MODELS_CACHE_TTL = "60"
        USE_OLLAMA_DOCKER = "false"
        WEBUI_SESSION_COOKIE_SECURE = "true"
        WEBUI_SECRET_KEY = "change_this_if_external_20250105"
      }

      resources {
        cpu = 2000 # MHz
        memory = 2048 # MB
      }

      logs {
        max_files = 10
        max_file_size = 15
      }
    }
  }
}
