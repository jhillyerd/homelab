# A scratch host for building up new service configurations.
{
  self,
  util,
  ...
}:
{
  imports = [
    ../common.nix
    ../common/onprem.nix
  ];

  systemd.network.networks = util.mkClusterNetworks self;
  roles.gateway-online.addr = "192.168.1.1";
  networking.firewall.enable = false;

  ### Temporary configuration below.
}
