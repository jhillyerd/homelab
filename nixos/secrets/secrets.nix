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
  nexus =
    "ssh-ed25519 AAAAC3NzaC1lZDI1NTE5AAAAIEuqgUtpyOVfnxa1oKLdjN4AIN5piKHfdumQHonqjH4P";
  nix-ryzen =
    "ssh-ed25519 AAAAC3NzaC1lZDI1NTE5AAAAIPO18qRQvPfbyWYkG5J5K1T1NbCw4Y7QeeRhdQG8CzI5";
  nixtarget1-virtd =
    "ssh-ed25519 AAAAC3NzaC1lZDI1NTE5AAAAILozTQNcPY2BNQZNW+F29M2euRzD7wZ1XtsKsWFjzpeJ";
  web =
    "ssh-ed25519 AAAAC3NzaC1lZDI1NTE5AAAAICHzyS01Xs/BFkkwlIa+F3K/23yw/9GE/NFcachriRgl";
  home-systems = [ eph fractal nexus nix-ryzen nixtarget1-virtd web ];

  nc-um350-1 =
    "ssh-ed25519 AAAAC3NzaC1lZDI1NTE5AAAAIMY7Sz0qZCTg2rJNZ1SX61eMosZwPyh0Mq8+kxp5AB31";
  nc-um350-2 =
    "ssh-ed25519 AAAAC3NzaC1lZDI1NTE5AAAAINSarN+Keghwq5qltwrvPR0AKNI7nrGoJRkZrl+mTPuO";
  nc-pi3-1 =
    "ssh-ed25519 AAAAC3NzaC1lZDI1NTE5AAAAIN8e1tGPws/Utx3BHPW8bF4UfcbeFZagMvu7x1MyYype";

  nomad-cluster = [ nexus nc-um350-1 nc-um350-2 nc-pi3-1 web ];
in
{
  # TODO define common, home, nomad groups to simplify assignments below.

  # Common
  "influxdb-telegraf.age".publicKeys = users ++ home-systems ++ nomad-cluster;
  "tailscale.age".publicKeys = users ++ home-systems ++ nomad-cluster;
  "wifi-env.age".publicKeys = users ++ home-systems ++ nomad-cluster;

  # Home
  "cloudflare-dns-api.age".publicKeys = users ++ home-systems;
  "influxdb-admin.age".publicKeys = users ++ home-systems;
  "influxdb-homeassistant.age".publicKeys = users ++ home-systems;
  "mqtt-admin.age".publicKeys = users ++ home-systems;
  "mqtt-clock.age".publicKeys = users ++ home-systems;
  "mqtt-sensor.age".publicKeys = users ++ home-systems;
  "mqtt-zwave.age".publicKeys = users ++ home-systems;

  # Nomad cluster
  "consul-encrypt.age".publicKeys = users ++ nomad-cluster;
  "consul-agent-token.age".publicKeys = users ++ nomad-cluster;
  "nomad-encrypt.age".publicKeys = users ++ nomad-cluster;
  "nomad-consul-token.age".publicKeys = users ++ nomad-cluster;
  "nomad-server-client-key.age".publicKeys = users ++ nomad-cluster;
  "skynet-server-consul-0-key.pem.age".publicKeys = users ++ nomad-cluster;
  "traefik-consul-token.age".publicKeys = users ++ nomad-cluster;
}
