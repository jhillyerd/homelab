{
  authorizedKeys,
  config,
  nixpkgs-unstable,
  pkgs,
  self,
  util,
  hermes-agent,
  ...
}:
let
  hermesHome = "/var/lib/hermes";
in
{
  imports = [
    ../common.nix
    ../common/onprem.nix
    hermes-agent.nixosModules.default
  ];

  systemd.network.networks = util.mkClusterNetworks self;
  roles.gateway-online.addr = "192.168.1.1";
  networking.firewall = {
    enable = true;
    allowedTCPPorts = [
      8642 # hermes agent API
      9119 # hermes web dashboard
    ];
  };

  environment.systemPackages =
    let
      system = pkgs.stdenv.hostPlatform.system;
      unstable = nixpkgs-unstable.legacyPackages.${system};
    in
    with pkgs;
    [
      gcc
      gh
      gnumake
      kitty # always install for terminfo
      ripgrep
      tmux
      ungoogled-chromium
      uv
      yazi
    ]
    ++ (with unstable; [ agent-browser ]);

  services.hermes-agent = {
    enable = true;
    addToSystemPackages = true;
    stateDir = hermesHome;

    settings =
      let
        bifrost_url = "https://bifrost.bytemonkey.org/v1";
        bifrost_smart = {
          provider = "custom";
          base_url = bifrost_url;
          api_key = "smartsmart";
          model = "smart";
          timeout = 120; # seconds
        };
        bifrost_fast = {
          provider = "custom";
          base_url = bifrost_url;
          api_key = "fastfast";
          model = "fast";
          timeout = 120; # seconds
        };
        zai_flash = {
          provider = "zai";
          model = "glm-5.3-flash";
        };
      in
      {
        approvals.mode = "off";

        model = bifrost_smart;
        fallback_model = zai_flash;
        delegation = bifrost_fast;

        auxiliary = {
          approval = bifrost_smart;
          compression = bifrost_fast;
          flush_memories = bifrost_fast;
          session_search = bifrost_fast;
          skills_hub = bifrost_smart;
          vision = bifrost_smart;
          web_extract = bifrost_fast;
        };
      };

    extraDependencyGroups = [
      "messaging"
      "web" # dashboard backend (fastapi/uvicorn)
    ];

    backend = {
      mode = "dashboard";
      host = "0.0.0.0"; # non-loopback bind enables the dashboard auth gate
      # Auth credentials come from hermes-env (HERMES_DASHBOARD_BASIC_AUTH_*),
      # otherwise the backend fails closed on start.
      port = 9119;
    };

    environmentFiles = [ config.age.secrets."hermes-env".path ];
  };

  services.borgbackup.jobs.hermes-data = {
    paths = "${hermesHome}/.hermes";
    repo = "/var/lib/borg/hermes-data";
    doInit = true;
    encryption.mode = "none";
    compression = "auto,zstd";
    startAt = "daily";
    prune.keep = {
      within = "14d";
      weekly = 4;
    };
  };

  users.users.hermes = {
    openssh.authorizedKeys.keys = authorizedKeys;
    extraGroups = [ "docker" ];
  };
  age.secrets."hermes-env".file = ../secrets/hermes-env.age;

  virtualisation.docker.enable = true;

  roles.upsmon = {
    enable = true;
    wave = 1;
  };
}
