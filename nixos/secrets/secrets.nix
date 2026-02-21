let
  # Users
  james-skynet = "ssh-ed25519 AAAAC3NzaC1lZDI1NTE5AAAAIGKG8scDbgNAwAfeKg76EfMHlaJOVzXMdcAKX9IInudG";
  james-boss = "ssh-ed25519 AAAAC3NzaC1lZDI1NTE5AAAAILMUS8WdTqKJ5zH4o/grh0UgBRpmyo9f1o4pELqq23y/";
  james-eph = "ssh-ed25519 AAAAC3NzaC1lZDI1NTE5AAAAIM1Rq9OFHVus5eULteCEGNkHgINch40oPP2LwvlVd6ng";
  james-ryzen = "ssh-ed25519 AAAAC3NzaC1lZDI1NTE5AAAAICAXHtE9NI16ZPNSKF6Cn0JNJS6fTNQYduerVmVa6WKY";
  james-nix-ryzen = "ssh-ed25519 AAAAC3NzaC1lZDI1NTE5AAAAICJoH0p+6iSISUAqRO8+6+uvQWpjaP0eQjDeGAXIYUI6";
  users = [
    james-skynet
    james-boss
    james-eph
    james-ryzen
    james-nix-ryzen
  ];

  # Nodes
  agent-zero = "ssh-ed25519 AAAAC3NzaC1lZDI1NTE5AAAAIOeMONJSXhs+Ydp9wx7fbBnacM9V30HwgRWhHHg09VeN";
  boss = "ssh-ed25519 AAAAC3NzaC1lZDI1NTE5AAAAIO1L6/RnWa8jBLfre3EQm4pCQ4fpObmj4GrqMarpuDNM";
  eph = "ssh-ed25519 AAAAC3NzaC1lZDI1NTE5AAAAIJy9svdsaaW77i5QPwiNLDSN+jJmFvkK5NisZzbm7Lro";
  fastd = "ssh-ed25519 AAAAC3NzaC1lZDI1NTE5AAAAIEhFOgRRiQp/P/amORoCK7woLM8koTmDCCNA+9+/ThrY";
  fractal = "ssh-ed25519 AAAAC3NzaC1lZDI1NTE5AAAAIHiazL5O3J6rnNk9zX484FCKnVGWsRDJIwhKub2dUp38";
  game = "ssh-ed25519 AAAAC3NzaC1lZDI1NTE5AAAAINwJjb9823qVwZPp95MrfTekFoMtHPeybTRbogwi6B24";
  metrics = "ssh-ed25519 AAAAC3NzaC1lZDI1NTE5AAAAIAthVAxIOvyRWkUlxH19erBZGNC6LCW1IAFE+1T4AxGL";
  nexus = "ssh-ed25519 AAAAC3NzaC1lZDI1NTE5AAAAIEuqgUtpyOVfnxa1oKLdjN4AIN5piKHfdumQHonqjH4P";
  nix-ryzen = "ssh-ed25519 AAAAC3NzaC1lZDI1NTE5AAAAIPO18qRQvPfbyWYkG5J5K1T1NbCw4Y7QeeRhdQG8CzI5";
  nixtarget1-virtd = "ssh-ed25519 AAAAC3NzaC1lZDI1NTE5AAAAILozTQNcPY2BNQZNW+F29M2euRzD7wZ1XtsKsWFjzpeJ";
  scratch = "ssh-ed25519 AAAAC3NzaC1lZDI1NTE5AAAAIO9E9qftUIsznkjQXN9Bwov9bme0ZPD9fd704XwChrtV";
  web = "ssh-ed25519 AAAAC3NzaC1lZDI1NTE5AAAAICHzyS01Xs/BFkkwlIa+F3K/23yw/9GE/NFcachriRgl";
  home-nodes = [
    agent-zero
    boss
    eph
    fastd
    fractal
    game
    metrics
    nexus
    nix-ryzen
    nixtarget1-virtd
    scratch
    web
  ];

  # Runners
  ci-runner1 = "ssh-ed25519 AAAAC3NzaC1lZDI1NTE5AAAAIJnOeW75UezreS51pqSHleYjx7tNg67Nv34rh5/dJLiZ";
  runner-nodes = [
    ci-runner1
    scratch
  ];

  # Cluster nodes
  witness = "ssh-ed25519 AAAAC3NzaC1lZDI1NTE5AAAAIAXoEYcViLYLHXZRThjTh61ZA43DS2lCCbJa5EXbFAwc";

  nc-um350-1 = "ssh-ed25519 AAAAC3NzaC1lZDI1NTE5AAAAIMY7Sz0qZCTg2rJNZ1SX61eMosZwPyh0Mq8+kxp5AB31";
  nc-um350-2 = "ssh-ed25519 AAAAC3NzaC1lZDI1NTE5AAAAIKmHTTSRM1PuZ45KXJACZhJc1GAgcT9i+QCClo6sV88R";
  nc-virt-1 = "ssh-ed25519 AAAAC3NzaC1lZDI1NTE5AAAAIHY+llyPw11hCagbnJiXTmzO/FfHydVRIFmDRseGLTOd";
  nomad-cluster = [
    nc-um350-1
    nc-um350-2
    nc-virt-1
    web
    witness
  ];

  group = {
    common = users ++ home-nodes ++ nomad-cluster ++ runner-nodes;
    home = users ++ home-nodes;
    nomad = users ++ nomad-cluster;
    runners = users ++ runner-nodes;
  };
in
{
  # Common
  "influxdb-telegraf.age".publicKeys = group.common;
  "tailscale.age".publicKeys = group.common;
  "wifi-env.age".publicKeys = group.common;

  # Home
  "cloudflare-dns-api.age".publicKeys = group.home;
  "influxdb-admin.age".publicKeys = group.home;
  "influxdb-homeassistant.age".publicKeys = group.home;
  "mqtt-admin.age".publicKeys = group.home;
  "mqtt-clock.age".publicKeys = group.home;
  "mqtt-sensor.age".publicKeys = group.home;
  "mqtt-zwave.age".publicKeys = group.home;
  "theforest-environment.age".publicKeys = group.home;

  # Nomad cluster
  "consul-encrypt.age".publicKeys = group.nomad;
  "consul-agent-token.age".publicKeys = group.nomad;
  "nomad-encrypt.age".publicKeys = group.nomad;
  "nomad-consul-token.age".publicKeys = group.nomad;
  "nomad-server-client-key.age".publicKeys = group.nomad;
  "skynet-server-consul-0-key.pem.age".publicKeys = group.nomad;
  "traefik-consul-token.age".publicKeys = group.nomad;

  # Runners.
  "gitea-runner-token.age".publicKeys = group.runners;

  # Specific hosts.
  "syncoid-ssh-key.age".publicKeys = users ++ [ fastd ];
}
