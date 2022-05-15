{ config, pkgs, lib, ... }:
with lib;
let cfg = config.roles.dns;
in
{
  options.roles.dns = {
    enable = mkEnableOption "Forward system logs";

    serveLocalZones = mkEnableOption "Serve local zone files";
  };

  config =
    let
      unifi-zones = [ "dyn.skynet.local" "cluster.skynet.local" ];

      skynet-zone-file = pkgs.writeText "skynet.local.zone" ''
        $ORIGIN skynet.local.
        @ 3600 SOA nexus.skynet.local. (
          zone-admin.skynet.local.
          2022051501 ; serial number
          3600       ; refresh period
          600        ; retry period
          604800     ; expire time
          1800       ; min TTL
        )

        gateway     600 IN A     192.168.1.1
        nexus       600 IN A     192.168.1.10
        fractal     600 IN A     192.168.1.12
        skynas      600 IN A     192.168.1.20
        octopi      600 IN A     192.168.1.21
        ryzen       600 IN A     192.168.1.50

        nc-um350-1  600 IN A     192.168.128.36
        nc-um350-2  600 IN A     192.168.128.37

        modem       600 IN A     192.168.100.1
      '';
    in
    mkIf cfg.enable {
      services.unbound = {
        enable = true;

        settings = {
          server = {
            interface = [ "0.0.0.0" ];
            access-control = "192.168.0.0/16 allow";

            qname-minimisation = true;

            # Local domains w/o DNSSEC.
            domain-insecure = unifi-zones;
          };

          # Configure a forward-zone for each unifi zone.
          forward-zone = map
            (name: {
              inherit name;
              forward-addr = "192.168.1.1";
            })
            unifi-zones;

          auth-zone = mkIf cfg.serveLocalZones {
            name = "skynet.local.";
            zonefile = "${skynet-zone-file}";
          };
        };
      };

      networking.firewall.allowedTCPPorts = [ 53 ];
      networking.firewall.allowedUDPPorts = [ 53 ];
    };
}
