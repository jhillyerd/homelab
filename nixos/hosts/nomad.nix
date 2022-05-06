{ config, pkgs, environment, ... }: {
  imports = [ ../common.nix ];

  roles.nomad.enableClient = true;
  roles.nomad.enableServer = true;
  roles.nomad.consulBind = "eth0";
  roles.nomad.retryJoin = [ "192.168.1.251" "192.168.1.252" "192.168.1.253"];

  networking.firewall.enable = false;
}
