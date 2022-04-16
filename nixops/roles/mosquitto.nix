{ config, pkgs, lib, ... }:
with lib;
let cfg = config.roles.mosquitto;
in {
  options.roles.mosquitto = {
    enable = mkEnableOption "Network Mosquitto host";

    port = mkOption {
      type = types.port;
      description = "Unencrypted MQTT port";
      default = 1883;
    };

    users = mkOption {
      type = types.attrsOf (types.submodule {
        options = {
          password = mkOption {
            type = with types; uniq (nullOr str);
            default = null;
            description = ''
              Specifies the (clear text) password for the MQTT User.
            '';
          };

          hashedPassword = mkOption {
            type = with types; uniq (nullOr str);
            default = null;
            description = ''
              Specifies the hashed password for the MQTT User.
              <option>hashedPassword</option> overrides <option>password</option>.
              To generate hashed password install <literal>mosquitto</literal>
              package and use <literal>mosquitto_passwd</literal>.
            '';
          };

          acl = mkOption {
            type = types.listOf types.str;
            example = [ "read A/B" "topic A/#" ];
            description = ''
              Control client access to topics on the broker.
            '';
          };
        };
      });
      example = {
        john = {
          password = "123456";
          acl = [ "readwrite john/#" ];
        };
      };
      description = ''
        A set of users and their passwords and ACLs.
      '';
    };
  };

  config = mkIf cfg.enable {
    services.mosquitto = {
      enable = true;
      listeners = [{
        port = cfg.port;
        users = cfg.users;
      }];
    };

    networking.firewall.allowedTCPPorts = [ cfg.port ];
  };
}
