{
  network.description = "Home Services";

  webserver =
    { config, pkgs, ... }:
    let
      website = import ./pkgs/website;
    in
    {
      services.nginx.enable = true;
      services.nginx.virtualHosts."127.0.0.1" = {
        root = "${website}";
      };

      networking.firewall.allowedTCPPorts = [ 80 ];
    };
}
