{ pkgs, ... }: {
  imports = [ ../common.nix ];

  services.nginx.enable = true;

  virtualisation.docker.enable = true;

  networking.firewall.allowedTCPPorts = [ 80 ];
}
