{ config, pkgs, environment, catalog, ... }: {
  imports = [ ../common.nix ];

  roles.nomad = {
    enableClient = true;
    enableServer = true;
    dataDir = "/data/nomad";

    consulBind = catalog.tailscale.interface;
    consulEncryptPath = config.age.secrets.consul-encrypt.path;
    retryJoin = with catalog.nodes; [ nexus.ip nc-um350-1.ip ];

    nomadEncryptPath = config.age.secrets.nomad-encrypt.path;
  };

  virtualisation.docker.extraOptions = "--data-root /data/docker";

  networking.firewall.enable = false;

  age.secrets = {
    consul-encrypt.file = ../secrets/consul-encrypt.age;
    nomad-encrypt.file = ../secrets/nomad-encrypt.age;
  };
}
