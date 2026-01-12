{ ... }:
{
  imports = [
    ./cluster-volumes.nix
    ./consul.nix
    ./dns.nix
    ./gateway-online.nix
    ./gui-sway.nix
    ./gui-xorg.nix
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
    ./upsmon.nix
    ./websvc.nix
    ./workstation.nix
  ];
}
