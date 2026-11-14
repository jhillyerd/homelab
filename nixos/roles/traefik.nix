{
  config,
  catalog,
  lib,
  ...
}:
with lib;
let
  cfg = config.roles.traefik;
in
{
  options.roles.traefik = {
    enable = mkEnableOption "Enable traefik daemon";

    autheliaUrl = mkOption {
      type = types.str;
      description = "forwardAuth URL for authelia service";
      example = "http://localhost:9091/api/verify?rd=https://login.example.com/";
    };

    # TODO: Too much abstraction, let websvc role handle this.
    services = mkOption {
      type =
        with types;
        attrsOf (submodule {
          options = {
            domainName = mkOption { type = str; };
            backendUrls = mkOption { type = listOf str; };
            sticky = mkOption {
              type = bool;
              default = false;
            };
            checkHost = mkOption {
              type = nullOr str;
              default = null;
            };
            checkPath = mkOption {
              type = str;
              default = "/";
            };
            checkInterval = mkOption {
              type = str;
              default = "15s";
            };
            external = mkOption {
              type = bool;
              default = false;
            };
            externalAuth = mkOption {
              type = bool;
              default = true;
            };
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
          }
          // catalogEntrypoints;

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
          connectAware = true;

          endpoint = {
            address = "consul.service.skynet.consul:8500";
            scheme = "http";
            datacenter = "skynet";
          };
        };

        # Nomad-native service discovery (wireguard-mesh-plan phase 3).
        # Services opt in per-service with `provider = "nomad"` in their
        # job specs; consulCatalog above is removed once all traefik-tagged
        # services have migrated.
        #
        # The API is TLS-only and the server cert carries no mesh-IP SANs,
        # so we dial witness's mesh address with verification disabled:
        # the connection still rides encrypted wg0, and only mesh members
        # can route to 10.99.x.y, so the cert's identity is anchored by the
        # mesh itself. Token arrives via NOMAD_TOKEN in traefik.env
        # (Traefik's env parsing does not map
        # TRAEFIK_PROVIDERS_NOMAD_ENDPOINT_TOKEN to endpoint.token, but the
        # provider defaults its token from the NOMAD_TOKEN env var, the
        # same mechanism consulCatalog uses with CONSUL_HTTP_TOKEN).
        providers.nomad = {
          prefix = "traefik";
          exposedByDefault = false;

          endpoint = {
            address = "https://${catalog.nodes.witness.ip.wg}:4646";
            tls.insecureSkipVerify = true;
          };
        };

        accessLog = { }; # enabled
        log.level = "info";
      };

      dynamicConfigOptions =
        let
          routerEntry = name: opt: {
            # Always allow internal entry points, external is optional.
            entryPoints = [
              "web"
              "websecure"
            ]
            ++ (if opt.external then [ "extweb" ] else [ ]);

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
              healthCheck = {
                hostname = mkIf (opt.checkHost != null) opt.checkHost;
                path = opt.checkPath;
                interval = opt.checkInterval;
              };
            };
          };
        in
        {
          http = {
            # Combine static routes with cfg.services entries.
            routers = {
              # Router for built-in traefik API.
              api = {
                entryPoints = [
                  "web"
                  "websecure"
                ];
                rule = "Host(`traefik.bytemonkey.org`)";
                service = "api@internal";
                tls.certresolver = "letsencrypt";
              };
            }
            // mapAttrs routerEntry cfg.services;

            services = mapAttrs serviceEntry cfg.services;

            middlewares.authelia = {
              # Forward requests w/ middlewares=authelia@file to authelia.
              forwardAuth = {
                address = cfg.autheliaUrl;
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
      traefik-nomad-token.file = ../secrets/traefik-nomad-token.age;
    };

    age-template.files."traefik.env" = {
      vars = {
        cfDnsToken = cfg.cloudflareDnsApiTokenFile;
        consulToken = config.age.secrets.traefik-consul-token.path;
        nomadToken = config.age.secrets.traefik-nomad-token.path;
      };
      content = ''
        CF_DNS_API_TOKEN=$cfDnsToken
        CONSUL_HTTP_TOKEN=$consulToken
        NOMAD_TOKEN=$nomadToken
      '';
    };

    systemd.services.traefik.serviceConfig.EnvironmentFile = [
      config.age-template.files."traefik.env".path
    ];

    # TODO: autogenerate this list from catalog entrypoints
    networking.firewall.allowedTCPPorts = [
      25
      80
      222
      443
      8443
    ];
    networking.firewall.allowedUDPPorts = [
      7777
      15000
      15777
    ];
  };
}
