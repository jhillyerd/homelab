{ config, pkgs, lib, ... }:
with lib;
let
  cfg = config.roles.website;
in
{
  options.roles.website = {
    enable = mkEnableOption "Enable website";

    services = mkOption {
      type = with types; listOf (submodule {
        options = {
          name = mkOption {
            type = str;
          };
          host = mkOption {
            type = str;
          };
          port = mkOption {
            type = port;
          };
          path = mkOption {
            type = path;
            default = "/";
          };
          proto = mkOption {
            type = enum [ "http" "https" ];
            default = "https";
          };
        };
      });
      description = "Service links";
      default = [];
    };
  };

  config =
    let
      data = {
        services = cfg.services;
      };

      configDir =
        pkgs.writeTextDir "data.json" (builtins.toJSON data);
    in
    mkIf cfg.enable {
      services.nginx = {
        enable = true;
        virtualHosts."127.0.0.1" = {
          root = "${pkgs.website}";

          locations."/config/" = {
            alias = "${configDir}/";
          };
        };
      };

      networking.firewall.allowedTCPPorts = [ 80 ];
    };
}
