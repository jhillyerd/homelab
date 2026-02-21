{
  config,
  lib,
  microvm,
  ...
}:
with lib;
let
  cfg = config.roles.microvm-host;
in
{
  imports = [
    microvm.nixosModules.host
  ];

  options.roles.microvm-host = {
    enable = mkEnableOption "Can run microVMs";
  };

  config = mkIf cfg.enable {
    microvm.host.enable = true;

    # Configure a bridge and tap interfaces for microVMs to use.
    systemd.network = {
      enable = true;

      netdevs."20-microbr".netdevConfig = {
        Kind = "bridge";
        Name = "microbr";
      };

      networks."20-microbr" = {
        matchConfig.Name = "microbr";
        addresses = [ { Address = "192.168.83.1/24"; } ];
        networkConfig = {
          ConfigureWithoutCarrier = true;
        };
      };

      networks."21-microvm-tap" = {
        matchConfig.Name = "microvm*";
        networkConfig.Bridge = "microbr";
      };
    };

    networking.nat = {
      enable = true;
      internalInterfaces = [ "microbr" ];
      # externalInterface = "wlp0s20f3";
    };

    # Tell NetworkManager to leave microvm interfaces alone
    networking.networkmanager.unmanaged = [
      "interface-name:microbr"
      "interface-name:microvm*"
    ];
  };
}
