# Catalog defines the systems & services on my network.
{ system }: {
  nodes = {
    fractal = {
      ip = "192.168.1.12";
      tail-ip = "100.112.232.73";
      config = ./hosts/fractal.nix;
      hw = ./hw/asus-b350.nix;
      system = system.x86_64-linux;
    };

    nc-um350-1 = {
      ip = "192.168.128.36";
      tail-ip = "100.109.33.10";
      config = ./hosts/nc-um350.nix;
      hw = ./hw/minis-um350.nix;
      system = system.x86_64-linux;
    };

    nc-um350-2 = {
      ip = "192.168.128.37";
      tail-ip = "100.97.169.111";
      config = ./hosts/nc-um350.nix;
      hw = ./hw/minis-um350.nix;
      system = system.x86_64-linux;
    };

    nexus = {
      ip = "192.168.1.10";
      tail-ip = "100.80.202.97";
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
      config = ./hosts/scratch.nix;
      hw = ./hw/qemu.nix;
      system = system.x86_64-linux;
    };
  };

  influxdb = rec {
    host = "nexus";
    port = 8086;
    telegraf.user = "telegraf";
    telegraf.database = "telegraf-hosts";
    urls = [ "http://${host}:${toString port}" ];
  };

  syslog.host = "nexus";
  syslog.port = 1514;

  smtp.host = "nexus";

  tailscale.interface = "tailscale0";
}
