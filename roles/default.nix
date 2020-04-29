{ config, pkgs, lib, ... }:
{
  imports = [
    ./grafana.nix
    ./influxdb.nix
    ./telegraf.nix
  ];
}
