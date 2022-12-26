# Catalog defines the systems & services on my network.
{ system }: rec {
  nodes = {
    fractal = {
      ip.priv = "192.168.1.12";
      ip.tail = "100.112.232.73";
      config = ./hosts/fractal.nix;
      hw = ./hw/asus-b350.nix;
      system = system.x86_64-linux;
    };

    nc-um350-1 = {
      ip.priv = "192.168.128.36";
      ip.tail = "100.109.33.10";
      config = ./hosts/nc-um350.nix;
      hw = ./hw/minis-um350.nix;
      system = system.x86_64-linux;
    };

    nc-um350-2 = {
      ip.priv = "192.168.128.37";
      ip.tail = "100.97.169.111";
      config = ./hosts/nc-um350.nix;
      hw = ./hw/minis-um350.nix;
      system = system.x86_64-linux;
    };

    nexus = {
      ip.priv = "192.168.1.10";
      ip.tail = "100.80.202.97";
      config = ./hosts/nexus.nix;
      hw = ./hw/cubi.nix;
      system = system.x86_64-linux;
    };

    nixpi3 = {
      config = ./hosts/nixpi3.nix;
      hw = ./hw/sd-image-pi3.nix;
      system = system.aarch64-linux;
    };

    scratch = {
      ip.priv = "10.0.2.15";
      config = ./hosts/scratch.nix;
      hw = ./hw/qemu.nix;
      system = system.x86_64-linux;
    };
  };

  influxdb = rec {
    host = nodes.nexus.ip.priv;
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
      "nodered-data"
      "satisfactory-data"
      "waypoint-runner-data"
      "waypoint-server-data"
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


  cf-api.user = "james@hillyerd.com";

  dns.host = nodes.nexus.ip.priv;

  syslog.host = nodes.nexus.ip.priv;
  syslog.port = 1514;

  smtp.host = nodes.nexus.ip.priv;

  tailscale.interface = "tailscale0";

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
  services = {
    auth = {
      title = "Authelia";
      external = true;
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
      lb.backendUrls = [ "http://127.0.0.1:12701" ];
    };

    dockreg = {
      title = "Docker Registry";
      dash.icon = "brands fa-docker";
      dash.host = "dockreg.bytemonkey.org";
      dash.path = "/v2/_catalog";

      lb.backendUrls = [ "http://192.168.1.20:5050" ];
    };

    gitea = {
      title = "Gitea";
      dash.icon = "code-branch";
    };

    grafana = {
      title = "Grafana";
      dash.icon = "chart-area";
      # Note: external + auth handled by labels.
    };

    homeassistant = {
      title = "Home Assistant";
      dash.host = "homeassistant.bytemonkey.org";
      dash.icon = "home";

      lb.backendUrls = [ "http://192.168.1.30:8123" ];
    };

    inbucket = {
      title = "Inbucket";
      dash.icon = "at";
    };

    modem = {
      title = "Cable Modem";
      dash.icon = "satellite-dish";
      dash.host = "192.168.100.1";
      dash.proto = "http";
    };

    nodered = {
      title = "Node-RED";
      dash.icon = "project-diagram";
    };

    nomad = {
      title = "Nomad";
      external = true;
      dash.icon = "server";

      lb.backendUrls = map (ip: "https://${ip}:4646") nomad.servers;
      lb.sticky = true;
      lb.auth = "external";
    };

    octopi = {
      title = "OctoPrint";
      dash.icon = "cube";

      lb.backendUrls = [ "http://192.168.1.21" ];
    };

    skynas = {
      title = "SkyNAS";
      dash.icon = "hdd";

      lb.backendUrls = [ "https://192.168.1.20:5001" ];
    };

    traefik = {
      title = "Traefik";
      dash.icon = "traffic-light";
      dash.host = "traefik.bytemonkey.org";
      dash.path = "/dashboard/";
    };

    unifi = {
      title = "UniFi";
      external = true;
      dash.icon = "network-wired";

      lb.backendUrls = [ "https://192.168.1.20:8443" ];
      lb.auth = "external";
    };
  };

  # Layout of services on the dashboard.
  layout = with services; [
    {
      section = "Services";
      services = [ "gitea" "grafana" "homeassistant" "inbucket" "nodered" "octopi" ];
    }
    {
      section = "Cluster";
      services = [ "consul" "nomad" "dockreg" ];
    }
    {
      section = "Infrastructure";
      services = [ "modem" "skynas" "traefik" "unifi" ];
    }
  ];
}
