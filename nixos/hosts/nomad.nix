{ config, pkgs, environment, ... }: {
  imports = [ ../common.nix ];

  roles.nomad-server.enable = true;
  roles.nomad-server.retryJoin = [ "192.168.1.251" "192.168.1.252" "192.168.1.253"];

  roles.nomad-client.enable = true;

  networking.firewall.enable = false;
}
