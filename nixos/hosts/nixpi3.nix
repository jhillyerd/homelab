{ pkgs, ... }: {
  imports = [ ../common.nix ];

  services.nginx.enable = true;

  networking.firewall.enable = false;
}
