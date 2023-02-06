job "nix-cache" {
  datacenters = ["skynet"]
  type = "service"

  group "nix-cache" {
    count = 1

    network {
      port "http" {}
    }

    service {
      name = "nix-cache"
      tags = [ "urlprefix-nix-cache.service.${node.datacenter}.consul/" ]
      port = "http"

      check {
        type     = "tcp"
        interval = "10s"
        timeout  = "2s"
      }
    }

    task "nginx" {
      driver = "docker"

      config {
        image = "nginx:stable-alpine"
        ports = ["http"]

        volumes = [
          "custom/default.conf:/etc/nginx/conf.d/default.conf"
        ]
      }

      resources {
        cpu    = 100 # MHz
        memory = 128 # MB
      }

      template {
        data = <<EOH
          server {
            listen {{env "NOMAD_PORT_http"}};
            server_name nix-cache.service.{{ env "NOMAD_DC" }}.consul;
            location / {
              root /local/data;
            }
          }
        EOH
        destination = "custom/default.conf"
      }

      # consul kv put features/demo 'Consul Rocks!'
      template {
        data = <<EOH
          Nomad Template example (Consul value)
          <br />
          <br />
          {{ if keyExists "features/demo" }}
            Consul Key Value:  {{ key "features/demo" }}
          {{ else }}
            Good morning.
          {{ end }}
          <br />
          <br />
          Node Environment Information:  <br />
          node_id:     {{ env "node.unique.id" }} <br/>
          datacenter:  {{ env "NOMAD_DC" }}
        EOH
        destination = "local/data/index.html"
      }

    }
  }
}
