{
  network.description = "Home Services";

  webserver =
    { config, pkgs, ... }:
    { services.nginx.enable = true;
      services.nginx.virtualHosts."127.0.0.1" =
        { root = "${pkgs.valgrind.doc}/share/doc/valgrind/html";
        };
      networking.firewall.allowedTCPPorts = [ 80 ];
    };
}
