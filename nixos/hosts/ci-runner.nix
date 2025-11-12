{
  config,
  pkgs-unstable,
  self,
  util,
  ...
}:
{
  imports = [
    ../common.nix
    ../common/onprem.nix
  ];

  systemd.network.networks = util.mkClusterNetworks self;

  networking.firewall.enable = true;

  services.gitea-actions-runner.package = pkgs-unstable.forgejo-runner;
  services.gitea-actions-runner.instances.skynet = {
    enable = true;

    name = config.networking.hostName;
    labels = [
      "nixos_amd64:host"
      "ubuntu-latest:docker://node:20-bookworm"
      "ubuntu-22.04:docker://node:20-bullseye"
    ];

    url = "https://forgejo.bytemonkey.org";
    tokenFile = config.age.secrets.gitea-runner-token.path;

    settings = {
      # The level of logging, can be trace, debug, info, warn, error, fatal
      log.level = "info";

      cache = {
        enabled = true;
        dir = "/var/cache/forgejo-runner/actions";
      };

      runner = {
        # Execute how many tasks concurrently at the same time.
        capacity = 2;
        # Extra environment variables to run jobs.
        envs = { };
        # The timeout for a job to be finished.
        # Please note that the Gitea instance also has a timeout (3h by default) for the job.
        # So the job could be stopped by the Gitea instance if it's timeout is shorter than this.
        timeout = "3h";
      };

      container = {
        # Specifies the network to which the container will connect.
        # Could be host, bridge or the name of a custom network.
        # If it's empty, act_runner will create a network automatically.
        network = "";

        # Whether to use privileged mode or not when launching task containers (privileged mode is required for Docker-in-Docker).
        privileged = false;

        # overrides the docker client host with the specified one.
        # If "-" or "", an available docker host will automatically be found.
        # If "automount", an available docker host will automatically be found and mounted in the job container (e.g.
        # /var/run/docker.sock).
        # Otherwise the specified docker host will be used and an error will be returned if it doesn't work.
        docker_host = "automount";
      };

      # systemd will namespace /var/tmp paths.
      host.workdir_parent = "/var/tmp/actwork";
    };
  };

  systemd.services.gitea-runner-skynet = {
    serviceConfig = {
      # Used by for action cache.
      CacheDirectory = "forgejo-runner";
    };
  };

  virtualisation.docker = {
    enable = true;
    # TODO: autoPrune settings.
  };

  age.secrets = {
    gitea-runner-token.file = ../secrets/gitea-runner-token.age;
  };

  # Allow container runners to access cache service.
  networking.firewall.trustedInterfaces = [ "br-+" ];

  roles.upsmon = {
    enable = true;
    wave = 1;
  };
}
