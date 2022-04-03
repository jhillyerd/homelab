{ pkgs, faasd, ... }: {
  imports = [ faasd.nixosModules.faasd ];

  services.faasd = {
    enable = true;
    basicAuth.enable = false;
  };

  networking.firewall.allowedTCPPorts = [ 8080 ];
}
