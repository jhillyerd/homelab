{
  config,
  pkgs,
  lib,
  ...
}:
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

    enableTcpListener = mkEnableOption "Forward logs from TCP clients";
  };

  config = mkIf cfg.enable {
    services.syslog-ng = {
      enable = true;

      extraConfig =
        let
          base = ''
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

          netListener =
            if cfg.enableTcpListener then
              ''
                source s_net {
                  tcp(ip(0.0.0.0) port(514));
                };

                log {
                  source(s_net);
                  destination(d_loki);
                };
              ''
            else
              "";
        in
        concatStringsSep "\n" [
          base
          netListener
        ];
    };

    networking.firewall.allowedTCPPorts = mkIf cfg.enableTcpListener [ 514 ];
  };
}
