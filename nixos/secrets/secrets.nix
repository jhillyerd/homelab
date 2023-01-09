let
  james-fractal =
    "ssh-ed25519 AAAAC3NzaC1lZDI1NTE5AAAAIB5SIs0HmrtQN+W7YFqIPpyTqTbRqW8Kq06h2btmXElG";
  james-hypernix =
    "ssh-ed25519 AAAAC3NzaC1lZDI1NTE5AAAAIBIYwEkZGwJbEcZve0qLyTbfuD7eKmtafA8ZWGgYHWUW";
  james-ryzen =
    "ssh-ed25519 AAAAC3NzaC1lZDI1NTE5AAAAICAXHtE9NI16ZPNSKF6Cn0JNJS6fTNQYduerVmVa6WKY";
  users = [ james-fractal james-hypernix james-ryzen ];

  eph =
    "ssh-ed25519 AAAAC3NzaC1lZDI1NTE5AAAAIJy9svdsaaW77i5QPwiNLDSN+jJmFvkK5NisZzbm7Lro";
  fractal =
    "ssh-ed25519 AAAAC3NzaC1lZDI1NTE5AAAAIDdjavkGpkN4niiLWGAjNsaS3R3gxnLn7H4rTtkVkyAt";
  nexus =
    "ssh-ed25519 AAAAC3NzaC1lZDI1NTE5AAAAIEuqgUtpyOVfnxa1oKLdjN4AIN5piKHfdumQHonqjH4P";
  nixtarget1-hyperv =
    "ssh-ed25519 AAAAC3NzaC1lZDI1NTE5AAAAILiU0B1BYTeGojG+uo2siv2tpl7PEj3iV0CL8EHyM42e";
  nixtarget1-virtd =
    "ssh-ed25519 AAAAC3NzaC1lZDI1NTE5AAAAILozTQNcPY2BNQZNW+F29M2euRzD7wZ1XtsKsWFjzpeJ";
  web =
    "ssh-ed25519 AAAAC3NzaC1lZDI1NTE5AAAAICHzyS01Xs/BFkkwlIa+F3K/23yw/9GE/NFcachriRgl";
  home-systems = [ eph fractal nexus nixtarget1-hyperv nixtarget1-virtd web ];

  nc-um350-1 =
    "ssh-ed25519 AAAAC3NzaC1lZDI1NTE5AAAAIMY7Sz0qZCTg2rJNZ1SX61eMosZwPyh0Mq8+kxp5AB31";
  nc-um350-2 =
    "ssh-ed25519 AAAAC3NzaC1lZDI1NTE5AAAAINSarN+Keghwq5qltwrvPR0AKNI7nrGoJRkZrl+mTPuO";

  nomad-cluster = [ nexus nc-um350-1 nc-um350-2 web ];
in
{
  # Common
  "influxdb-telegraf.age".publicKeys = users ++ home-systems ++ nomad-cluster;
  "tailscale.age".publicKeys = users ++ home-systems ++ nomad-cluster;

  # Home
  "cloudflare-dns-api.age".publicKeys = users ++ home-systems;
  "influxdb-admin.age".publicKeys = users ++ home-systems;
  "influxdb-homeassistant.age".publicKeys = users ++ home-systems;
  "mqtt-admin.age".publicKeys = users ++ home-systems;
  "mqtt-sensor.age".publicKeys = users ++ home-systems;

  # Nomad cluster
  "consul-encrypt.age".publicKeys = users ++ nomad-cluster;
  "nomad-encrypt.age".publicKeys = users ++ nomad-cluster;
  "nomad-consul-token.age".publicKeys = users ++ nomad-cluster;
  "nomad-server-client-key.age".publicKeys = users ++ nomad-cluster;
  "skynet-server-consul-0-key.pem.age".publicKeys = users ++ nomad-cluster;
  "traefik-consul-token.age".publicKeys = users ++ nomad-cluster;
}
