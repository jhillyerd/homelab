{ config, pkgs, lib, catalog, ... }:
with lib;
let cfg = config.roles.tailscale;
in
{
  options.roles.tailscale = with types; {
    enable = mkEnableOption "Enable Tailscale daemon";

    exitNode = mkEnableOption "Register as an exit node";

    useAuthKey = mkOption {
      type = bool;
      description = "Use secrets/tailscale.age for auto-join key";
      default = true;
    };
  };

  config = mkIf cfg.enable {
    # Enable tailscale daemon.
    services.tailscale = {
      enable = true;
      interfaceName = catalog.tailscale.interface;
    };

    # Create a oneshot job to authenticate to Tailscale.
    systemd.services.tailscale-autoconnect = mkIf cfg.useAuthKey {
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

          $ts up -authkey "$(< ${config.age.secrets.tailscale.path})" ${exitNode}
        '';
    };

    age.secrets.tailscale.file = mkIf cfg.useAuthKey ../secrets/tailscale.age;

    networking.firewall = {
      # Trust inbound tailnet traffic.
      trustedInterfaces = [ catalog.tailscale.interface ];

      # Allow tailscale through firewall.
      allowedUDPPorts = [ config.services.tailscale.port ];
    };
  };
}
