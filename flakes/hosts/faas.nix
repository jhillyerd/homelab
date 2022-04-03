{ pkgs, ... }: {
  networking.firewall.allowedTCPPorts = [ 80 ];
}
