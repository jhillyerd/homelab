job "logging" {
  datacenters = ["skynet"]
  type = "system"

  constraint {
    attribute = "${attr.kernel.name}"
    value     = "linux"
  }

  update {
    min_healthy_time = "10s"
    healthy_deadline = "5m"
    progress_deadline = "10m"
    auto_revert = true
  }

  group "logging" {
    count = 1

    restart {
      attempts = 3
      interval = "10m"
      delay = "30s"
      mode = "fail"
    }

    network {
      port "api" {
        to = 8686
      }
    }

    # docker socket volume
    volume "docker-sock" {
      type = "host"
      source = "docker-sock-ro"
      read_only = true
    }

    ephemeral_disk {
      size    = 500
      sticky  = true
    }

    task "telegraf" {
      driver = "docker"

      config {
        network_mode = "host"
        image = "telegraf:1.22"
        entrypoint = ["/usr/bin/telegraf"]
        args = [
          "-config",
          "/local/telegraf.conf",
        ]
      }

      resources {
        cpu    = 100
        memory = 128
      }

      template {
        data = <<EOH
          [agent]
            interval = "10s"
            round_interval = true
            metric_batch_size = 1000
            metric_buffer_limit = 10000
            collection_jitter = "0s"
            flush_interval = "10s"
            flush_jitter = "3s"
            precision = ""
            debug = false
            quiet = false
            hostname = ""
            omit_hostname = false
          [[outputs.influxdb]]
            urls = ["http://nexus.home.arpa:8086"]
            database = "telegraf-hosts"
            username = "telegraf"
            password = "{{key "secrets/influxdb/telegraf"}}"
            retention_policy = "autogen"
            timeout = "5s"
            user_agent = "telegraf-{{env "NOMAD_TASK_NAME" }}"
          [[inputs.prometheus]]
            urls = ["https://127.0.0.1:4646/v1/metrics?format=prometheus"]
            tls_ca = "/local/nomad-ca-cert.pem"
          EOH
        destination = "local/telegraf.conf"
      }

      template {
        data = "{{key \"certs/nomad-ca-cert\"}}"
        destination = "local/nomad-ca-cert.pem"
      }
    }

    task "vector" {
      driver = "docker"

      config {
        image = "timberio/vector:0.22.X-alpine"
        ports = ["api"]
      }

      # docker socket volume mount
      volume_mount {
        volume = "docker-sock"
        destination = "/var/run/docker.sock"
        read_only = true
      }

      # Vector won't start unless the sinks(backends) configured are healthy
      env {
        VECTOR_CONFIG = "local/vector.toml"
        VECTOR_REQUIRE_HEALTHY = "true"
      }

      resources {
        cpu    = 500 # 500 MHz
        memory = 256 # 256MB
      }

      # template with Vector's configuration
      template {
        destination = "local/vector.toml"
        change_mode   = "signal"
        change_signal = "SIGHUP"
        # overriding the delimiters to [[ ]] to avoid conflicts with Vector's native templating, which also uses {{ }}
        left_delimiter = "[["
        right_delimiter = "]]"
        data=<<EOH
          data_dir = "alloc/data/vector/"
          [api]
            enabled = true
            address = "0.0.0.0:8686"
            playground = true
          [sources.logs]
            type = "docker_logs"
          [sinks.out]
            type = "console"
            inputs = [ "logs" ]
            encoding.codec = "json"
          [sinks.loki]
            type = "loki"
            inputs = ["logs"]
            endpoint = "http://nexus.home.arpa:3100"
            encoding.codec = "json"
            healthcheck.enabled = true
            # remove fields that have been converted to labels to avoid having the field twice
            remove_label_fields = true
          [sinks.loki.labels]
            forwarder = 'vector'
            app_name = 'nomad_docker'
            job = '{{ label."com.hashicorp.nomad.job_name" }}'
            task = '{{ label."com.hashicorp.nomad.task_name" }}'
            group = '{{ label."com.hashicorp.nomad.task_group_name" }}'
            node = '{{ label."com.hashicorp.nomad.node_name" }}'
        EOH
      }

      service {
        check {
          port     = "api"
          type     = "http"
          path     = "/health"
          interval = "30s"
          timeout  = "5s"
        }
      }

      kill_timeout = "30s"
    }
  }
}
