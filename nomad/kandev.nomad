# Kandev — coding-agent control plane (https://kandev.ai).
#
# Web UI + API for assigning repo work to agents and reviewing the result.
# Agent execution is remote: the agent role on boss (192.168.1.30:2222,
# nixos/roles/kandev-agent.nix) runs the actual CLIs over SSH, so this
# container only needs outbound access, not a docker.sock. The image disables
# the Docker executor anyway (KANDEV_DOCKER_ENABLED=false), which sidesteps
# the upstream docs' containerized-control-plane caveats.
#
# Auth is disabled upstream by default and /data holds gh + agent CLI
# credentials, so this stays internal-only: kandev.bytemonkey.org, no
# external/Authelia route (see nixos/catalog/services.nix).
#
# Secrets (nomad var put nomad/jobs/kandev ...):
#   ssh_private_key   ed25519 key for the boss agent role (192.168.1.30:2222);
#                     rendered at /data/home/.ssh/id_ed25519 inside the
#                     container — that is the path to give Kandev's SSH
#                     profile in the UI. Pubkey belongs in boss's
#                     /srv/kandev-agent/home/.ssh/authorized_keys.
#
# /data on NFS holds the SQLite DB, repos, worktrees, sessions, runtime npm
# CLI installs and CLI auth state.
#
# Images: ghcr is not mirrored, so pin a release tag and bump manually. Base
# flavor (X.Y.Z); the universal flavor adds Go/Rust/build tools that only
# matter for in-container agent execution, which we don't use.

job "kandev" {
  datacenters = ["skynet"]
  type        = "service"

  group "kandev" {
    count = 1

    update {
      # SQLite schema migrations run at startup, so no canaries; give first
      # boot (volume chown + migrations) generous deadlines.
      canary            = 0
      auto_promote      = false
      auto_revert       = true
      healthy_deadline  = "10m"
      progress_deadline = "15m"
    }

    # Bridge (not host): the image command pins the listener to 38429, so the
    # dynamic host port only lines up via a docker port mapping.
    network {
      port "http" { to = 38429 }
    }

    service {
      name = "kandev"
      port = "http"

      tags = [
        "http",
        "traefik.enable=true",
        "traefik.http.routers.kandev.entrypoints=websecure",
        "traefik.http.routers.kandev.rule=Host(`kandev.bytemonkey.org`)",
        "traefik.http.routers.kandev.tls.certresolver=letsencrypt",
      ]

      # /ready (not /health): /health returns 200 while still starting up,
      # /ready flips once routes are registered. It is not a DB probe, but
      # the process shares its listener with NFS-backed git/SQLite work and
      # NAS-side stalls have flapped checks on this cluster before (bifrost),
      # so debounce generously.
      check {
        name     = "Kandev HTTP Check"
        type     = "http"
        path     = "/ready"
        interval = "30s"
        timeout  = "10s"

        failures_before_critical = 4
      }
    }

    task "kandev" {
      driver = "docker"

      # The image defaults to root + a chown/gosu entrypoint repair that
      # EPERMs on the root-squashed NFS export; as non-root the entrypoint
      # execs the command directly. 3003:3003 owns /mnt/nomad-volumes/*.
      user = "3003"

      config {
        image = "ghcr.io/kdlbs/kandev:0.96.0"
        ports = ["http"]

        mount {
          type     = "bind"
          source   = "/mnt/nomad-volumes/kandev"
          target   = "/data"
          readonly = false
        }

        # SSH executor key for the agent role on boss. Docker creates the
        # missing /data/home/.ssh parent (0755, root) on first mount; the key
        # file itself is 0600 task-user-owned, which is what OpenSSH demands.
        mount {
          type     = "bind"
          source   = "secrets/id_ed25519"
          target   = "/data/home/.ssh/id_ed25519"
          readonly = true
        }
      }

      # Rendered from the Nomad variable; perms matter — ssh refuses keys
      # readable by group/other. uid/gid: without them the client renders as
      # the Nomad agent user (root) and the bind-mounted 0600 file is
      # unreadable by the task user. Change the var and Nomad re-renders and
      # restarts the task (default change_mode).
      template {
        data        = "{{ with nomadVar \"nomad/jobs/kandev\" }}{{ .ssh_private_key }}{{ end }}"
        destination = "secrets/id_ed25519"
        perms       = "0600"
        uid         = 3003
        gid         = 3003
      }

      resources {
        cpu    = 1000 # MHz
        memory = 2048 # MB
      }

      logs {
        max_files     = 10
        max_file_size = 15
      }
    }
  }
}
