{ config, pkgs, lib, ... }: {
  imports = [
    ./cluster-volumes.nix
    ./consul.nix
    ./dns.nix
    ./gateway-online.nix
    ./homesite.nix
    ./influxdb.nix
    ./log-forwarder.nix
    ./loki.nix
    ./mosquitto.nix
    ./nomad.nix
    ./nfs-bind.nix
    ./tailscale.nix
    ./telegraf.nix
    ./template.nix
    ./traefik.nix
    ./websvc.nix
    ./workstation.nix
  ];
}
