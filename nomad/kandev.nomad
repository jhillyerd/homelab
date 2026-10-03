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
#   database_password PostgreSQL role password (kandev@fastd.home.arpa:5432).
#
# Database lives in PostgreSQL on fastd (fastd.home.arpa), not SQLite: kandev
# enables SQLite WAL by default and WAL relies on shared-memory mmap +
# cross-client byte-range locking that NFS does not provide, which pinned our
# stalls/corruption symptoms. /data on NFS still holds repos, worktrees,
# sessions, runtime npm CLI installs and CLI auth state — that state is
# plain-file and NFS-safe. Driver switch does NOT migrate the old SQLite rows
# (kandev has no sqlite->postgres path): task history stays behind in
# /data/data/kandev.db. Rollback is just unsetting the KANDEV_DATABASE_* env.
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
      # Schema migrations run at startup; unlike SQLite there is no
      # pre-migration snapshot, so pg_dump before image upgrades. No canaries;
      # give first boot generous deadlines.
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
      # /ready flips once routes are registered. Post-startup it also flips
      # to 503 (reason "persistence") when the postgres store probe fails, so
      # a dead fastd now fails checks (same tradeoff as hindsight). Git/FS
      # work still rides NFS, which has flapped checks on this cluster before
      # (bifrost), so keep the debounce.
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
      # A numeric uid with no passwd entry (image stops at kandev:1000)
      # breaks getpwuid-style lookups in the CLIs kandev shells out to
      # (git, gh, ...), hence the /etc/passwd overlay mount below. Pin
      # uid:gid — a bare numeric user leaves docker defaulting gid to 0.
      user = "3003:3003"

      config {
        image = "ghcr.io/kdlbs/kandev:0.97.0"
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

        # Overlay a passwd that knows uid 3003; see the secrets/passwd
        # template below for why the content is a verbatim copy + one line.
        mount {
          type     = "bind"
          source   = "secrets/passwd"
          target   = "/etc/passwd"
          readonly = true
        }
      }

      # PostgreSQL on fastd. Bridge-mode containers resolve via the host's
      # DNS (cluster BIND), and outbound TCP NATs to the client host — same
      # path hindsight uses, though that one runs host-networked.
      # DBNAME not DATABASE_NAME (viper maps database.dbName directly).
      # sslmode disable: LAN-only, like every other cluster hop. Pool defaults
      # (min 5 / max 25) are fine. Nomad re-renders and restarts on var change.
      template {
        data = <<EOT
KANDEV_DATABASE_DRIVER=postgres
KANDEV_DATABASE_HOST=fastd.home.arpa
KANDEV_DATABASE_PORT=5432
KANDEV_DATABASE_USER=kandev
KANDEV_DATABASE_DBNAME=kandev
KANDEV_DATABASE_SSLMODE=disable
KANDEV_DATABASE_PASSWORD={{ with nomadVar "nomad/jobs/kandev" }}{{ .database_password }}{{ end }}

# Traefik on web (192.168.128.11, static): accept its X-Forwarded-For /
# X-Forwarded-Host so the port-scoped session cookie resolves the browser's
# original host (kandev.bytemonkey.org) instead of the bridge peer. Exact IP,
# not a CIDR — default (unset) ignores all forwarded headers.
KANDEV_TRUSTED_PROXIES=192.168.128.11

# Must be HTTPS for remote executors.
KANDEV_GITHUB_CREDENTIAL_BROKER_PUBLIC_BASE_URL=https://kandev.bytemonkey.org
EOT
        destination = "secrets/database.env"
        env         = true
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

      # /etc/passwd overlay. The image has no entry for the shared NFS uid,
      # and pure-Go CLIs it execs (git, gh, ...) resolve the current user via
      # os/user -> /etc/passwd with no env fallback, failing with
      # "user: unknown userid 3003". Content is the image's passwd verbatim
      # plus one appended kandev-svc line, so image users (kandev:1000 for
      # the unused root/gosu entrypoint path) stay resolvable.
      #
      # Upgrade check: this copy matches ghcr.io/kdlbs/kandev:0.97.0 — on an
      # image bump, re-diff and refresh (drift here fails loudly in CLI
      # execs, never silently):
      #   nix run nixpkgs#crane -- export ghcr.io/kdlbs/kandev:<tag> - \
      #     | tar -xO etc/passwd
      template {
        data = <<EOT
root:x:0:0:root:/root:/bin/bash
daemon:x:1:1:daemon:/usr/sbin:/usr/sbin/nologin
bin:x:2:2:bin:/bin:/usr/sbin/nologin
sys:x:3:3:sys:/dev:/usr/sbin/nologin
sync:x:4:65534:sync:/bin:/bin/sync
games:x:5:60:games:/usr/games:/usr/sbin/nologin
man:x:6:12:man:/var/cache/man:/usr/sbin/nologin
lp:x:7:7:lp:/var/spool/lpd:/usr/sbin/nologin
mail:x:8:8:mail:/var/mail:/usr/sbin/nologin
news:x:9:9:news:/var/spool/news:/usr/sbin/nologin
uucp:x:10:10:uucp:/var/spool/uucp:/usr/sbin/nologin
proxy:x:13:13:proxy:/bin:/usr/sbin/nologin
www-data:x:33:33:www-data:/var/www:/usr/sbin/nologin
backup:x:34:34:backup:/var/backups:/usr/sbin/nologin
list:x:38:38:Mailing List Manager:/var/list:/usr/sbin/nologin
irc:x:39:39:ircd:/run/ircd:/usr/sbin/nologin
_apt:x:42:65534::/nonexistent:/usr/sbin/nologin
nobody:x:65534:65534:nobody:/nonexistent:/usr/sbin/nologin
kandev:x:1000:999::/data/home:/bin/sh
kandev-svc:x:3003:3003:Kandev service:/data/home:/bin/sh
EOT
        destination = "secrets/passwd"
        perms       = "0644"
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
