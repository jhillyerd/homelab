{ nodes, nomad }: {
  # The services block populates my dashboard and configures the load balancer.
  #
  # The key-name of each service block is mapped to an internal domain name
  # <key>.bytemonkey.org and an external domain name <key>.x.bytemonkey.org.
  #
  # If the `lb` section is unspecified, then it is assumed the configuration
  # has been provided by tags in consul. Untagged services can be specified
  # using the dash.(host|port|proto|path) attributes.
  #
  # Authelia is configured to deny by default; services will need to be
  # configured there before being available externally.
  auth = {
    title = "Authelia";
    external = true;

    dns.intCname = true;
    dns.extCname = true;

    lb.backendUrls = [ "http://127.0.0.1:9091" ];
    lb.auth = "none";
  };

  consul = {
    title = "Consul";

    dash.icon = "address-book";
    dash.host = nodes.nexus.ip.priv;
    dash.port = 8500;
    dash.proto = "http";
  };

  dash = {
    title = "Dashboard";
    dns.intCname = true;
    lb.backendUrls = [ "http://127.0.0.1:12701" ];
  };

  dockreg = {
    title = "Docker Registry";

    dns.intCname = true;

    dash.icon = "brands fa-docker";
    dash.host = "dockreg.bytemonkey.org";
    dash.path = "/v2/_catalog";

    lb.backendUrls = [ "http://192.168.1.20:5050" ];
  };

  gitea = {
    title = "Gitea";

    dns.intCname = true;
    dns.extCname = true;

    dash.icon = "code-branch";
    # Note: external + auth handled by labels.
  };

  grafana = {
    title = "Grafana";

    dns.intCname = true;
    dns.extCname = true;

    dash.icon = "chart-area";
    # Note: external + auth handled by labels.
  };

  homeassistant = {
    title = "Home Assistant";

    dns.intCname = true;

    dash.host = "homeassistant.bytemonkey.org";
    dash.icon = "home";

    lb.backendUrls = [ "http://192.168.1.30:8123" ];
  };

  inbucket = {
    title = "Inbucket";
    dns.intCname = true;
    dash.icon = "at";
  };

  modem = {
    title = "Cable Modem";

    dash.icon = "satellite-dish";
    dash.host = "192.168.100.1";
    dash.proto = "http";
  };

  monolith = {
    title = "Monolith";
    dns.intCname = true;
  };

  nodered = {
    title = "Node-RED";
    dns.intCname = true;
    dash.icon = "project-diagram";
  };

  nomad = {
    title = "Nomad";
    external = true;

    dns.intCname = true;
    dns.extCname = true;

    dash.icon = "server";

    lb.backendUrls = map (ip: "https://${ip}:4646") nomad.servers;
    lb.sticky = true;
    lb.auth = "external";
  };

  octopi = {
    title = "OctoPrint";
    dns.intCname = true;
    dash.icon = "cube";
    lb.backendUrls = [ "http://192.168.1.21" ];
  };

  proxmox = {
    title = "Proxmox VE";
    dns.intCname = true;
    dash.icon = "terminal";
    lb.backendUrls = [ "https://192.168.128.10:8006" ];
  };

  skynas = {
    title = "SkyNAS";
    dns.intCname = true;
    dash.icon = "hdd";
    lb.backendUrls = [ "https://192.168.1.20:5001" ];
  };

  traefik = {
    title = "Traefik";

    dns.intCname = true;

    dash.icon = "traffic-light";
    dash.host = "traefik.bytemonkey.org";
    dash.path = "/dashboard/";
  };

  unifi = {
    title = "UniFi";
    external = true;

    dns.intCname = true;
    dns.extCname = true;

    dash.icon = "network-wired";

    lb.backendUrls = [ "https://192.168.1.20:8443" ];
    lb.auth = "external";
  };
}
