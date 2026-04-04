{
  authorizedKeys,
  config,
  pkgs,
  self,
  util,
  hermes-agent,
  ...
}:
{
  imports = [
    ../common.nix
    ../common/onprem.nix
    hermes-agent.nixosModules.default
  ];

  systemd.network.networks = util.mkClusterNetworks self;
  roles.gateway-online.addr = "192.168.1.1";
  networking.firewall.enable = true;

  environment.systemPackages = with pkgs; [
    kitty # always install for terminfo
    ripgrep
    tmux
    yazi
  ];

  services.hermes-agent = {
    enable = true;
    addToSystemPackages = true;

    settings = {
      model = {
        provider = "zai";
        default = "glm-5-turbo";
      };
      fallback_model = {
        provider = "openrouter";
        model = "stepfun/step-3.5-flash";
      };
      compression = {
        enable = true;
        threshold = 0.5;
        # summary_provider = "custom";
        # summary_model = "qwen3.5-35b-a3b";
        # summary_base_url = "http://fractal.home.arpa:8001/v1";
      };
      terminal = {
        backend = "docker";
      };
    };

    environmentFiles = [ config.age.secrets."hermes-env".path ];
  };

  services.borgbackup.jobs.hermes-data = {
    paths = "/var/lib/hermes/.hermes";
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
