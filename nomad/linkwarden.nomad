job "linkwarden" {
  datacenters = ["skynet"]
  type = "service"

  group "linkwarden" {
    count = 1

    update {
      # Does DB migrations, so no canary and long deadlines.
      canary = 0
      auto_promote = false
      auto_revert = true
      healthy_deadline = "10m"
      progress_deadline = "15m"
    }

    network {
      port "http" { to = 3000 }
      port "search" { to = 7700 }
      port "ollama" { to = 11434 }
    }

    consul {
      # Use server default task identity.
    }

    service {
      name = "linkwarden-http"
      port = "http"

      tags = [
        "http",
        "traefik.enable=true",
        "traefik.http.routers.linkwarden-http.entrypoints=websecure",
        "traefik.http.routers.linkwarden-http.rule=Host(`links.bytemonkey.org`)",
        "traefik.http.routers.linkwarden-http.tls.certresolver=letsencrypt",
      ]

      check {
        name = "Linkwarden HTTP Check"
        type = "http"
        path = "/"
        interval = "10s"
        timeout = "2s"
      }
    }

    task "linkwarden" {
      driver = "docker"

      config {
        image = "ghcr.io/linkwarden/linkwarden:v2.13.5"
        ports = ["http"]

        mount {
          type     = "bind"
          source   = "/mnt/nomad-volumes/linkwarden/data"
          target   = "/data/data"
          readonly = false
        }
      }

      env {
        NEXTAUTH_URL = "https://links.bytemonkey.org/api/v1/auth"
        MEILI_HOST = "http://${NOMAD_ADDR_search}"

        AUTOSCROLL_TIMEOUT = 120 # Seconds to archive a website
        MONOLITH_MAX_BUFFER = 32 # MB, default is 6

        NEXT_PUBLIC_OLLAMA_ENDPOINT_URL = "http://${NOMAD_ADDR_ollama}"
        OLLAMA_MODEL = "phi3.5:3.8b"
      }

      template {
        change_mode = "restart"
        data = <<EOT
NEXTAUTH_SECRET={{key "secrets/linkwarden/nextauth"}}
DATABASE_URL=postgresql://linkwarden:{{key "secrets/linkwarden/postgres"}}@fastd.home.arpa:5432/linkwarden
MEILI_MASTER_KEY={{key "secrets/linkwarden/meilisearch"}}
EOT
        destination = "secrets/linkwarden.env"
        env = true
      }

      resources {
        cpu = 500 # MHz
        memory = 2048 # MB
      }

      logs {
        max_files = 10
        max_file_size = 5
      }
    }

    service {
      name = "linkwarden-search"
      port = "search"

      check {
        name = "Linkwarden Search Check"
        type = "http"
        path = "/"
        interval = "10s"
        timeout = "2s"
      }
    }

    task "meilisearch" {
      driver = "docker"

      config {
        image = "getmeili/meilisearch:v1.12.8"
        ports = ["search"]
        
        mount {
          type     = "bind"
          source   = "/mnt/nomad-volumes/linkwarden/meilisearch"
          target   = "/meili_data"
          readonly = false
        }
      }

      env {
        MEILI_ENV = "development"
      }

      template {
        change_mode = "restart"
        data = <<EOT
MEILI_MASTER_KEY={{key "secrets/linkwarden/meilisearch"}}
EOT
        destination = "secrets/meilisearch.env"
        env = true
      }

      resources {
        cpu = 500 # MHz
        memory = 1024 # MB
      }

      logs {
        max_files = 10
        max_file_size = 5
      }
    }

    service {
      name = "linkwarden-ollama"
      port = "ollama"

      check {
        name = "Ollama HTTP Check"
        type = "http"
        path = "/"
        interval = "10s"
        timeout = "2s"
      }
    }

    task "ollama" {
      driver = "docker"

      config {
        image = "dockreg.bytemonkey.org/ollama-phi3.5:edge"
        ports = ["ollama"]
      }

      resources {
        cpu = 4000 # MHz
        memory = 6144 # MB
      }

      logs {
        max_files = 10
        max_file_size = 5
      }
    }
  }
}
