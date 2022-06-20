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

  nomad.servers = with nodes; [
    nexus.ip.priv
    nc-um350-1.ip.priv
    nc-um350-2.ip.priv
  ];

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

  skynas-nomad-host-volumes = [
    "gitea-storage"
    "grafana-storage"
    "nodered-data"
    "satisfactory-storage"
    "waypoint-storage"
  ];

  cf-api.user = "james@hillyerd.com";

  dns.host = nodes.nexus.ip.priv;

  syslog.host = nodes.nexus.ip.priv;
  syslog.port = 1514;

  smtp.host = nodes.nexus.ip.priv;

  tailscale.interface = "tailscale0";
}
