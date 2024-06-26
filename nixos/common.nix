# Common config shared among all machines
{ config
, pkgs
, options
, authorizedKeys
, hostName
, environment
, catalog
, nixpkgs
, ...
}: {
  system.stateVersion = "23.11";

  imports = [ ./common/packages.nix ./roles ];
  nixpkgs.overlays = [ (import ./pkgs/overlay.nix) ];
  nixpkgs.config.allowUnfree = true;

  nix = {
    nixPath = [ "nixpkgs=${nixpkgs}" ];
    optimise.automatic = true;

    gc = {
      automatic = true;
      dates = "weekly";
      options = "--delete-older-than 7d";
      randomizedDelaySec = "20min";
    };

    settings.substituters = [
      "http://nix-cache.service.skynet.consul?priority=10"
    ];
  };

  networking = {
    search = [ "home.arpa" "dyn.home.arpa" ];
    timeServers = [ "ntp.home.arpa" ] ++ options.networking.timeServers.default;
  };

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

  services.openssh = {
    enable = true;
    settings.PermitRootLogin = "yes";
  };

  programs.command-not-found.enable = false; # not flake aware

  programs.msmtp.accounts.default = {
    auth = false;
    host = catalog.smtp.host;
  };

  time.timeZone = "US/Pacific";

  users.users.root.openssh.authorizedKeys.keys = authorizedKeys;

  age.secrets = {
    influxdb-telegraf.file = ./secrets/influxdb-telegraf.age;
    wifi-env.file = ./secrets/wifi-env.age;
  };

  environment.etc."issue.d/ip.issue".text = ''
    IPv4: \4
  '';
  networking.dhcpcd.runHook = "${pkgs.utillinux}/bin/agetty --reload";
  networking.firewall.checkReversePath = "loose";
}
