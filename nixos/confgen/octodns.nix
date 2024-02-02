{ pkgs, catalog, ... }:
let
  inherit (pkgs.lib) filterAttrs attrByPath mapAttrs;

  # Nameserver to push records to.
  target = catalog.dns.ns1;

  # Reverse proxy host for internal services.
  intHost = "web.home.arpa";

  bytemonkeyRecords = {
    "".type = "NS";
    "".values = [
      "ns1.bytemonkey.org."
      "ns2.bytemonkey.org."
      "ns3.bytemonkey.org."
    ];

    ns1.type = "A";
    ns1.value = catalog.dns.ns1;
    ns2.type = "A";
    ns2.value = catalog.dns.ns2;
    ns3.type = "A";
    ns3.value = catalog.dns.ns3;
  };

  # Services that requested a CNAME.
  internalServices = filterAttrs (n: svc: attrByPath [ "dns" "intCname" ] false svc) catalog.services;

  mkInternalServiceRecord = name: svc: {
    type = "CNAME";
    value = intHost + ".";
  };
in
{
  "octodns/config.yaml" = {
    manager = {
      max_workers = 1;
      enable_checksum = true;
      processors = [ "meta" ];
    };

    providers = {
      zones = {
        class = "octodns.provider.yaml.YamlProvider";
        directory = "./zones";
        default_ttl = 600;
        enforce_order = true;
      };

      nexus_bind = {
        class = "octodns_bind.Rfc2136Provider";
        host = target;
        key_name = "env/BIND_KEY_NAME";
        key_secret = "env/BIND_KEY_SECRET";
      };
    };

    zones = {
      "bytemonkey.org." = {
        sources = [ "zones" ];
        targets = [ "nexus_bind" ];
      };
    };

    processors = {
      meta = {
        class = "octodns.processor.meta.MetaProcessor";
        record_name = "octodns-meta";
        include_provider = true;
      };
    };
  };

  "octodns/zones/bytemonkey.org.yaml" = bytemonkeyRecords
    // (mapAttrs mkInternalServiceRecord internalServices);
}
