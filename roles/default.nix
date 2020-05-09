{ config, pkgs, lib, ... }:
{
  imports = [
    ./grafana.nix
    ./homesite.nix
    ./influxdb.nix
    ./telegraf.nix
  ];
}
