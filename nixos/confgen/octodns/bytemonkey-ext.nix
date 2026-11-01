{ pkgs, catalog, ... }:
target:
let
  inherit (pkgs.lib)
    filterAttrs
    attrByPath
    mapAttrs
    mapAttrs'
    ;

  # Reverse proxy host for internal services.
  intProxy = "web.bytemonkey.org.";

  # Reverse proxy host for external (internet) services.
  extProxy = "x.bytemonkey.org.";

  bytemonkeyRecords = {
    mininas = {
      type = "A";
      value = "100.87.48.66";
    };
    tse = {
      type = "TXT";
      value = "google-site-verification=AuTsq7_HTu2uyAM1L-FDshwDdFfzjtUHyQ2lzXr7UOg";
      ttl = 3600;
    };
    web = {
      type = "A";
      value = catalog.nodes.web.ip.tail;
    };
    x = {
      type = "CNAME";
      value = "home.bytemonkey.org.";
    };
  };

  # Services that requested a CNAME.
  internalServices = filterAttrs (
    n: svc:
    attrByPath [
      "dns"
      "intCname"
    ] false svc
  ) catalog.services;

  # Services to expose outside of our tailnet.
  externalServices = filterAttrs (
    n: svc:
    attrByPath [
      "dns"
      "extCname"
    ] false svc
  ) catalog.services;

  mkInternalServiceRecord = proxy: name: svc: {
    type = "CNAME";
    value = proxy;
  };

  mkExternalServiceRecord = proxy: name: svc: {
    name = "${name}.x";
    value = {
      type = "CNAME";
      value = proxy;
    };
  };
in
bytemonkeyRecords
// (mapAttrs (mkInternalServiceRecord intProxy) internalServices)
// (mapAttrs' (mkExternalServiceRecord extProxy) externalServices)
