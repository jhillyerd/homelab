let
  # Users
  james-eph = "ssh-ed25519 AAAAC3NzaC1lZDI1NTE5AAAAIM1Rq9OFHVus5eULteCEGNkHgINch40oPP2LwvlVd6ng";
  james-ryzen = "ssh-ed25519 AAAAC3NzaC1lZDI1NTE5AAAAICAXHtE9NI16ZPNSKF6Cn0JNJS6fTNQYduerVmVa6WKY";
  james-nix-ryzen = "ssh-ed25519 AAAAC3NzaC1lZDI1NTE5AAAAICJoH0p+6iSISUAqRO8+6+uvQWpjaP0eQjDeGAXIYUI6";
  users = [
    james-eph
    james-ryzen
    james-nix-ryzen
  ];

  # Nodes
  eph = "ssh-ed25519 AAAAC3NzaC1lZDI1NTE5AAAAIJy9svdsaaW77i5QPwiNLDSN+jJmFvkK5NisZzbm7Lro";
  fastd = "ssh-ed25519 AAAAC3NzaC1lZDI1NTE5AAAAIEhFOgRRiQp/P/amORoCK7woLM8koTmDCCNA+9+/ThrY";
  media1 = "ssh-ed25519 AAAAC3NzaC1lZDI1NTE5AAAAIEHbWtaiN5lzh0UAD3aZfSuLV1fn8BFZOXUwe57fZ2wP";
  metrics = "ssh-ed25519 AAAAC3NzaC1lZDI1NTE5AAAAIAthVAxIOvyRWkUlxH19erBZGNC6LCW1IAFE+1T4AxGL";
  nexus = "ssh-ed25519 AAAAC3NzaC1lZDI1NTE5AAAAIEuqgUtpyOVfnxa1oKLdjN4AIN5piKHfdumQHonqjH4P";
  nix-ryzen = "ssh-ed25519 AAAAC3NzaC1lZDI1NTE5AAAAIPO18qRQvPfbyWYkG5J5K1T1NbCw4Y7QeeRhdQG8CzI5";
  nixtarget1-virtd = "ssh-ed25519 AAAAC3NzaC1lZDI1NTE5AAAAILozTQNcPY2BNQZNW+F29M2euRzD7wZ1XtsKsWFjzpeJ";
  scratch = "ssh-ed25519 AAAAC3NzaC1lZDI1NTE5AAAAIO9E9qftUIsznkjQXN9Bwov9bme0ZPD9fd704XwChrtV";
  web = "ssh-ed25519 AAAAC3NzaC1lZDI1NTE5AAAAICHzyS01Xs/BFkkwlIa+F3K/23yw/9GE/NFcachriRgl";
  home-nodes = [
    eph
    fastd
    media1
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

  kube1 = "ssh-ed25519 AAAAC3NzaC1lZDI1NTE5AAAAIB7K81sGBvuRcbOaQpippdNHhCRL2eDfmsJ1BNosZ8+o";
  kube2 = "ssh-ed25519 AAAAC3NzaC1lZDI1NTE5AAAAIIziR7mI9vwr2/qHYx89GDJh95oQkZmbfb5AdDePXUtZ";
  kube-cluster = [
    kube1
    kube2
    scratch
    witness
  ];

  nc-um350-1 = "ssh-ed25519 AAAAC3NzaC1lZDI1NTE5AAAAIMY7Sz0qZCTg2rJNZ1SX61eMosZwPyh0Mq8+kxp5AB31";
  nc-um350-2 = "ssh-ed25519 AAAAC3NzaC1lZDI1NTE5AAAAIKmHTTSRM1PuZ45KXJACZhJc1GAgcT9i+QCClo6sV88R";
  nomad-cluster = [
    nexus
    nc-um350-1
    nc-um350-2
    scratch
    web
    witness
  ];

  group = {
    common = users ++ home-nodes ++ nomad-cluster ++ kube-cluster ++ runner-nodes;
    home = users ++ home-nodes;
    kube = users ++ kube-cluster;
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

  # Kube cluster
  "k3s-token.age".publicKeys = group.kube;

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
}
