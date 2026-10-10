{
  authorizedKeys,
  config,
  nixpkgs-unstable,
  pkgs,
  self,
  util,
  hermes-agent,
  hermes-webui,
  ...
}:
let
  hermesHome = "/var/lib/hermes";

  # Same overridden package for the gateway service and the WebUI (which
  # derives its agent python from passthru). Keep the version string in
  # sync with the hermes-agent tag pinned in flake.nix.
  hermesPkg =
    hermes-agent.packages.${pkgs.stdenv.hostPlatform.system}.default.override {
      version = "0.21.6";
    };
in
{
  imports = [
    ../common.nix
    ../common/onprem.nix
    hermes-agent.nixosModules.default
    hermes-webui.nixosModules.default
  ];

  systemd.network.networks = util.mkClusterNetworks self;
  roles.gateway-online.addr = "192.168.1.1";
  networking.firewall = {
    enable = true;
    allowedTCPPorts = [
      8642 # hermes agent API
      8787 # hermes webui
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
          docker_image = "nousresearch/hermes-sandbox:v0.21.6-desktop";
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

  # Third-party web UI (nesquena/hermes-webui): imports the agent in-process
  # and reads HERMES_HOME directly, so it must be colocated with the agent —
  # same host, same user, same state. Chat/session state stays in
  # ~/.hermes/webui inside the agent home (already borg-backed). Secrets are
  # not passed via systemd env: the agent activation mirrors hermes-env into
  # $HERMES_HOME/.env, which run_agent loads at import time.
  services.hermes-webui = {
    enable = true;

    # Run as the agent service user so both processes share HERMES_HOME
    # (sessions, state.db, config.yaml); the module otherwise creates a
    # separate hermes-webui user that cannot read the agent state.
    user = "hermes";
    group = "hermes";

    # Non-loopback bind makes the WebUI enforce its password gate; the
    # password is set via its settings UI (PBKDF2 hash in settings.json —
    # do NOT add HERMES_WEBUI_PASSWORD to hermes-env, it would override).
    host = "0.0.0.0";
    port = 8787;

    hermesHome = "${hermesHome}/.hermes";

    agent = {
      package = hermesPkg; # HERMES_WEBUI_PYTHON from passthru.hermesVenv
      # The Nix package out has no run_agent.py; the venv site-packages is
      # the importable "agent source root" the WebUI puts on sys.path.
      dir =
        "${hermesPkg.passthru.hermesVenv}/${hermesPkg.passthru.python.sitePackages}";
    };
  };

  # The webui unit has no packages option; give its in-process agent the
  # docker CLI the same way the agent module does for its own services.
  systemd.services.hermes-webui.path = [ pkgs.docker-client ];

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
