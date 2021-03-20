{ config, pkgs, lib, ... }:
{
  imports = [
    ./grafana.nix
    ./homesite.nix
    ./influxdb.nix
    ./loki.nix
    ./mosquitto.nix
    ./telegraf.nix
  ];
}
