{ config, pkgs, lib, ... }: {
  imports = [
    ./envfile.nix
    ./homesite.nix
    ./influxdb.nix
    ./log-forwarder.nix
    ./loki.nix
    ./mosquitto.nix
    ./nomad.nix
    ./nfs-bind.nix
    ./tailscale.nix
    ./telegraf.nix
    ./traefik.nix
    ./workstation.nix
  ];
}
