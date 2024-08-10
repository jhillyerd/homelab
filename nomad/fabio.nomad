job "fabio" {
  datacenters = ["skynet"]
  type = "system"

  constraint {
    attribute = "${attr.kernel.name}"
    value = "linux"
  }

  constraint {
    attribute = "${attr.kernel.arch}"
    value = "x86_64"
  }

  group "fabio" {
    network {
      port "lb" {
        static = 80
        to = 9999
      }
      port "ui" {
        static = 9998
      }
    }

    task "fabio" {
      driver = "docker"

      config {
        image = "fabiolb/fabio"
        ports = ["lb","ui"]
        args = ["-cfg", "/secrets/fabio.properties"]
      }

      user = "nobody"

      resources {
        cpu    = 200
        memory = 128
      }

      template {
        data = <<EOT
          registry.consul.addr = {{env "NOMAD_IP_lb"}}:8500
          registry.consul.token = {{key "secrets/fabio/consul"}}
        EOT
        destination = "secrets/fabio.properties"
      }
    }
  }
}
