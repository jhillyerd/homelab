job "bifrost" {
  datacenters = ["skynet"]
  type        = "service"

  group "bifrost" {
    count = 1

    update {
      canary            = 0
      auto_promote      = false
      auto_revert       = true
      healthy_deadline  = "10m"
      progress_deadline = "15m"
    }

    network {
      mode = "host"
      port "http" { to = 8080 }
    }

    service {
      name = "bifrost"
      port = "http"

      tags = [
        "http",
        "traefik.enable=true",
        "traefik.http.routers.bifrost.entrypoints=websecure",
        "traefik.http.routers.bifrost.rule=Host(`bifrost.bytemonkey.org`)",
        "traefik.http.routers.bifrost.tls.certresolver=letsencrypt",
      ]

      # NOTE: /health pings bifrost's SQLite DBs, which live on the NFS
      # export from mininas. NAS-side periodic tasks can stall those pings for
      # tens of seconds while the app itself keeps serving traffic. A single
      # failed probe flips the Consul check critical, and Traefik's
      # consul-catalog provider then drops the whole router (hard 404s).
      # Debounce with failures_before_critical + a generous probe timeout.
      check {
        name     = "Bifrost HTTP Check"
        type     = "http"
        path     = "/health"
        interval = "30s"
        timeout  = "10s"

        failures_before_critical = 4
      }
    }

    task "bifrost" {
      driver = "docker"

      # The image runs as UID 1000 by default; the NFS-backed volume is owned
      # by 3003:3003 (the shared service UID/GID used across /mnt/nomad-volumes).
      user = "3003"

      config {
        image = "maximhq/bifrost:v2.1.0"
        ports = ["http"]

        # Bifrost stores its config (config.db), request logs (logs.db) and
        # optional config.json in its app-dir. The mounted volume becomes the
        # app-dir, keeping provider API keys and settings across restarts.
        # Everything is configured via the Web UI after first boot.
        #
        # Note: provider base URLs are the bare origin (e.g.
        # http://dgx1.home.arpa:8000) — do NOT include /v1, Bifrost appends
        # API paths itself (unlike OpenAI SDK base-URL conventions).
        mount {
          type     = "bind"
          source   = "/mnt/nomad-volumes/bifrost"
          target   = "/app/data"
          readonly = false
        }
      }

      resources {
        cpu    = 500  # MHz
        memory = 512  # MB
      }

      # Bootstrap token for creating the initial admin account in the Web UI.
      # Store it with: nomad var put nomad/jobs/bifrost setup_token=<token>
      template {
        data        = "BIFROST_SETUP_TOKEN={{ with nomadVar \"nomad/jobs/bifrost\" }}{{ .setup_token }}{{ end }}"
        destination = "secrets/bifrost.env"
        env         = true
      }

      logs {
        max_files     = 10
        max_file_size = 5
      }
    }
  }
}
