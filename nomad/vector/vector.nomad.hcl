job "vector" {
  datacenters = ["skynet"]
  type = "system"

  update {
    min_healthy_time = "10s"
    healthy_deadline = "5m"
    progress_deadline = "10m"
    auto_revert = true
  }

  group "vector" {
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

      # resource limits are a good idea because you don't want your log collection to consume all resources available
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
