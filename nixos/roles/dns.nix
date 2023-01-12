{ config, pkgs, lib, self, catalog, ... }:
with lib;
let cfg = config.roles.dns;
in
{
  options.roles.dns = {
    enable = mkEnableOption "Run unbound recursive resolver";

    serveLocalZones = mkEnableOption "Serve local zone files";
  };

  # TODO Generate DNS entries from catalog.nodes.
  config =
    let
      unifi-zones = [ "dyn.skynet.local" "cluster.skynet.local" ];

      skynet-zone-file = pkgs.writeText "home.arpa.zone" ''
        $ORIGIN home.arpa.
        @ 3600 SOA nexus.home.arpa. (
          zone-admin.home.arpa.
          2022051501 ; serial number
          3600       ; refresh period
          600        ; retry period
          604800     ; expire time
          1800       ; min TTL
        )

        gateway        600 IN A     192.168.1.1
        printer        600 IN A     192.168.1.5
        fractal        600 IN A     192.168.1.12
        skynas         600 IN A     192.168.1.20
        octopi         600 IN A     192.168.1.21
        homeassistant  600 IN A     192.168.1.30
        ryzen          600 IN A     192.168.1.50

        eph            600 IN A     192.168.128.44
        nc-um350-1     600 IN A     192.168.128.36
        nc-um350-2     600 IN A     192.168.128.37
        nexus          600 IN A     192.168.128.40
        pve1           600 IN A     192.168.128.10
        web            600 IN A     192.168.128.11

        modem          600 IN A     192.168.100.1
      '';
    in
    mkIf cfg.enable {
      networking.resolvconf = {
        # 127.0.0.1 is not useful in containers, instead we will use our
        # private IP.
        useLocalResolver = false;
        extraConfig = ''
          name_servers='${self.ip.priv} ${catalog.dns.host}'
        '';
      };

      services.unbound = {
        enable = true;

        settings = {
          server = {
            interface = [ "0.0.0.0" ];
            access-control = "192.168.0.0/16 allow";

            qname-minimisation = true;
            do-not-query-localhost = false; # for consul.

            # Local domains w/o DNSSEC.
            domain-insecure = unifi-zones ++ [ "consul" "home.arpa" ];

            # Disable built-in default home.arpa zone.
            local-zone = "home.arpa transparent";
          };

          # Configure a forward-zone for each unifi zone.
          forward-zone = map
            (name: {
              inherit name;
              forward-addr = "192.168.1.1";
            })
            unifi-zones;

          # Forward consul zone to local instance.
          stub-zone = [
            { name = "consul"; stub-addr = "127.0.0.1@8600"; }
          ];

          auth-zone = mkIf cfg.serveLocalZones {
            name = "home.arpa.";
            zonefile = "${skynet-zone-file}";
          };
        };
      };

      networking.firewall.allowedTCPPorts = [ 53 ];
      networking.firewall.allowedUDPPorts = [ 53 ];
    };
}
