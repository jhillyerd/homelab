{ pkgs, catalog, ... }:
let
  inherit (pkgs.lib) filterAttrs attrByPath mapAttrs;

  # Reverse proxy host for internal services.
  intHost = "web.bytemonkey.org";

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
      include_meta = true;
      max_workers = 1;
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
        host = catalog.nodes.nexus.ip.priv;
      };
    };

    zones = {
      "bytemonkey.org." = {
        sources = [ "zones" ];
        targets = [ "nexus_bind" ];
      };
    };
  };

  "octodns/zones/bytemonkey.org.yaml" = (mapAttrs mkInternalServiceRecord internalServices);
}
