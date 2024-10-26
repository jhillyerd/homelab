{
  config,
  pkgs,
  lib,
  self,
  catalog,
  ...
}:
with lib;
let
  cfg = config.roles.dns;
in
{
  options.roles.dns = with lib.types; {
    bind = mkOption {
      type = submodule {
        options = {
          enable = mkEnableOption "Run bind DNS server";
          serveLocalZones = mkEnableOption "Serve local zone files directly";
        };
      };
      default = { };
    };
  };

  config =
    let
      namedWorkDir = "/var/lib/named";

      transferAddrs = [
        "192.168.1.0/24"
        "192.168.128.0/18"
      ];

      unifiZones = [
        "dyn.home.arpa."
        "cluster.home.arpa."
      ];

      mkZone = name: rec {
        inherit name;
        file = "${name}.zone";
        path = "${namedWorkDir}/${file}";

        # Barebones zone file that will be overwritten by transfers.
        emptyZone = pkgs.writeText file ''
          $ORIGIN ${name}.
          @ 3600 SOA ns1.${name}. (
            zone-admin.home.arpa.
            1      ; serial number
            3600   ; refresh period
            600    ; retry period
            604800 ; expire time
            1800   ; min TTL
          )

          @   600 IN NS ns1
          ns1 600 IN A  ${catalog.dns.ns1}
        '';
      };

      bytemonkeyZone = mkZone "bytemonkey.org";
      homeZone = mkZone "home.arpa";
    in
    mkIf cfg.bind.enable {
      networking.resolvconf = {
        # 127.0.0.1 is not useful in containers, instead we will use our
        # private IP.
        useLocalResolver = false;
        extraConfig = ''
          name_servers='${self.ip.priv} ${catalog.dns.ns1}'
        '';
      };

      services.bind = mkIf cfg.bind.enable {
        enable = true;

        cacheNetworks = [ "0.0.0.0/0" ];
        forwarders = [
          "1.1.1.1"
          "8.8.8.8"
        ];

        extraOptions = ''
          allow-update { key "rndc-key"; };

          dnssec-validation auto;

          validate-except { "consul"; };
        '';

        zones = builtins.listToAttrs (
          map
            (zone: {
              name = zone.name + ".";
              value =
                if cfg.bind.serveLocalZones then
                  {
                    master = true;
                    slaves = transferAddrs;
                    file = zone.path;
                  }
                else
                  {
                    master = false;
                    masters = [ "${catalog.dns.ns1}" ];
                    file = zone.path;
                  };
            })
            [
              bytemonkeyZone
              homeZone
            ]
        );

        extraConfig =
          let
            unifiForwardZones = concatMapStrings (zone: ''
              zone "${zone}" {
                type forward;
                forward only;
                forwarders { 192.168.1.1; };
              };
            '') unifiZones;
          in
          ''
            zone "consul." IN {
              type forward;
              forward only;
              forwarders { 127.0.0.1 port 8600; };
            };

            ${unifiForwardZones}
          '';
      };

      # Setup named work directory during activation.
      system.activationScripts.init-named-zones =
        let
          copyZone = zone: ''
            # Copy zone file if it does not already exist.
            if [[ ! -e "${zone.path}" ]]; then
              cp "${zone.emptyZone}" "${zone.path}"
              chown named: "${zone.path}"
            fi
          '';
        in
        ''
          mkdir -p ${namedWorkDir}
          chown named: ${namedWorkDir}
        ''
        + (
          if cfg.bind.serveLocalZones then
            ''
              ${copyZone bytemonkeyZone}
              ${copyZone homeZone}
            ''
          else
            ""
        );

      networking.firewall.allowedTCPPorts = [ 53 ];
      networking.firewall.allowedUDPPorts = [ 53 ];
    };
}
