job "forgejo" {
  datacenters = ["skynet"]
  type = "service"

  group "forgejo" {
    count = 1

    update {
      # Docs recommend stopping old instances for DB migrations,
      # so no canary and long deadlines.
      canary = 0
      auto_promote = false
      auto_revert = true
      healthy_deadline = "10m"
      progress_deadline = "15m"
    }

    network {
      # Both ports bind wg0 only: traefik dials them over the encrypted
      # mesh (phase 3), including git-over-ssh via the tcp router. CI
      # runners reach forgejo through https://forgejo.bytemonkey.org
      # (traefik), so mesh-only binding loses them nothing.
      port "http" {
        to          = 3000
        host_network = "mesh"
      }
      port "ssh" {
        to          = 22
        host_network = "mesh"
      }
    }

    service {
      name     = "forgejo-http"
      port     = "http"
      provider = "nomad" # phase 3: nomad-native registration for traefik

      tags = [
        "http",
        "traefik.enable=true",
        "traefik.http.routers.forgejo-http.entrypoints=websecure",
        "traefik.http.routers.forgejo-http.rule=Host(`forgejo.bytemonkey.org`)",
        "traefik.http.routers.forgejo-http.tls.certresolver=letsencrypt",
        # "traefik.http.routers.forgejo-xhttp.entrypoints=extweb",
        # "traefik.http.routers.forgejo-xhttp.rule=Host(`forgejo.x.bytemonkey.org`)",
        # "traefik.http.routers.forgejo-xhttp.tls.certresolver=letsencrypt",
      ]

      check {
        name = "Forgejo HTTP Check"
        type = "http"
        path = "/"
        interval = "10s"
        timeout = "2s"
      }
    }

    service {
      name     = "forgejo-ssh"
      port     = "ssh"
      provider = "nomad" # phase 3: nomad-native registration for traefik

      tags = [
        "ssh",
        "traefik.enable=true",
        "traefik.tcp.routers.nomad-ssh.rule=HostSNI(`*`)",
        "traefik.tcp.routers.nomad-ssh.entrypoints=ssh",
      ]

      check {
        name = "Forgejo SSH Check"
        type = "tcp"
        port = "ssh"
        interval = "30s"
        timeout = "2s"
      }
    }

    task "forgejo" {
      driver = "docker"

      config {
        image = "codeberg.org/forgejo/forgejo:17.0.1"
        ports = ["http", "ssh"]

        mount {
          type     = "bind"
          source   = "/mnt/nomad-volumes/forgejo"
          target   = "/data"
          readonly = false
        }
      }

      env {
        USER_UID = 3003
        USER_GID = 3003
      }

      resources {
        cpu = 500 # MHz
        memory = 768 # MB
      }

      logs {
        max_files = 10
        max_file_size = 5
      }
    }
  }
}
