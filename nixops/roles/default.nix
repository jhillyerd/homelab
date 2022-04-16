{ config, pkgs, lib, ... }: {
  imports = [
    ./grafana.nix
    ./homesite.nix
    ./influxdb.nix
    ./log-forwarder.nix
    ./loki.nix
    ./mosquitto.nix
    ./nfs-bind.nix
    ./telegraf.nix
    ./traefik.nix
  ];
}
