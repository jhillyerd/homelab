job "zwavejs" {
  datacenters = ["skynet"]
  type = "service"

  constraint {
    attribute = "${meta.zwave}"
    value = "aeotec"
  }

  group "zwavejs" {
    count = 1

    update {
      # Canary is not compatible with sticky ephemeral_disk.
      canary = 0
      auto_promote = false
      auto_revert = true
      healthy_deadline = "5m"
      progress_deadline = "10m"
    }

    network {
      port "http" { to = 8091 }
      port "ws" { static = 3000 }
    }

    volume "zwavejs" {
      type = "host"
      source = "zwavejs-data"
      read_only = false
    }

    service {
      name = "zwavejs-ui"
      port = "http"

      tags = [
        "http",
        "traefik.enable=true",
        "traefik.http.routers.zwavejs-ui.entrypoints=websecure",
        "traefik.http.routers.zwavejs-ui.rule=Host(`zwavejs.bytemonkey.org`)",
        "traefik.http.routers.zwavejs-ui.tls.certresolver=letsencrypt",
      ]

      check {
        name = "ZwaveJS HTTP Check"
        type = "http"
        path = "/"
        interval = "10s"
        timeout = "2s"
      }
    }

    service {
      name = "zwavejs-ws"
      port = "ws"

      tags = ["websocket"]

      check {
        name = "ZwaveJS WS Check"
        type = "tcp"
        interval = "10s"
        timeout = "2s"
      }
    }

    ephemeral_disk {
      sticky = true
      migrate = true
      size = 150 # MB
    }

    task "zwavejs" {
      driver = "docker"

      config {
        image = "zwavejs/zwave-js-ui:8.8.5"
        ports = ["http", "ws"]

        devices = [
          {
            host_path = "/dev/serial/by-id/usb-0658_0200-if00"
            container_path = "/dev/zwave"
          }
        ]
      }

      volume_mount {
        volume = "zwavejs"
        destination = "/usr/src/app/store"
        read_only = false
      }

      resources {
        cpu = 200 # MHz
        memory = 128 # MB
      }

      logs {
        max_files = 10
        max_file_size = 5
      }
    }
  }
}
