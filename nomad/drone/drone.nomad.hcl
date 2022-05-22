job "drone" {
  datacenters = ["skynet"]

  constraint {
    attribute = "${attr.kernel.name}"
    value = "linux"
  }

  group "drone" {
    network {
      port "drone-http" { to = 80 }
      port "drone-agent" { to = 3000 }
    }

    service {
      name = "drone"
      port = "drone-http"
      tags = [
        "http",
        "traefik.enable=true",
        "traefik.http.routers.drone-http.entrypoints=websecure",
        "traefik.http.routers.drone-http.rule=Host(`drone.bytemonkey.org`)",
        "traefik.http.routers.drone-http.tls.certresolver=letsencrypt",
      ]

      check {
        name = "Drone HTTP Check"
        port = "drone-http"
        type = "tcp"
        interval = "10s"
        timeout = "2s"
      }
    }

    task "drone-server" {
      driver = "docker"
      config {
        image = "drone/drone:2.12"
        ports = ["drone-http"]
      }

      template {
        data = <<EOH
          DRONE_GITEA_SERVER=https://gitea.bytemonkey.org
          DRONE_GITEA_CLIENT_ID={{key "secrets/drone/gitea-client-id"}}
          DRONE_GITEA_CLIENT_SECRET={{key "secrets/drone/gitea-client-secret"}}
          DRONE_USER_CREATE=username:admin,machine:false,admin:true
          DRONE_DATABASE_DRIVER=postgres
          DRONE_DATABASE_DATASOURCE={{key "secrets/drone/datasource"}}
          DRONE_DATABASE_SECRET={{key "secrets/drone/encryption-key"}}
          DRONE_SERVER_HOST=drone.bytemonkey.org
          DRONE_SERVER_PROTO=https
          DRONE_RPC_SECRET={{key "secrets/drone/rpc-secret"}}
        EOH

        destination = "local/env"
        env = true
      }

      resources {
        cpu    = 250 # MHz
        memory = 512 # MB
      }
    }

    task "drone-agent" {
      driver = "docker"
      config {
        image = "drone/drone-runner-nomad:latest"
        ports = ["drone-agent"]
      }

      template {
        data = <<EOH
          DRONE_JOB_DATACENTER=skynet
          DRONE_RPC_HOST=drone.service.consul
          DRONE_RPC_PROTO=http
          DRONE_RPC_SECRET={{key "secrets/drone/rpc-secret"}}
          NOMAD_ADDR=http://nomad.service.consul:4646
          NOMAD_TOKEN={{key "secrets/drone/runner-nomad-token"}}
        EOH

        destination = "local/env"
        env = true
      }

      resources {
        cpu    = 250 # MHz
        memory = 1024 # MB
      }
    }
  }
}

