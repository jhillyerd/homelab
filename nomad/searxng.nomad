job "searxng" {
  datacenters = ["skynet"]
  type        = "service"

  group "searxng" {
    count = 1

    update {
      canary           = 0
      auto_promote     = false
      auto_revert      = true
      healthy_deadline = "10m"
      progress_deadline = "15m"
    }

    network {
      port "http" { to = 8080 }
    }

    service {
      name = "searxng"
      port = "http"

      tags = [
        "http",
        "traefik.enable=true",
        "traefik.http.routers.searxng.entrypoints=websecure",
        "traefik.http.routers.searxng.rule=Host(`search.bytemonkey.org`)",
        "traefik.http.routers.searxng.tls.certresolver=letsencrypt",
      ]

      check {
        name     = "SearXNG HTTP Check"
        type     = "http"
        path     = "/healthz"
        interval = "10s"
        timeout  = "2s"
      }
    }

    task "searxng" {
      driver = "docker"

      config {
        image = "searxng/searxng:2026.5.9-0cba32c15"
        ports = ["http"]

        # The entrypoint expects /etc/searxng/settings.yml to exist. If it
        # already exists, it leaves it alone. We template into NOMAD_TASK_DIR
        # (i.e. local/) and bind-mount it over the expected path.
        mount {
          type     = "bind"
          source   = "secrets/settings.yml"
          target   = "/etc/searxng/settings.yml"
          readonly = false
        }
      }

      template {
        change_mode = "restart"
        data        = <<EOT
use_default_settings: true

general:
  instance_name: "SearXNG bytemonkey"
  debug: false

search:
  safe_search: 0
  autocomplete: "duckduckgo"
  default_lang: "en"
  formats: ["csv", "html", "json", "rss"]

server:
  secret_key: "{{ with nomadVar "nomad/jobs/searxng" }}{{ .secret_key }}{{ end }}"
  bind_address: "0.0.0.0"
  port: 8080
  limiter: false
  public_instance: false

ui:
  hotkeys: vim
EOT
        destination = "secrets/settings.yml"
      }

      resources {
        cpu    = 500  # MHz
        memory = 512  # MB
      }

      logs {
        max_files     = 10
        max_file_size = 5
      }
    }
  }
}
