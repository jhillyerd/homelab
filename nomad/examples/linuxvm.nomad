job "linuxvm" {
  datacenters = ["skynet"]
  type = "service"

  group "linuxvm" {
    count = 1

    network {
      port "ssh" {}
    }

    task "linuxvm" {
      driver = "qemu"

      config {
        image_path = "local/nixos.qcow2"

        accelerator = "kvm"
        graceful_shutdown = true
        guest_agent = true

        args = [
          "-device",
          "e1000,netdev=user.0",
          "-netdev",
          "user,id=user.0,hostfwd=tcp::${NOMAD_PORT_ssh}-:22",
        ]
      }

      artifact {
        source = "http://skynas.home.arpa/vms/nixos.qcow2"
      }

      kill_timeout = "30s"

      resources {
        cpu = 1000 # MHz
        memory = 2048 # MB
      }

      logs {
        max_files = 10
        max_file_size = 1
      }
    }
  }
}
