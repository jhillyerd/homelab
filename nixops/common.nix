# Common config shared among all machines
{ pkgs, hostName, environment, lib, catalog, ... }:
let
  # Import low security credentials.
  lowsec = import ./lowsec.nix;
in {
  imports = [ ./roles ];

  nixpkgs.overlays = [ (import ./pkgs/overlay.nix) ];

  networking.hostName = hostName;

  # Configure telegraf agent.
  roles.telegraf = {
    enable = true;
    influxdb = {
      urls =
        [ "http://${catalog.influxdb.host}:${toString catalog.influxdb.port}" ];
      database = "telegraf-hosts";
      username = lowsec.influxdb.telegraf.user;
      password = lowsec.influxdb.telegraf.password;
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
    lib.splitString "\n" (builtins.readFile ./authorized_keys.txt);

  users.users.james = {
    uid = 1001;
    isNormalUser = true;
    home = "/home/james";
    description = "James Hillyerd";
    extraGroups = [ "docker" "wheel" ];
    openssh.authorizedKeys.keys =
      lib.splitString "\n" (builtins.readFile ./authorized_keys.txt);
  };
}
