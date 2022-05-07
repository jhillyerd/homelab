{ config, pkgs, environment, catalog, ... }: {
  imports = [ ../common.nix ];

  roles.nomad = {
    enableClient = true;
    enableServer = true;

    consulBind = catalog.tailscale.interface;
    consulEncryptPath = config.age.secrets.consul-encrypt.path;
    retryJoin = [ "100.126.18.23" "100.81.177.34" "100.111.127.85" ];

    nomadEncryptPath = config.age.secrets.nomad-encrypt.path;
  };

  networking.firewall.enable = false;

  age.secrets = {
    consul-encrypt.file = ../secrets/consul-encrypt.age;
    nomad-encrypt.file = ../secrets/nomad-encrypt.age;
  };
}
