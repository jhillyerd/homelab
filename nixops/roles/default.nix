{ config, pkgs, lib, ... }: {
  imports = [
    ./envfile.nix
    ./grafana.nix
    ./homesite.nix
    ./influxdb.nix
    ./log-forwarder.nix
    ./loki.nix
    ./mosquitto.nix
    ./nfs-bind.nix
    ./telegraf.nix
    ./traefik.nix
    ./workstation.nix
  ];
}
