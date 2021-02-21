{ config, pkgs, lib, ... }:
{
  imports = [
    ./grafana.nix
    ./homesite.nix
    ./influxdb.nix
    ./mosquitto.nix
    ./telegraf.nix
  ];
}
