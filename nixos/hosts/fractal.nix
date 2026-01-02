{
  self,
  util,
  ...
}:
{
  imports = [ ../common.nix ];

  roles.workstation.enable = true;

  networking.firewall.enable = false;
  systemd.network.networks = util.mkClusterNetworks self;

  # virtualisation.docker.extraOptions = "--data-root /data/docker";
}
