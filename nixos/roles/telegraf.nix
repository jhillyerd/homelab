{ config, pkgs, lib, ... }:
with lib;
let cfg = config.roles.telegraf;
in
{
  options.roles.telegraf = with types; {
    enable = mkEnableOption "Telegraf node";

    influxdb = mkOption {
      type = attrs;
      description = "Influxdb output options";
    };

    http_response = mkOption {
      type = listOf attrs;
      description = "Telegraf http_response monitoring input config";
      default = [ ];
    };

    ping = mkOption {
      type = listOf str;
      description = "List of hosts for telegraf to ping";
      default = [ ];
    };

    nomad = mkOption {
      type = bool;
      description = "Scrape local nomad metrics exposed via prometheus";
      default = false;
    };
  };

  config = mkIf cfg.enable {
    services.telegraf = {
      enable = true;

      extraConfig = {
        inputs = {
          cpu = { percpu = true; };
          disk = { };
          kernel = { };
          mem = { };
          net = { };
          netstat = { };
          processes = { };
          swap = { };
          system = { };

          http_response = mkIf (length cfg.http_response > 0)
            (map
              (a: a // {
                interval = "30s";
              })
              cfg.http_response);

          ping = mkIf (length cfg.ping > 0)
            (map
              (host: {
                urls = [ host ];
                interval = "30s";
                binary = "${pkgs.iputils}/bin/ping";
              })
              cfg.ping);

          nomad = mkIf (cfg.nomad) {
            url = "https://127.0.0.1:4646";
            insecure_skip_verify = true;
          };
        };

        outputs.influxdb = with cfg.influxdb; {
          inherit urls database;
          username = user;
          password = "$PASSWORD";
        };
      };

      environmentFiles =
        [ config.roles.template.files."telegraf-influx.env".path ];
    };

    # Create an environment file containing the influxdb password.
    roles.template.files."telegraf-influx.env" = {
      vars.password = cfg.influxdb.passwordFile;
      content = ''PASSWORD=$password'';
    };
  };
}
