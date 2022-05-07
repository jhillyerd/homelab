{ config, pkgs, lib, catalog, ... }:
with lib;
let cfg = config.roles.tailscale;
in {
  options.roles.tailscale = with types; {
    enable = mkEnableOption "Enable Tailscale daemon + autojoin";

    authkeyPath = mkOption {
      type = nullOr path;
      description = "Path to tailscale authkey secret";
      default = null;
    };
  };

  config = mkIf cfg.enable {
    # Enable tailscale daemon.
    services.tailscale = {
      enable = true;
      interfaceName = catalog.tailscale.interface;
    };

    # Create a oneshot job to authenticate to Tailscale.
    systemd.services.tailscale-autoconnect = mkIf (cfg.authkeyPath != null) {
      description = "Automatic connection to Tailscale";

      # Make sure tailscale is running before trying to connect.
      after = [ "network-pre.target" "tailscale.service" ];
      wants = [ "network-pre.target" "tailscale.service" ];
      wantedBy = [ "multi-user.target" ];

      serviceConfig.Type = "oneshot";

      script = with pkgs; ''
        ts=${tailscale}/bin/tailscale

        # Wait for tailscaled to settle.
        sleep 2

        if $ts status --peers=false >/dev/null; then
          # Already online, do nothing.
          exit 0
        fi

        $ts up -authkey "$(< ${cfg.authkeyPath})"
      '';
    };

    networking.firewall = {
      # Trust inbound tailnet traffic.
      trustedInterfaces = [ catalog.tailscale.interface ];

      # Allow tailscale through firewall.
      allowedUDPPorts = [ config.services.tailscale.port ];
    };
  };
}
