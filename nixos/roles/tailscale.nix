{
  config,
  pkgs,
  lib,
  catalog,
  ...
}:
with lib;
let
  cfg = config.roles.tailscale;
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

      authKeyFile = mkIf cfg.useAuthKey config.age.secrets.tailscale.path;
      extraUpFlags = mkIf cfg.exitNode [ "--advertise-exit-node" ];
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
