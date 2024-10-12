{ pkgs, catalog, ... }:
target:
let
  inherit (pkgs.lib) filterAttrs mapAttrs;

  homeRecords = {
    "" = {
      type = "NS";
      values = [
        "ns1.home.arpa."
        "ns2.home.arpa."
        "ns3.home.arpa."
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
    cluster = {
      type = "NS";
      value = "gateway.home.arpa.";
    };
    dyn = {
      type = "NS";
      value = "gateway.home.arpa.";
    };

    mail = {
      type = "CNAME";
      value = "web.home.arpa.";
    };
    mqtt = {
      type = "CNAME";
      value = "metrics.home.arpa.";
    };
    ntp = {
      type = "CNAME";
      value = "skynas.home.arpa.";
    };

    # Default network.
    gateway = {
      type = "A";
      value = "192.168.1.1";
    };
    printer = {
      type = "A";
      value = "192.168.1.5";
    };
    skynas = {
      type = "A";
      value = "192.168.1.20";
    };
    octopi = {
      type = "A";
      value = "192.168.1.21";
    };
    homeassistant = {
      type = "A";
      value = "192.168.1.30";
    };

    modem = {
      type = "A";
      value = "192.168.100.1";
    };

    # IoT network.
    msdde3 = {
      type = "A";
      value = "192.168.10.23";
    };

    # Cluster network.
    pve1 = {
      type = "A";
      value = "192.168.128.10";
    };
    pve2 = {
      type = "A";
      value = "192.168.128.12";
    };
    pve3 = {
      type = "A";
      value = "192.168.128.13";
    };
    "*.k" = {
      type = "CNAME";
      value = "kube1.home.arpa.";
    };
  };

  ipPrivNodes = filterAttrs (n: v: v ? ip.priv) catalog.nodes;

  mkNodeRecord = name: node: {
    type = "A";
    value = node.ip.priv;
  };

  nodeRecords = mapAttrs mkNodeRecord ipPrivNodes;
in
homeRecords // nodeRecords
