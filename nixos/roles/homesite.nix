{ config, pkgs, lib, homesite, ... }:
with lib;
let cfg = config.roles.homesite;
in
{
  options.roles.homesite = {
    enable = mkEnableOption "Enable home website";

    sections = with types; mkOption {
      type = listOf (submodule {
        options = {
          title = mkOption { type = str; };
          services = mkOption {
            type = with types;
              listOf (submodule {
                options = {
                  name = mkOption { type = str; };
                  host = mkOption { type = str; };
                  port = mkOption {
                    type = nullOr port;
                    default = null;
                  };
                  path = mkOption {
                    type = path;
                    default = "/";
                  };
                  proto = mkOption {
                    type = enum [ "http" "https" ];
                    default = "https";
                  };
                  icon = mkOption { type = str; };
                };
              });
            description = "Service links";
            default = [ ];
          };
        };
      });
      default = [ ];
    };
  };

  config =
    let
      data = { sections = cfg.sections; };

      configDir = pkgs.writeTextDir "data.json" (builtins.toJSON data);
    in
    mkIf cfg.enable {
      services.nginx = {
        enable = true;
        virtualHosts."homesite" = {
          root = "${homesite.defaultPackage.x86_64-linux}"; # From flake

          locations."/config/" = { alias = "${configDir}/"; };

          listen = [{
            addr = "0.0.0.0";
            port = 12701;
            ssl = false;
          }];
        };
      };

      networking.firewall.allowedTCPPorts = [ 12701 ];
    };
}
