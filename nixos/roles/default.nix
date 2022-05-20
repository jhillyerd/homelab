{ config, pkgs, lib, ... }: {
  imports = [
    ./dns.nix
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
    ./workstation.nix
  ];
}
