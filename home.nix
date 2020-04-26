{
  network.description = "Home Services";

  webserver =
    { config, pkgs, lib, ... }:
    let
      mypkgs = import ./pkgs { nixpkgs = pkgs; };
    in with mypkgs;
    {
      services.nginx.enable = true;
      services.nginx.virtualHosts."127.0.0.1" = {
        root = "${website}";
      };

      networking.firewall.allowedTCPPorts = [ 80 ];
    };
}
