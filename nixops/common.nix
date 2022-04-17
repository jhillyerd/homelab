# Common config shared among all machines
{ config, pkgs, hostName, environment, lib, catalog, ... }: {
  system.stateVersion = "21.11";

  imports = [ ./roles ];

  nixpkgs.overlays = [ (import ./pkgs/overlay.nix) ];

  networking.hostName = hostName;

  nixpkgs.config.allowUnfree = true;

  environment.systemPackages = with pkgs;
    let
      vim-is-neovim = pkgs.writeShellScriptBin "vim" ''
        exec ${pkgs.neovim}/bin/nvim "$@"
      '';
    in [
      bind
      file
      git
      htop
      jq
      lsof
      ncat
      neovim
      psmisc
      tree
      vim-is-neovim
      wget
    ];

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
    influxdb-telegraf.file = ./secrets/influxdb-telegraf.age;

    mqtt-sensor.file = ./secrets/mqtt-sensor.age;
  };
}
