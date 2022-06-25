{ config, pkgs, lib, catalog, ... }:
with lib;
let cfg = config.roles.traefik;
in
{
  options.roles.traefik = {
    enable = mkEnableOption "Enable traefik daemon";

    # TODO: Too much abstraction, let websvc role handle this.
    services = mkOption {
      type = with types;
        attrsOf (submodule {
          options = {
            domainName = mkOption { type = str; };
            backendUrls = mkOption { type = listOf str; };
            sticky = mkOption { type = bool; default = false; };
            external = mkOption { type = bool; default = false; };
            externalAuth = mkOption { type = bool; default = true; };
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
        api.dashboard = true;

        entryPoints =
          let
            catalogEntrypoints =
              # Convert catalog name=addr to name.address=addr for traefik.
              mapAttrs (name: address: { inherit address; }) catalog.traefik.entrypoints;
          in
          {
            web = {
              address = ":80/tcp";

              # Always redirect to HTTPS.
              http.redirections.entryPoint.to = "websecure";
            };
          } // catalogEntrypoints;

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
            address = catalog.nodes.nexus.ip.priv + ":8500";
            scheme = "http";
            datacenter = "skynet";
          };
        };

        log.level = "info";
      };

      dynamicConfigOptions =
        let
          routerEntry = name: opt: {
            entryPoints = if opt.external then [ "extweb" ] else [ "web" "websecure" ];
            rule = "Host(`" + opt.domainName + "`)";
            service = name;
            tls.certresolver = "letsencrypt";
            middlewares = mkIf (opt.external && opt.externalAuth) [ "authelia@file" ];
          };

          serviceEntry = name: opt: {
            loadBalancer = {
              # Map list of urls to individual url= attributes.
              servers = map (url: { url = url; }) opt.backendUrls;
              sticky = mkIf opt.sticky { cookie = { }; };
            };
          };
        in
        {
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

            middlewares.authelia = {
              # Forward requests w/ middlewares=authelia@file to authelia.
              forwardAuth = {
                address = "http://${catalog.nodes.nexus.ip.priv}:9091/api/verify?rd=https://auth.x.bytemonkey.org/";
                trustForwardHeader = true;
                authResponseHeaders = [
                  "Remote-User"
                  "Remote-Name"
                  "Remote-Email"
                  "Remote-Groups"
                ];
              };
            };
          };
        };
    };

    # Setup secrets.
    age.secrets = {
      traefik-consul-token.file = ../secrets/traefik-consul-token.age;
    };

    roles.template.files."traefik.env" = {
      vars = {
        cfDnsToken = cfg.cloudflareDnsApiTokenFile;
        consulToken = config.age.secrets.traefik-consul-token.path;
      };
      content = ''
        CF_DNS_API_TOKEN=$cfDnsToken
        CONSUL_HTTP_TOKEN=$consulToken
      '';
    };

    systemd.services.traefik.serviceConfig.EnvironmentFile =
      config.roles.template.files."traefik.env".path;

    # TODO: autogenerate this list from catalog entrypoints
    networking.firewall.allowedTCPPorts = [ 25 80 443 8443 ];
    networking.firewall.allowedUDPPorts = [ 7777 15000 15777 ];
  };
}
