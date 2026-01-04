{
  config,
  pkgs,
  lib,
  ...
}:
let
  inherit (lib)
    mkEnableOption
    mkIf
    mkOption
    length
    ;
  inherit (lib.types)
    attrs
    bool
    listOf
    str
    ;

  cfg = config.roles.telegraf;
in
{
  options.roles.telegraf = {
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

    x509_certs = mkOption {
      type = listOf str;
      description = "List of URLs to monitor for certificate expiration";
      default = [ ];
    };

    zfs = mkOption {
      type = bool;
      description = "Collect ZFS snapshot metrics";
      default = false;
    };
  };

  config = mkIf cfg.enable {
    services.telegraf = {
      enable = true;

      extraConfig = {
        inputs = {
          cpu = {
            percpu = true;
          };
          disk = { };
          kernel = { };
          mem = { };
          net = { };
          netstat = { };
          processes = { };
          swap = { };
          system = { };

          http_response = mkIf (length cfg.http_response > 0) (
            map (a: a // { interval = "30s"; }) cfg.http_response
          );

          ping = mkIf (length cfg.ping > 0) (
            map (host: {
              urls = [ host ];
              interval = "30s";
              binary = "${pkgs.iputils}/bin/ping";
            }) cfg.ping
          );

          nomad = mkIf (cfg.nomad) {
            url = "https://127.0.0.1:4646";
            insecure_skip_verify = true;
          };

          x509_cert = mkIf (length cfg.x509_certs > 0) {
            sources = cfg.x509_certs;
            interval = "5m";
          };

          exec = mkIf (cfg.zfs) {
            commands = [ ./files/telegraf/zfs_snap_times.py ];
            timeout = "5s";
            data_format = "influx";
            environment = [ "PATH=/run/current-system/sw/bin" ];
          };
        };

        outputs.influxdb = with cfg.influxdb; {
          inherit urls database;
          username = user;
          password = "$PASSWORD";
        };
      };

      environmentFiles = [ config.age-template.files."telegraf-influx.env".path ];
    };

    # Create an environment file containing the influxdb password.
    age-template.files."telegraf-influx.env" = {
      vars.password = cfg.influxdb.passwordFile;
      content = ''PASSWORD=$password'';
    };
  };
}
