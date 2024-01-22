# Catalog defines the systems & services on my network.
{ system }: rec {
  nodes = import ./nodes.nix { inherit system; };
  services = import ./services.nix { inherit nodes nomad; };

  # Common config across most machines.
  cf-api.user = "james@hillyerd.com";
  dns.host = nodes.nexus.ip.priv;
  smtp.host = "mail.home.arpa";
  syslog.host = nodes.metrics.ip.priv;
  syslog.port = 1514;
  tailscale.interface = "tailscale0";

  # Role/service specifc configuration.
  authelia = {
    host = nodes.web.ip.priv;
    port = 9091;
  };

  consul = {
    servers = with nodes; [
      nexus.ip.priv
      nc-um350-1.ip.priv
      nc-um350-2.ip.priv
    ];
  };

  k3s = {
    leader = nodes.kube1;
  };

  influxdb = rec {
    host = nodes.metrics.ip.priv;
    port = 8086;
    telegraf.user = "telegraf";
    telegraf.database = "telegraf-hosts";
    urls = [ "http://${host}:${toString port}" ];
  };

  nomad = {
    servers = with nodes; [
      nexus.ip.priv
      nc-um350-1.ip.priv
      nc-um350-2.ip.priv
    ];

    skynas-host-volumes = [
      "gitea-storage"
      "grafana-storage"
      "homeassistant-data"
      "nodered-data"
      "satisfactory-data"
      "waypoint-runner-data"
      "waypoint-server-data"
      "zwavejs-data"
    ];
  };

  # Named TCP/UDP load balancer entry points.
  traefik.entrypoints = {
    factorygame = ":7777/udp";
    factorybeacon = ":15000/udp";
    factoryquery = ":15777/udp";

    smtp = ":25/tcp";
    ssh = ":222/tcp";
    websecure = ":443/tcp";
    extweb = ":8443/tcp";
  };

  # Layout of services on the dashboard.
  layout = [
    {
      section = "Services";
      services = [ "gitea" "grafana" "homeassistant" "inbucket" "nodered" "octopi" ];
    }
    {
      section = "Cluster";
      services = [ "consul" "nomad" "proxmox" "dockreg" ];
    }
    {
      section = "Infrastructure";
      services = [ "modem" "skynas" "traefik" "unifi" "zwavejs" ];
    }
  ];
}
