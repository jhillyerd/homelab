job "speedflux" {
  datacenters = ["skynet"]
  type = "service"

  group "speedflux" {
    count = 1

    consul {
      # Use server default task identity.
    }

    task "speedflux" {
      driver = "docker"

      config {
        image = "breadlysm/speedtest-to-influxdb"
        cap_add = ["net_raw"]
      }

      resources {
        cpu = 100 # MHz
        memory = 64 # MB
        memory_max = 256 # MB
      }

      logs {
        max_files = 10
        max_file_size = 5
      }

      template {
        data = <<EOT
NAMESPACE=comcast
INFLUX_DB_ADDRESS=metrics.home.arpa
INFLUX_DB_PORT=8086
INFLUX_DB_USER=telegraf
INFLUX_DB_PASSWORD={{key "secrets/influxdb/telegraf"}}
INFLUX_DB_DATABASE=telegraf-hosts
# See https://github.com/breadlysm/speedtest-to-influxdb#tag-options
INFLUX_DB_TAGS=external_ip, server_name, server_location, isp, server_host
# Speed test interval in minutes
SPEEDTEST_INTERVAL=600
# Ping interval in seconds
PING_INTERVAL=180
PING_TARGETS=1.1.1.1, 8.8.8.8
LOG_TYPE=info
EOT

        destination = "speedflux.env"
        env = true
      }
    }
  }
}
