{ config, pkgs, lib, ... }:
with lib;
let cfg = config.roles.telegraf;
in {
  options.roles.telegraf = {
    enable = mkEnableOption "Telegraf node";

    influxdb = mkOption {
      type = types.attrs;
      description = "Influxdb output options";
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
          swap = { };
          system = { };
        };

        outputs.influxdb = with cfg.influxdb; {
          inherit urls database;
          username = user;
          password = "$PASSWORD";
        };
      };

      environmentFiles =
        [ config.roles.envfile.files."telegraf-influx.env".file ];
    };

    # Create an environment file containing the influxdb password.
    roles.envfile = {
      files."telegraf-influx.env" = {
        secretPath = cfg.influxdb.passwordFile;
        varName = "PASSWORD";
      };
    };
  };
}
