{ config, pkgs, lib, catalog, ... }:
with lib;
let cfg = config.roles.traefik;
in {
  options.roles.traefik = {
    enable = mkEnableOption "Enable traefik daemon";

    services = mkOption {
      type = with types;
        attrsOf (submodule {
          options = {
            domainName = mkOption { type = str; };
            backendUrls = mkOption { type = listOf str; };
          };
        });
      description = "Services to proxy";
      default = { };
    };

    certificateEmail = mkOption {
      type = types.str;
      description = "Email passed to Let's Encrypt";
    };

    cloudflareDnsApiTokenFile = mkOption {
      type = types.path;
      description = "File containing API token with DNS:Edit permission";
    };
  };

  config = mkIf cfg.enable {
    services.traefik = {
      enable = true;

      staticConfigOptions = {
        # Dashboard is not part of the nix package.
        api.dashboard = false;

        entryPoints = {
          web = {
            address = ":80/tcp";

            # Always redirect to HTTPS.
            http.redirections.entryPoint.to = "websecure";
          };

          websecure.address = ":443/tcp";

          smtp = {
            address = ":25/tcp";
          };
        };

        certificatesResolvers.letsencrypt.acme = {
          email = cfg.certificateEmail;
          storage = "/var/lib/traefik/letsencrypt-certs.json";
          caServer = "https://acme-v02.api.letsencrypt.org/directory";
          dnsChallenge = {
            provider = "cloudflare";
            delayBeforeCheck = "0";
            resolvers = [ "1.1.1.1:53" ];
          };
        };

        serversTransport = {
          # Disable backend certificate verification.
          insecureSkipVerify = true;
        };

        providers.consulCatalog = {
          prefix = "traefik";
          exposedByDefault = false;
          endpoint = {
            address = catalog.nodes.nexus.ip + ":8500";
            scheme = "http";
            datacenter = "skynet";
          };
        };

        log.level = "INFO";
      };

      dynamicConfigOptions = let
        routerEntry = name: opt: {
          entryPoints = [ "web" "websecure" ];
          rule = "Host(`" + opt.domainName + "`)";
          service = name;
          tls.certresolver = "letsencrypt";
        };

        serviceEntry = name: opt: {
          loadBalancer = {
            # Map list of urls to individual url= attributes.
            servers = map (url: { url = url; }) opt.backendUrls;
          };
        };
      in {
        http = {
          # Combine static routes with cfg.services entries.
          routers = {
            # Router for built-in traefik API.
            api = {
              entryPoints = [ "web" "websecure" ];
              rule = "Host(`traefik.bytemonkey.org`)";
              service = "api@internal";
              tls.certresolver = "letsencrypt";
            };
          } // mapAttrs routerEntry cfg.services;

          services = mapAttrs serviceEntry cfg.services;
        };
      };
    };

    # Setup Cloudflare secret.
    roles.envfile = {
      files."cloudflare-dns-api.env" = {
        secretPath = cfg.cloudflareDnsApiTokenFile;
        varName = "CF_DNS_API_TOKEN";
      };
    };
    systemd.services.traefik.serviceConfig.EnvironmentFile =
      config.roles.envfile.files."cloudflare-dns-api.env".file;

    networking.firewall.allowedTCPPorts = [ 25 80 443 ];
  };
}
