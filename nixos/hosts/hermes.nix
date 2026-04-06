{
  authorizedKeys,
  config,
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

  environment.systemPackages = with pkgs; [
    kitty # always install for terminfo
    ripgrep
    tmux
    yazi
  ];

  services.hermes-agent = {
    enable = true;
    addToSystemPackages = true;
    stateDir = hermesHome;

    settings =
      let
        fractal_qwen = {
          base_url = "http://fractal.home.arpa:8001/v1";
          model = "qwen3.5-27b";
          timeout = 60; # seconds
        };
        fast = {
          provider = "zai";
          model = "glm-4.7-flash";
        };
      in
      {
        approvals.mode = "smart";
        model = {
          provider = "zai";
          default = "glm-5-turbo";
        };
        fallback_model = {
          provider = "openrouter";
          model = "stepfun/step-3.5-flash";
        };
        auxiliary = {
          approval = fractal_qwen;
          flush_memories = fast;
          session_search = fast;
          skills_hub = fractal_qwen;
          vision = fractal_qwen;
          web_extract = fractal_qwen;
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
