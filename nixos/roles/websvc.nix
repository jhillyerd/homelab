{ config, pkgs, lib, catalog, ... }:
with lib;
let
  cfg = config.roles.websvc;

  serviceOptions = with types;
    submodule ({ config, ... }: {
      options = {
        name = mkOption {
          type = str;
          default = config._module.args.name;
          description = "Service host name";
        };

        title = mkOption {
          type = str;
          default = config._module.args.name;
          description = "Friendly name";
        };

        external = mkOption {
          type = bool;
          default = false;
          description = "Expose externally";
        };

        dash = mkOption {
          description = "Dashboard (homesite) config.";
          type = submodule {
            options = {
              icon = mkOption {
                type = nullOr str;
                default = null;
                description = "Icon for homesite entry from fontawesome-free.";
              };

              host = mkOption {
                type = str;
                default = "${config.name}.${cfg.internalDomain}";
              };

              port = mkOption { type = nullOr port; default = null; };
              path = mkOption { type = path; default = "/"; };

              proto = mkOption {
                type = enum [ "http" "https" ];
                default = "https";
              };
            };
          };
          default = { };
        };

        lb = mkOption {
          description = "Loadbalancer (traefik) config.";
          type = nullOr (submodule {
            options = {
              backendUrls = mkOption { type = listOf str; default = [ ]; };
              sticky = mkOption { type = bool; default = false; };
              auth = mkOption {
                type = enum [ "none" "external" "both" ];
                default = "none";
              };
            };
          });
          default = null;
        };
      };
    });
in
{
  options.roles.websvc = with types; {
    enable = mkEnableOption "Enable web services";

    internalDomain = mkOption { type = str; };
    externalDomain = mkOption { type = str; };

    cloudflareDnsApiTokenFile = mkOption {
      type = types.path;
      description = "File containing API token with DNS:Edit permission";
    };

    services = mkOption {
      description = "Web services to expose & dashboard";
      type = attrsOf serviceOptions;
      default = { };
    };

    layout = mkOption {
      description = "Organization of services within dashboard";
      type = listOf (submodule {
        options = {
          section = mkOption { type = str; description = "Section title"; };
          services = mkOption { type = listOf str; description = "Service names to include"; };
        };
      });
    };
  };

  config = mkIf cfg.enable {
    roles.traefik =
      let
        # All services with an `lb` stanza.
        internalConfigs = filterAttrs (n: s: s.lb != null) cfg.services;

        # All services with an `lb` stanza & `external` enabled.
        externalConfigs = filterAttrs (n: s: s.external) internalConfigs;

        mkInternalService = name: opt: {
          inherit name;
          value = {
            # TODO: Internal auth support.
            inherit (opt.lb) backendUrls sticky;
            # TODO: opt.name?
            domainName = "${name}.${cfg.internalDomain}";
          };
        };

        mkExternalService = name: opt: {
          name = name + "-external";
          value = {
            # TODO: don't define a duplicate backend for external.
            inherit (opt.lb) backendUrls sticky;
            domainName = "${name}.${cfg.externalDomain}";
            external = true;
            externalAuth = elem opt.lb.auth [ "external" "both" ];
          };
        };
      in
      {
        enable = true;
        certificateEmail = catalog.cf-api.user;
        cloudflareDnsApiTokenFile = cfg.cloudflareDnsApiTokenFile;
        services = (mapAttrs' mkInternalService internalConfigs) //
          mapAttrs' mkExternalService externalConfigs;
      };

    roles.homesite =
      let
        mkSection = opt: {
          title = opt.section;
          services = map mkServiceEntry opt.services;
        };

        mkServiceEntry = name:
          let opt = cfg.services.${name};
          in
          {
            inherit (opt.dash) icon host path port proto;

            name = opt.title;
          };
      in
      {
        enable = true;
        sections = map mkSection cfg.layout;
      };
  };
}
