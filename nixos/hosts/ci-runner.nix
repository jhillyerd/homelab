# A scratch host for building up new service configurations.
{ config, pkgs, lib, self, catalog, util, ... }: {
  imports = [ ../common.nix ];

  systemd.network.networks = util.mkClusterNetworks self;

  networking.firewall.enable = true;

  services.gitea-actions-runner.instances.skynet = {
    enable = true;
    name = config.networking.hostName;
    labels = [
      "nixos_amd64:host"
      "ubuntu-latest:docker://node:18-bullseye"
      "ubuntu-22.04:docker://node:18-bullseye"
    ];

    url = "https://gitea.bytemonkey.org";
    tokenFile = config.age.secrets.gitea-runner-token.path;

    settings = {
      # The level of logging, can be trace, debug, info, warn, error, fatal
      log.level = "info";

      cache = {
        enabled = true;
        dir = "/var/cache/gitea-runner/actions";
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
        network = "bridge";

        # Whether to use privileged mode or not when launching task containers (privileged mode is required for Docker-in-Docker).
        privileged = false;

        # overrides the docker client host with the specified one.
        # If it's empty, act_runner will find an available docker host automatically.
        # If it's "-", act_runner will find an available docker host automatically, but the docker
        # host won't be mounted to the job containers and service containers.
        # If it's not empty or "-", the specified docker host will be used. An error will be returned if it doesn't work.
        docker_host = "";
      };

      # systemd will namespace /var/tmp paths.
      host.workdir_parent = "/var/tmp/actwork";
    };
  };

  systemd.services.gitea-runner-skynet = {
    serviceConfig = {
      # Used by for action cache.
      CacheDirectory = "gitea-runner";
    };
  };

  virtualisation.docker = {
    enable = true;
    # TODO: autoPrune settings.
  };

  age.secrets = {
    gitea-runner-token.file = ../secrets/gitea-runner-token.age;
  };
}
