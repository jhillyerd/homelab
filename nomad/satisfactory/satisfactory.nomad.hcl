job "satisfactory" {
  datacenters = ["skynet"]
  type = "service"

  group "satisfactory" {
    count = 1

    update {
      canary = 0
      auto_promote = false
      auto_revert = true
      healthy_deadline = "2m"
      progress_deadline = "5m"
    }

    network {
      port "game" { to = 7777 }
      port "beacon" { to = 15000 }
      port "query" { to = 15777 }
    }

    service {
      name = "factory-game"
      port = "game"

      tags = [
        "udp",
        "traefik.enable=true",
        "traefik.udp.routers.satisfactory-game.entrypoints=factorygame",
      ]
    }

    service {
      name = "factory-beacon"
      port = "beacon"

      tags = [
        "udp",
        "traefik.enable=true",
        "traefik.udp.routers.satisfactory-beacon.entrypoints=factorybeacon",
      ]
    }

    service {
      name = "factory-query"
      port = "query"

      tags = [
        "udp",
        "traefik.enable=true",
        "traefik.udp.routers.satisfactory-query.entrypoints=factoryquery",
      ]
    }

    volume "satisfactory" {
      type = "host"
      source = "satisfactory-storage"
      read_only = false
    }

    task "satisfactory" {
      driver = "docker"

      config {
        image = "wolveix/satisfactory-server:latest"
        ports = ["game", "beacon", "query"]
      }

      volume_mount {
        volume = "satisfactory"
        destination = "/config"
        read_only = false
      }

      env {
        AUTOSAVEINTERVAL = "300"
      }

      resources {
        cpu = 6000 # MHz
        memory = 10240 # MB
        memory_max = 12288 # MB
      }

      logs {
        max_files = 10
        max_file_size = 5
      }
    }
  }
}
