job "nix-cache" {
  datacenters = ["skynet"]
  type = "service"

  group "nix-cache" {
    count = 1

    network {
      # Bind on wg0 only: registers mesh addresses, and traefik
      # (nomad provider) dials backends over the encrypted mesh
      # (wireguard-mesh-plan phase 3).
      port "http" {
        host_network = "mesh"
      }
    }

    service {
      name     = "nix-cache"
      port     = "http"
      provider = "nomad" # phase 3: nomad-native registration for traefik

      tags = [
        "http",
        "traefik.enable=true",
        "traefik.http.routers.nix-cache.entrypoints=websecure",
        "traefik.http.routers.nix-cache.rule=Host(`nix-cache.bytemonkey.org`)",
        "traefik.http.routers.nix-cache.tls.certresolver=letsencrypt",
      ]

      check {
        type     = "tcp"
        interval = "10s"
        timeout  = "2s"
      }
    }

    ephemeral_disk {
      sticky = true
      migrate = false
      size = 56320 # MB
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
        memory = 160 # MB
      }

      template {
        data = <<EOH
          # This config is based on:
          # https://www.channable.com/tech/setting-up-a-private-nix-cache-for-fun-and-profit
          proxy_cache_path /alloc/data/nginx-cache max_size=50G keys_zone=cache_zone:50m inactive=365d;
          proxy_cache cache_zone;
          # Don't cache failed requests.
          proxy_cache_valid 200 365d;
          proxy_cache_use_stale error timeout invalid_header updating http_500 http_502 http_504 http_403 http_404 http_429;
          # Nix store is immutable, ignore expiration.
          proxy_ignore_headers X-Accel-Expires Expires Cache-Control Set-Cookie;
          proxy_cache_lock on;
          proxy_ssl_server_name on;
          proxy_ssl_verify on;
          proxy_ssl_verify_depth 2;
          proxy_ssl_trusted_certificate /etc/ssl/certs/ca-certificates.crt;

          server {
            listen {{env "NOMAD_PORT_http"}};
            server_name nix-cache.bytemonkey.org;
            location / {
              proxy_set_header Host $proxy_host;
              proxy_pass https://cache.nixos.org;
            }
          }
        EOH
        destination = "custom/default.conf"
      }
    }
  }
}
