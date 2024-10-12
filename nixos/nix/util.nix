{ lib, ... }:
{
  # Populate systemd.network.networks given a catalog `self` entry.
  mkClusterNetworks = self: {
    # Hardware config defaults to DHCP, make static if ip.priv is set.
    "10-cluster" = lib.mkIf (self ? ip.priv) {
      networkConfig.DHCP = "no";
      address = [ (self.ip.priv + "/18") ];
      gateway = [ "192.168.128.1" ];

      dns = [
        "192.168.128.36"
        "192.168.128.37"
        "192.168.128.40"
      ];
      domains = [
        "home.arpa"
        "dyn.home.arpa"
      ];
    };
  };
}
