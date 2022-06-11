job "whoami" {
  datacenters = ["skynet"]
  type = "service"

  group "whoami" {
    count = 1

    network {
      port "public" { to = 80 }
      port "private" { to = 81 }
    }

    service {
      name = "whoami-public"
      port = "public"

      tags = [
        "http",
        "traefik.enable=true",
        "traefik.http.routers.whoami-public.entrypoints=extweb",
        "traefik.http.routers.whoami-public.rule=Host(`x.bytemonkey.org`) && PathPrefix(`/public/`)",
        "traefik.http.routers.whoami-public.tls.certresolver=letsencrypt",
      ]

      check {
        name = "Public HTTP Check"
        type = "http"
        path = "/"
        interval = "10s"
        timeout = "2s"
      }
    }

    service {
      name = "whoami-private"
      port = "private"

      tags = [
        "http",
        "traefik.enable=true",
        "traefik.http.routers.whoami-private.entrypoints=extweb",
        "traefik.http.routers.whoami-private.rule=Host(`x.bytemonkey.org`) && PathPrefix(`/private/`)",
        "traefik.http.routers.whoami-private.tls.certresolver=letsencrypt",
      ]

      check {
        name = "Private HTTP Check"
        type = "http"
        path = "/"
        interval = "10s"
        timeout = "2s"
      }
    }

    task "public" {
      driver = "docker"

      config {
        image = "traefik/whoami"
        ports = ["public"]
      }

      env {
        WHOAMI_PORT_NUMBER = "${NOMAD_PORT_public}"
        WHOAMI_NAME = "public"
      }

      resources {
        cpu = 100 # MHz
        memory = 16 # MB
      }

      logs {
        max_files = 10
        max_file_size = 1
      }
    }

    task "private" {
      driver = "docker"

      config {
        image = "traefik/whoami"
        ports = ["private"]
      }

      env {
        WHOAMI_PORT_NUMBER = "${NOMAD_PORT_private}"
        WHOAMI_NAME = "private"
      }

      resources {
        cpu = 100 # MHz
        memory = 16 # MB
      }

      logs {
        max_files = 10
        max_file_size = 1
      }
    }
  }
}
