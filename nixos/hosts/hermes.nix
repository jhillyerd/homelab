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
      yazi
    ]
    ++ (with unstable; [ agent-browser ]);

  services.hermes-agent = {
    enable = true;
    addToSystemPackages = true;
    stateDir = hermesHome;

    settings =
      let
        dgx_qwen = {
          # Qwen 3.5 122B-A10B thinking for main-agent tasks
          provider = "custom";
          base_url = "http://dgx1.home.arpa:8000/v1";
          model = "qwen"; # 122B-A10B
          timeout = 60; # seconds
        };
        fractal_qwen = {
          # Qwen 3.5 35B-A3B non-thinking for auxiliary tasks
          provider = "custom";
          base_url = "http://fractal.home.arpa:8001/v1";
          model = "unsloth/Qwen3.5-35B-A3B-GGUF:UD-IQ4_NL";
          timeout = 60; # seconds
        };
        thinking = dgx_qwen;
        fast = fractal_qwen;
      in
      {
        approvals.mode = "off";

        model = thinking;
        fallback_model = {
          provider = "zai";
          model = "glm-5-turbo";
        };

        auxiliary = {
          approval = thinking;
          flush_memories = fast;
          session_search = fast;
          skills_hub = thinking;
          vision = thinking;
          web_extract = fast;
        };

        compression = {
          enable = true;
          threshold = 0.5;
          summary_provider = fast.provider;
          summary_model = fast.model;
        };
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
