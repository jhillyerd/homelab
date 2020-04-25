{
  network.description = "Home Services";

  webserver =
    { config, pkgs, ... }:
    let
      mypkgs = pkgs.callPackage ./pkgs {};
    in with pkgs // mypkgs;
    {
      services.nginx.enable = true;
      services.nginx.virtualHosts."127.0.0.1" = {
        root = "${website}";
      };

      networking.firewall.allowedTCPPorts = [ 80 ];
    };
}
