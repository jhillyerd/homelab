# Common config shared among all machines
{ config, pkgs, hostName, environment, lib, catalog, ... }: {
  imports = [ ./roles ];

  nixpkgs.overlays = [ (import ./pkgs/overlay.nix) ];

  networking.hostName = hostName;

  # Configure telegraf agent.
  roles.telegraf = {
    enable = true;
    influxdb = {
      urls = catalog.influxdb.urls;
      database = catalog.influxdb.telegraf.database;
      user = catalog.influxdb.telegraf.user;
      passwordFile = config.age.secrets.influxdb-telegraf.path;
    };
  };

  # Forward syslogs to promtail/loki.
  roles.log-forwarder = {
    enable = true;
    syslogHost = catalog.syslog.host;
    syslogPort = catalog.syslog.port;
  };

  services.getty.helpLine =
    ">>> Flake node: ${hostName}, environment: ${environment}";

  services.tailscale.enable = true;

  services.openssh = {
    enable = true;
    permitRootLogin = "yes";
  };

  time.timeZone = "US/Pacific";

  users.users.root.openssh.authorizedKeys.keys =
    lib.splitString "\n" (builtins.readFile ../authorized_keys.txt);

  users.users.james = {
    uid = 1001;
    isNormalUser = true;
    home = "/home/james";
    description = "James Hillyerd";
    extraGroups = [ "docker" "wheel" ];
    openssh.authorizedKeys.keys =
      lib.splitString "\n" (builtins.readFile ../authorized_keys.txt);
  };

  age.secrets = {
    cloudflare-dns-api.file = ./secrets/cloudflare-dns-api.age;

    influxdb-admin.file = ./secrets/influxdb-admin.age;
    influxdb-homeassistant.file = ./secrets/influxdb-homeassistant.age;
    influxdb-telegraf.file = ./secrets/influxdb-telegraf.age;

    mqtt-admin.file = ./secrets/mqtt-admin.age;
    mqtt-admin.owner = "mosquitto";
    mqtt-sensor.file = ./secrets/mqtt-sensor.age;
    mqtt-sensor.owner = "mosquitto";

    nodered.file = ./secrets/nodered.age;
  };
}
