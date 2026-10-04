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

  roles.consul = {
    client = {
      enable = true;
      connect = true;
    };
  };

  roles.nomad = {
    enableClient = true;
    client.allocDir = "/data/nomad-alloc";
  };

  # Host metrics for NFS path monitoring (see nfs-path-monitoring-plan):
  # the mountstats collector exposes per-mount NFS RPC stats, and being a
  # host service it keeps reporting during a nomad outage.
  services.prometheus.exporters.node = {
    enable = true;
    enabledCollectors = [ "mountstats" ];
    openFirewall = true; # 9100; firewall is currently disabled anyway
  };

  roles.telegraf.nomad = true;

  roles.gateway-online.addr = "192.168.1.1";

  virtualisation.docker.daemon.settings = {
    data-root = "/data/docker";
  };

  networking.firewall.enable = false;

  roles.upsmon = {
    enable = true;
    wave = 1;
  };
}
