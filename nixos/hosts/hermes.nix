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

  # Same overridden package for the gateway service and the WebUI (which
  # derives its agent python from passthru). Keep the version string in
  # sync with the hermes-agent tag pinned in flake.nix.
  hermesPkg = hermes-agent.packages.${pkgs.stdenv.hostPlatform.system}.default.override {
    version = "0.23.0";
  };
in
{
  imports = [
    ../common
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
      9120 # hermes webapp (Desktop in a browser)
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

    # Upstream's nix/packages.nix never passes `version` (flake tags aren't
    # exposed to builds), so the install stamp defaults to 0.0.0 — which the
    # banner and plugin `requires_hermes` checks then read. Override with the
    # pinned tag's version, kept in sync with flake.nix.
    package = hermesPkg;

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

        # Run terminal sessions in Docker containers instead of on the host
        # (also covers webui sessions — shared config.yaml). Image tag is
        # version-matched to the hermes-agent pin: bump together, see AGENTS.md.
        terminal = {
          backend = "docker";
          docker_image = "nousresearch/hermes-sandbox:v0.23.0-desktop";
        };

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

        # v0.23 Webapp: the Desktop workspace in a browser tab, served by
        # the gateway on its own listener (default port 9120). Off by
        # default upstream. Like the module's backend option, a 0.0.0.0
        # bind engages the dashboard auth gate, so the hermes-env
        # basic-auth credentials apply here too.
        webapp = {
          enabled = true;
          host = "0.0.0.0";
        };
      };

    extraDependencyGroups = [
      "messaging"
      "web" # dashboard backend (fastapi/uvicorn)
    ];

    # Docker CLI for terminal.backend = "docker" — service units get a
    # minimal PATH, so the CLI must be wired in explicitly (also lands in the
    # hermes user's profile for login shells).
    extraPackages = [ pkgs.docker-client ];

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
    paths = [
      "${hermesHome}/.hermes" # agent home incl. webui sessions
      "/var/lib/hermes-webui" # webui service state dir
    ];
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
