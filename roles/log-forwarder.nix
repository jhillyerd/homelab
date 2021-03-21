{ config, pkgs, lib, ... }:
with lib;
let
  cfg = config.roles.log-forwarder;
in
{
  options.roles.log-forwarder = {
    enable = mkEnableOption "Forward system logs";

    syslogHost = mkOption {
      type = types.str;
      description = "Destination syslog host";
      example = "127.0.0.1";
    };

    syslogPort = mkOption {
      type = types.port;
      description = "Destination syslog port";
      example = "514";
    };
  };

  config = mkIf cfg.enable {
    services.syslog-ng = {
      enable = true;

      extraConfig = ''
        source s_local {
          system();
          internal();
        };

        destination d_loki {
          syslog("${cfg.syslogHost}" transport("tcp") port(${toString cfg.syslogPort}));
        };

        log {
          source(s_local);
          destination(d_loki);
        };
      '';
    };
  };
}
