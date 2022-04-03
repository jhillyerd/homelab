{ pkgs, ... }: {
  services.nginx.enable = true;

  networking.firewall.allowedTCPPorts = [ 80 ];
}
