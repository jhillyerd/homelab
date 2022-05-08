job "inbucket" {
  datacenters = ["skynet"]
  type = "service"

  group "backend" {
    count = 1

    network {
      port "http" {
        static = 9000
      }
      port "smtp" {
        static = 2500
      }
    }

    service {
      name = "inbucket-http"
      port = "http"
      tags = ["http"]

      check {
        name = "alive"
        type = "http"
        path = "/"
        interval = "10s"
        timeout = "2s"
      }
    }

    service {
      name = "inbucket-smtp"
      port = "smtp"
      tags = ["smtp"]

      check {
        name = "alive"
        type = "tcp"
        port = "smtp"
        interval = "10s"
        timeout = "2s"
      }
    }

    ephemeral_disk {
      sticky = true
      migrate = true
      size = 150 # MB
    }

    task "inbucket" {
      driver = "docker"

      config {
        image = "inbucket/inbucket:latest"

        ports = ["http", "smtp"]

        volumes = [
          "../alloc/data/inbucket_storage:/storage"
        ]
      }

      resources {
        cpu = 300 # MHz
        memory = 128 # MB
      }

      logs {
        max_files = 10
        max_file_size = 5
      }
    }
  }
}
