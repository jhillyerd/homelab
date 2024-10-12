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
  intProxy = "web.home.arpa.";

  bytemonkeyRecords = {
    "" = {
      type = "NS";
      values = [
        "ns1.bytemonkey.org."
        "ns2.bytemonkey.org."
        "ns3.bytemonkey.org."
      ];
    };

    ns1 = {
      type = "A";
      value = catalog.dns.ns1;
    };
    ns2 = {
      type = "A";
      value = catalog.dns.ns2;
    };
    ns3 = {
      type = "A";
      value = catalog.dns.ns3;
    };

    skynas = {
      type = "A";
      value = "100.126.1.1";
    };
    x = {
      type = "CNAME";
      value = intProxy;
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
// (mapAttrs' (mkExternalServiceRecord intProxy) externalServices)
