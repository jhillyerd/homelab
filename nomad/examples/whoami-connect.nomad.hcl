job "whoami-connect" {
  datacenters = ["skynet"]
  type = "service"

  constraint {
    attribute = "${attr.kernel.name}"
    value = "linux"
  }

  constraint {
    attribute = "${attr.kernel.arch}"
    value = "x86_64"
  }

  group "whoami" {
    count = 1

    network {
      mode = "bridge"
    }

    service {
      name = "whoami-connect"
      port = 80

      # Allows sidecar to connect.
      address_mode = "alloc"

      tags = [
        "http",
      ]

      connect {
        sidecar_service {}
      }

      check {
        name = "Whoami HTTP Check"
        type = "http"
        path = "/"
        interval = "10s"
        timeout = "2s"

        # Allow local consul to connect.
        address_mode = "alloc"
      }
    }

    task "whoami" {
      driver = "docker"

      config {
        image = "traefik/whoami"
        ports = ["http"]
      }

      env {
        WHOAMI_PORT_NUMBER = "80"
        WHOAMI_NAME = "connect"
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
