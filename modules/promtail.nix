{ config, lib, pkgs, ... }:

let
  inherit (lib) escapeShellArgs literalExample mkEnableOption mkIf mkOption types;

  cfg = config.services.promtail;

  prettyJSON = conf:
    pkgs.runCommand "promtail-config.json" { } ''
      echo '${builtins.toJSON conf}' | ${pkgs.jq}/bin/jq 'del(._module)' > $out
    '';

in {
  options.services.promtail = {
    enable = mkEnableOption "promtail";

    user = mkOption {
      type = types.str;
      default = "promtail";
      description = ''
        User under which the Promtail service runs.
      '';
    };

    group = mkOption {
      type = types.str;
      default = "promtail";
      description = ''
        Group under which the Promtail service runs.
      '';
    };

    dataDir = mkOption {
      type = types.path;
      default = "/var/lib/promtail";
      description = ''
        Specify the directory for Promtail.
      '';
    };

    configuration = mkOption {
      type = (pkgs.formats.json {}).type;
      default = {};
      description = ''
        Specify the configuration for Promtail in Nix.
      '';
    };

    configFile = mkOption {
      type = types.nullOr types.path;
      default = null;
      description = ''
        Specify a configuration file that Promtail should use.
      '';
    };

    extraFlags = mkOption {
      type = types.listOf types.str;
      default = [];
      example = literalExample [ "-server.http-listen-port=3101" ];
      description = ''
        Specify a list of additional command line flags,
        which get escaped and are then passed to Promtail.
      '';
    };
  };

  config = mkIf cfg.enable {
    assertions = [{
      assertion = (
        (cfg.configuration == {} -> cfg.configFile != null) &&
        (cfg.configFile != null -> cfg.configuration == {})
      );
      message  = ''
        Please specify either
        'services.promtail.configuration' or
        'services.promtail.configFile'.
      '';
    }];

    users.groups.${cfg.group} = { };
    users.users.${cfg.user} = {
      description = "Promtail Service User";
      group = cfg.group;
      home = cfg.dataDir;
      createHome = true;
      isSystemUser = true;
    };

    systemd.services.promtail = {
      description = "Promtail Service Daemon";
      wantedBy = [ "multi-user.target" ];

      # Forces promtail to be stopped before loki, preventing retry hang.
      after = [ "loki.service" ];

      serviceConfig = let
        conf = if cfg.configFile == null
               then prettyJSON cfg.configuration
               else cfg.configFile;
      in
      {
        ExecStart = ''
          ${pkgs.grafana-loki}/bin/promtail -config.file=${conf} -positions.file="${cfg.dataDir}/positions.yaml" ${escapeShellArgs cfg.extraFlags}
        '';
        User = cfg.user;
        Restart = "always";
        PrivateTmp = true;
        ProtectHome = true;
        ProtectSystem = "full";
        DevicePolicy = "closed";
        NoNewPrivileges = true;
        WorkingDirectory = cfg.dataDir;
      };
    };
  };
}
