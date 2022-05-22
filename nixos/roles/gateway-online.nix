{ config, pkgs, lib, ... }:
with lib;
let cfg = config.roles.gateway-online;
in
{
  options.roles.gateway-online = {
    addr = mkOption {
      type = types.nullOr types.str;
      description = "Name or address of gateway to ping";
      default = null;
    };
  };

  config = mkIf (cfg.addr != null) {
    # Delay network-online.target until gateway address is pingable.
    systemd.services."gateway-online" = {
      enable = true;
      before = [ "network-online.target" ];
      after = [ "nss-lookup.target" ];
      wantedBy = [ "network-online.target" ];

      unitConfig = {
        DefaultDependencies = "no";
      };

      serviceConfig = {
        ExecStart = ''
          /bin/sh -c "while ! ping -c 1 ${escapeShellArg cfg.addr}; do sleep 1; done"
        '';
      };
    };
  };
}
