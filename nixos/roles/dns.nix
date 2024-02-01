{ config, pkgs, lib, self, catalog, ... }:
with lib;
let cfg = config.roles.dns;
in
{
  options.roles.dns = with lib.types; {
    bind = mkOption {
      type = submodule {
        options = {
          enable = mkEnableOption "Run bind DNS server";
          serveLocalZones = mkEnableOption "Serve local zone files";
        };
      };
      default = { };
    };
  };

  # TODO Generate DNS entries from catalog.nodes.
  config =
    let
      transferAddrs = [ "192.168.1.0/24" "192.168.128.0/18" ];

      unifiZones = [ "dyn.home.arpa" "cluster.home.arpa" ];

      bytemonkeyZoneFile = "/var/lib/named/bytemonkey.org.zone";
      bytemonkeyZoneConfig = pkgs.writeText "bytemonkey.org.zone" ''
        $ORIGIN bytemonkey.org.
        @ 3600 SOA nexus.home.arpa. (
          zone-admin.home.arpa.
          1          ; serial number
          3600       ; refresh period
          600        ; retry period
          604800     ; expire time
          1800       ; min TTL
        )

        @              600 IN NS    ns1
        ns1            600 IN A     192.168.128.40
      '';

      homeZoneConfig = pkgs.writeText "home.arpa.zone" ''
        $ORIGIN home.arpa.
        @ 3600 SOA nexus.home.arpa. (
          zone-admin.home.arpa.
          2024012901 ; serial number
          3600       ; refresh period
          600        ; retry period
          604800     ; expire time
          1800       ; min TTL
        )

        @              600 IN NS    ns1
        ns1            600 IN A     192.168.128.40

        cluster        600 IN NS    gateway
        dyn            600 IN NS    gateway

        dockreg        600 IN CNAME web
        mail           600 IN CNAME web
        mqtt           600 IN CNAME metrics
        ntp            600 IN CNAME skynas

        gateway        600 IN A     192.168.1.1
        printer        600 IN A     192.168.1.5
        skynas         600 IN A     192.168.1.20
        octopi         600 IN A     192.168.1.21
        nc-pi3-1       600 IN A     192.168.1.22
        homeassistant  600 IN A     192.168.1.30
        ryzen          600 IN A     192.168.1.50

        modem          600 IN A     192.168.100.1

        ; Cluster subnet

        eph            600 IN A     192.168.128.44
        metrics        600 IN A     192.168.128.41
        nc-um350-1     600 IN A     192.168.128.36
        nc-um350-2     600 IN A     192.168.128.37
        nexus          600 IN A     192.168.128.40
        pve1           600 IN A     192.168.128.10
        pve2           600 IN A     192.168.128.12
        pve3           600 IN A     192.168.128.13
        web            600 IN A     192.168.128.11

        scratch        600 IN A     192.168.131.2
        witness        600 IN A     192.168.131.3

        kube1          600 IN A     192.168.132.1
        kube2          600 IN A     192.168.132.2
        kube3          600 IN A     192.168.132.3
      '';
    in
    mkIf cfg.bind.enable {
      networking.resolvconf = {
        # 127.0.0.1 is not useful in containers, instead we will use our
        # private IP.
        useLocalResolver = false;
        extraConfig = ''
          name_servers='${self.ip.priv} ${catalog.dns.host}'
        '';
      };

      services.bind = mkIf cfg.bind.enable {
        enable = true;

        cacheNetworks = [ "0.0.0.0/0" ];
        forwarders = [ "1.1.1.1" "8.8.8.8" ];

        extraOptions = ''
          allow-update { key "rndc-key"; };

          dnssec-validation auto;

          validate-except { "consul"; };
        '';

        zones = mkIf cfg.bind.serveLocalZones {
          "home.arpa" = {
            master = true;
            slaves = transferAddrs;
            file = "${homeZoneConfig}";
          };

          "bytemonkey.org." = {
            master = true;
            slaves = transferAddrs;
            file = "${bytemonkeyZoneFile}";
          };
        };

        extraConfig =
          let
            unifiForwardZones = concatMapStrings
              (zone: ''
                zone "${zone}" {
                  type forward;
                  forward only;
                  forwarders { 192.168.1.1; };
                };
              '')
              unifiZones;

            localForwardZones =
              if cfg.bind.serveLocalZones then
                ""
              else
                (concatMapStrings
                  (zone: ''
                    zone "${zone}" {
                      type forward;
                      forward only;
                      forwarders { ${catalog.dns.host}; };
                    };
                  '')
                  [ "home.arpa" ]);
          in
          ''
            zone "consul" IN {
              type forward;
              forward only;
              forwarders { 127.0.0.1 port 8600; };
            };

            ${unifiForwardZones}

            ${localForwardZones}
          '';
      };

      # Setup named work directory during activation.
      system.activationScripts.init-named-zones = ''
        mkdir -p /var/lib/named
        chown named: /var/lib/named

        # Copy zone file if it does not already exist.
        if [[ ! -e "${bytemonkeyZoneFile}" ]]; then
          cp "${bytemonkeyZoneConfig}" "${bytemonkeyZoneFile}"
          chown named: "${bytemonkeyZoneFile}"
        fi
      '';

      networking.firewall.allowedTCPPorts = [ 53 ];
      networking.firewall.allowedUDPPorts = [ 53 ];
    };
}
