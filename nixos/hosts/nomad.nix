{ config, pkgs, environment, catalog, ... }: {
  imports = [ ../common.nix ];

  roles.nomad.enableClient = true;
  roles.nomad.enableServer = true;
  roles.nomad.consulBind = catalog.tailscale.interface;
  roles.nomad.consulEncryptPath = config.age.secrets.consul-encrypt.path;
  roles.nomad.retryJoin = [ "100.126.18.23" "100.81.177.34" "100.111.127.85" ];

  networking.firewall.enable = false;

  age.secrets = {
    consul-encrypt.file = ../secrets/consul-encrypt.age;
  };
}
