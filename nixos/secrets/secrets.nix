let
  # Users
  james-eph =
    "ssh-ed25519 AAAAC3NzaC1lZDI1NTE5AAAAIM1Rq9OFHVus5eULteCEGNkHgINch40oPP2LwvlVd6ng";
  james-fractal =
    "ssh-ed25519 AAAAC3NzaC1lZDI1NTE5AAAAIB5SIs0HmrtQN+W7YFqIPpyTqTbRqW8Kq06h2btmXElG";
  james-ryzen =
    "ssh-ed25519 AAAAC3NzaC1lZDI1NTE5AAAAICAXHtE9NI16ZPNSKF6Cn0JNJS6fTNQYduerVmVa6WKY";
  james-nix-ryzen =
    "ssh-ed25519 AAAAC3NzaC1lZDI1NTE5AAAAICJoH0p+6iSISUAqRO8+6+uvQWpjaP0eQjDeGAXIYUI6";
  users = [ james-eph james-fractal james-ryzen james-nix-ryzen ];

  # Nodes
  eph =
    "ssh-ed25519 AAAAC3NzaC1lZDI1NTE5AAAAIJy9svdsaaW77i5QPwiNLDSN+jJmFvkK5NisZzbm7Lro";
  fractal =
    "ssh-ed25519 AAAAC3NzaC1lZDI1NTE5AAAAIDdjavkGpkN4niiLWGAjNsaS3R3gxnLn7H4rTtkVkyAt";
  metrics =
    "ssh-ed25519 AAAAC3NzaC1lZDI1NTE5AAAAIAthVAxIOvyRWkUlxH19erBZGNC6LCW1IAFE+1T4AxGL";
  nexus =
    "ssh-ed25519 AAAAC3NzaC1lZDI1NTE5AAAAIEuqgUtpyOVfnxa1oKLdjN4AIN5piKHfdumQHonqjH4P";
  nix-ryzen =
    "ssh-ed25519 AAAAC3NzaC1lZDI1NTE5AAAAIPO18qRQvPfbyWYkG5J5K1T1NbCw4Y7QeeRhdQG8CzI5";
  nixtarget1-virtd =
    "ssh-ed25519 AAAAC3NzaC1lZDI1NTE5AAAAILozTQNcPY2BNQZNW+F29M2euRzD7wZ1XtsKsWFjzpeJ";
  web =
    "ssh-ed25519 AAAAC3NzaC1lZDI1NTE5AAAAICHzyS01Xs/BFkkwlIa+F3K/23yw/9GE/NFcachriRgl";
  home-systems = [ eph fractal metrics nexus nix-ryzen nixtarget1-virtd web ];

  kube1 =
    "ssh-ed25519 AAAAC3NzaC1lZDI1NTE5AAAAIB7K81sGBvuRcbOaQpippdNHhCRL2eDfmsJ1BNosZ8+o";
  kube2 =
    "ssh-ed25519 AAAAC3NzaC1lZDI1NTE5AAAAIIziR7mI9vwr2/qHYx89GDJh95oQkZmbfb5AdDePXUtZ";
  kube-cluster = [ kube1 kube2 ];

  nc-um350-1 =
    "ssh-ed25519 AAAAC3NzaC1lZDI1NTE5AAAAIMY7Sz0qZCTg2rJNZ1SX61eMosZwPyh0Mq8+kxp5AB31";
  nc-um350-2 =
    "ssh-ed25519 AAAAC3NzaC1lZDI1NTE5AAAAINSarN+Keghwq5qltwrvPR0AKNI7nrGoJRkZrl+mTPuO";
  nc-pi3-1 =
    "ssh-ed25519 AAAAC3NzaC1lZDI1NTE5AAAAIN8e1tGPws/Utx3BHPW8bF4UfcbeFZagMvu7x1MyYype";
  nomad-cluster = [ nexus nc-um350-1 nc-um350-2 nc-pi3-1 web ];

  group = {
    common = users ++ home-systems ++ nomad-cluster ++ kube-cluster;
    home = users ++ home-systems;
    kube = users ++ kube-cluster;
    nomad = users ++ nomad-cluster;
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
}
