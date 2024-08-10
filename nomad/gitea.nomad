job "gitea" {
  datacenters = ["skynet"]
  type = "service"

  group "gitea" {
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
      port "http" { to = 3000 }
      port "ssh" { to = 22 }
    }

    volume "gitea" {
      type = "host"
      source = "gitea-storage"
      read_only = false
    }

    service {
      name = "gitea-http"
      port = "http"

      tags = [
        "http",
        "traefik.enable=true",
        "traefik.http.routers.gitea-http.entrypoints=websecure",
        "traefik.http.routers.gitea-http.rule=Host(`gitea.bytemonkey.org`)",
        "traefik.http.routers.gitea-http.tls.certresolver=letsencrypt",
        # "traefik.http.routers.gitea-xhttp.entrypoints=extweb",
        # "traefik.http.routers.gitea-xhttp.rule=Host(`gitea.x.bytemonkey.org`)",
        # "traefik.http.routers.gitea-xhttp.tls.certresolver=letsencrypt",
      ]

      check {
        name = "Gitea HTTP Check"
        type = "http"
        path = "/"
        interval = "10s"
        timeout = "2s"
      }
    }

    service {
      name = "gitea-ssh"
      port = "ssh"

      tags = [
        "ssh",
        "traefik.enable=true",
        "traefik.tcp.routers.nomad-ssh.rule=HostSNI(`*`)",
        "traefik.tcp.routers.nomad-ssh.entrypoints=ssh",
      ]

      check {
        name = "Gitea SSH Check"
        type = "tcp"
        port = "ssh"
        interval = "30s"
        timeout = "2s"
      }
    }

    task "gitea" {
      driver = "docker"

      config {
        image = "gitea/gitea:1.21.10"
        ports = ["http", "ssh"]
      }

      volume_mount {
        volume = "gitea"
        destination = "/data"
        read_only = false
      }

      env {
        USER_UID = 1024
        USER_GID = 1000
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
