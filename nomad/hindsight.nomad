# Hindsight — agent memory service (vectorize-io/hindsight)
#
# Stateless by design: all memory state lives in PostgreSQL + pgvector
# (fastd.home.arpa). Nothing is stored in the container, so the task can be
# rescheduled or updated freely with no bind mounts.
#
# Secrets (nomad var put nomad/jobs/hindsight ...):
#   database_url   postgresql://hindsight:<pw>@fastd.home.arpa:5432/hindsight
#   tenant_api_key shared key required on every API request
#
# Images/versions: ghcr is not mirrored, so pin a release tag and bump manually.

job "hindsight" {
  datacenters = ["skynet"]
  type        = "service"

  group "hindsight" {
    count = 1

    update {
      canary            = 0
      auto_promote      = false
      auto_revert       = true
      healthy_deadline  = "10m"
      progress_deadline = "20m"
    }

    network {
      mode = "host"

      # 8888: API (also serves /mcp/{bank} for MCP clients)
      # 9999: Control Plane (web UI)
      port "api" { to = 8888 }
      port "ui"  { to = 9999 }
    }

    # The API authenticates nothing unless the built-in API-key tenant
    # extension is enabled, so it is not optional here: this host rule makes
    # the endpoint reachable at hindsight-api.bytemonkey.org like any other
    # web service, and the key is what keeps strangers out of your banks.
    service {
      name = "hindsight-api"
      port = "api"

      tags = [
        "http",
        "traefik.enable=true",
        "traefik.http.routers.hindsight-api.entrypoints=websecure",
        "traefik.http.routers.hindsight-api.rule=Host(`hindsight-api.bytemonkey.org`)",
        "traefik.http.routers.hindsight-api.tls.certresolver=letsencrypt",
      ]

      # Readiness checks the database; liveness does not. Prefer readiness so a
      # dead fastd stops this from receiving traffic, but note that it also
      # means a DB outage fails the task and triggers a restart loop.
      check {
        name     = "Hindsight API Check"
        type     = "http"
        path     = "/health/ready"
        interval = "15s"
        timeout  = "5s"
      }
    }

    # The Control Plane talks to the API server-side via HINDSIGHT_CP_DATAPLANE_API_URL
    # (below), so the browser only ever needs 9999.
    service {
      name = "hindsight"
      port = "ui"

      tags = [
        "http",
        "traefik.enable=true",
        "traefik.http.routers.hindsight.entrypoints=websecure",
        "traefik.http.routers.hindsight.rule=Host(`hindsight.bytemonkey.org`)",
        "traefik.http.routers.hindsight.tls.certresolver=letsencrypt",
      ]

      # UI health: no documented /health on the CP; a TCP check is the honest option.
      check {
        name     = "Hindsight UI Check"
        type     = "tcp"
        interval = "15s"
        timeout  = "2s"
      }
    }

    task "hindsight" {
      driver = "docker"

      config {
        image = "ghcr.io/vectorize-io/hindsight:0.10.1"
        ports = ["api", "ui"]
      }

      template {
        data = <<EOT
# Storage: external PostgreSQL + pgvector on fastd.
# Without this the image starts its own embedded pg0 in ~/.hindsight/pg0 and
# data becomes invisible to the rest of the homelab.
HINDSIGHT_API_DATABASE_URL={{ with nomadVar "nomad/jobs/hindsight" }}{{ .database_url }}{{ end }}
HINDSIGHT_API_TENANT_EXTENSION=hindsight_api.extensions.builtin.tenant:ApiKeyTenantExtension
HINDSIGHT_API_TENANT_API_KEY={{ with nomadVar "nomad/jobs/hindsight" }}{{ .tenant_api_key }}{{ end }}

# The internal worker claims async tasks (consolidation, mental model
# refresh) under its ID and recovers them by ID after a restart. The default
# is the container hostname, which Nomad changes every recreation, leaving
# tasks stuck in 'processing' forever. With count = 1 a literal is stable and
# collision-free.
HINDSIGHT_API_WORKER_ID=hindsight-1

# LLM: bifrost gateway (OpenAI-compatible). Bifrost appends the API paths
# itself, so the base URL is the bare origin — plus /v1, which this OpenAI
# provider needs.
HINDSIGHT_API_LLM_PROVIDER=openai
HINDSIGHT_API_LLM_BASE_URL=https://bifrost.bytemonkey.org/v1
HINDSIGHT_API_LLM_MODEL=fast

# `chat_template_kwargs`/`enable_thinking` does NOT survive Bifrost, but
# `reasoning_effort` does.) Applies globally: retain, reflect, consolidation
# and mental-model refresh all inherit it unless overridden by their own
# HINDSIGHT_API_*_LLM_REASONING_EFFORT.
HINDSIGHT_API_LLM_REASONING_EFFORT=none

HINDSIGHT_API_LLM_API_KEY=unused

# Mental-model refresh runs the reflect pipeline in the background and has
# its own timeout lane: it never inherits REFLECT_LLM_TIMEOUT (kept short
# because interactive reflect has a caller waiting), it falls back to the
# global 120s default — which is what those refresh_mental_model timeouts
# were hitting.
HINDSIGHT_API_MENTAL_MODEL_REFRESH_LLM_TIMEOUT=600

# Debounce for automatic mental-model refreshes: a triggered refresh arriving
# within N seconds of the model's last rebuild is parked until the window
# expires. Default is 0 — every trigger rebuilds immediately — which let
# auto-refreshes fire back-to-back and kept the GPU busy. Explicit refreshes
# (API/MCP/control plane) ignore this and always run.
HINDSIGHT_API_MENTAL_MODEL_MIN_REFRESH_INTERVAL_SECONDS=300

# Consolidation batches make the longest LLM calls in the system, and the
# global per-request deadline (HINDSIGHT_API_LLM_TIMEOUT) is only 120s, which
# cuts large memory-consolidation batches short mid-call. This override raises
# just the consolidation lane; interactive ops (recall/reflect) keep the fast
# default deadline. 0 or unset falls back to the global timeout.
HINDSIGHT_API_CONSOLIDATION_LLM_TIMEOUT=600

# Control Plane -> API, server-side. Both processes share this container's
# network namespace, so the API is on the task's own loopback at its `to`
# port (8888).
HINDSIGHT_CP_DATAPLANE_API_URL=http://127.0.0.1:8888

# The API requires the tenant API key on every request (ApiKeyTenantExtension
# expects `Authorization: Bearer <key>`), and the CP proxies server-side, so
# it must present the same key or every request 401s.
HINDSIGHT_CP_DATAPLANE_API_KEY={{ with nomadVar "nomad/jobs/hindsight" }}{{ .tenant_api_key }}{{ end }}
EOT
        destination = "secrets/hindsight.env"
        env         = true
      }

      resources {
        cpu        = 1000  # MHz
        memory     = 2048  # MB — soft limit; OOMed at 1024
        memory_max = 3072  # MB — hard limit; lets the container burst between
                            #       consolidation batches without being killed
      }

      logs {
        max_files     = 10
        max_file_size = 15
      }
    }
  }
}
