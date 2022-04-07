# Common config shared among all machines
{ pkgs, nodes, hostName, environment, ... }:
let
  # Import low security credentials.
  lowsec = import ./lowsec.nix;

  influxHost = "nexus";
  influxPort = nodes.nexus.config.roles.influxdb.port;

  syslogHost = "nexus";
  syslogPort = nodes.nexus.config.roles.loki.promtail_syslog_port;
in {
  imports = [ ./roles ];

  nixpkgs.overlays = [ (import ./pkgs/overlay.nix) ];

  networking.hostName = hostName;

  # Configure telegraf agent.
  roles.telegraf = {
    enable = true;
    influxdb = {
      urls = [ "http://${influxHost}:${toString influxPort}" ];
      database = "telegraf-hosts";
      username = lowsec.influxdb.telegraf.user;
      password = lowsec.influxdb.telegraf.password;
    };
  };

  # Forward syslogs to promtail/loki.
  roles.log-forwarder = {
    enable = true;
    inherit syslogHost syslogPort;
  };

  services.getty.helpLine = ">>> Flake node: ${hostName}, environment: ${environment}";

  services.tailscale.enable = true;

  services.openssh = {
    enable = true;
    permitRootLogin = "yes";
  };

  time.timeZone = "US/Pacific";

  users.users.james = {
    uid = 1001;
    isNormalUser = true;
    home = "/home/james";
    description = "James Hillyerd";
    extraGroups = [ "docker" "wheel" ];
    openssh.authorizedKeys.keys = [
      "ssh-rsa AAAAB3NzaC1yc2EAAAADAQABAAABgQDZj6GV5aC3zX/P/STi0QDDaIUCwyDekLIKtN/L+s2vL8E1KxD69DLQ4DKV1fJUV97oo/Qv8pHUFgCQhEOYm5bchm+0Wc6ZBolcJ6q9KUNGIsaIa8ts6vQEG5k3pRI1E4kMrhggUJFOlSKxmcA9v+tEmZTlAo9wXn2wmqhmaLVfaGORwyMCuUc+2BP4xTwfuc+c0rb+kZOdp6+TuYiIXUOD9OqDrBkhFMe9bqNI0QxryACjid/qJvhjMos/fTeg7CgSsp+jP9ChVWnde0QquUVv5jmkKq2cdN2tfZdmin48cvAKAdtibpi4jQcIeWM7xWfEoE9T1u5tkfQgM8VhiV5EmSQrO/U9PIucKh64Vu+PGvQtbeNUcODd5Zkky0NDK2vrnIZTnGwQcTw4j5nDDUkgBHeW8jxT3Pf9lsCtJJL3edLxKwZA2+Dgf6EX2LxovvZVKYgfONhH1FRtv4V9ahoCPg0l1qdYX996Iihwc9wv8DfXMnWypEcytpKP2sXhUqc= james@Ryzen"
    ];
  };
}
