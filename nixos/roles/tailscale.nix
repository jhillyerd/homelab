{ config, pkgs, lib, catalog, ... }:
with lib;
let cfg = config.roles.tailscale;
in
{
  options.roles.tailscale = with types; {
    enable = mkEnableOption "Enable Tailscale daemon + autojoin";

    exitNode = mkEnableOption "Register as an exit node";

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

      script = with pkgs;
        let
          exitNode = if cfg.exitNode then "--advertise-exit-node" else "";
        in
        ''
          ts=${tailscale}/bin/tailscale

          # Wait for tailscaled to settle.
          sleep 2

          if $ts status --peers=false >/dev/null; then
            # Already online, do nothing.
            exit 0
          fi

          $ts up -authkey "$(< ${cfg.authkeyPath})" ${exitNode}
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
