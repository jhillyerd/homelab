# Common config shared among all machines
{ config, pkgs, hostName, environment, lib, catalog, nixpkgs-unstable, ... }: {
  system.stateVersion = "21.11";

  imports = [ ./roles ];
  nixpkgs.overlays = [ (import ./pkgs/overlay.nix) ];
  nixpkgs.config.allowUnfree = true;

  # Garbage collect & optimize /nix/store daily.
  nix.gc = {
    automatic = true;
    dates = "weekly";
    options = "--delete-older-than 7d";
  };
  nix.optimise.automatic = true;

  networking.hostName = hostName;
  networking.search = [ "home.arpa" "dyn.skynet.local" ];

  environment.systemPackages = with pkgs;
    let
      # Use unstable neovim.
      neovim = nixpkgs-unstable.legacyPackages.${system}.neovim;

      vim-is-neovim = pkgs.writeShellScriptBin "vim" ''
        exec ${neovim}/bin/nvim "$@"
      '';
    in
    [
      bind
      file
      git
      htop
      jq
      lsof
      mailutils
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

  services.ssmtp = {
    enable = true;
    hostName = catalog.smtp.host;
    root = "root@skynet.local";
  };

  services.openssh = {
    enable = true;
    permitRootLogin = "yes";
  };

  roles.tailscale = {
    enable = true;
    authkeyPath = config.age.secrets.tailscale.path;
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
    tailscale.file = ./secrets/tailscale.age;
  };

  environment.etc."issue.d/ip.issue".text = ''
    IPv4: \4
  '';
  networking.dhcpcd.runHook = "${pkgs.utillinux}/bin/agetty --reload";
}
