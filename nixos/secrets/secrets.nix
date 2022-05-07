let
  james-fractal =
    "ssh-ed25519 AAAAC3NzaC1lZDI1NTE5AAAAIB5SIs0HmrtQN+W7YFqIPpyTqTbRqW8Kq06h2btmXElG";
  james-hypernix =
    "ssh-ed25519 AAAAC3NzaC1lZDI1NTE5AAAAIBIYwEkZGwJbEcZve0qLyTbfuD7eKmtafA8ZWGgYHWUW";
  james-ryzen =
    "ssh-ed25519 AAAAC3NzaC1lZDI1NTE5AAAAICAXHtE9NI16ZPNSKF6Cn0JNJS6fTNQYduerVmVa6WKY";
  users = [ james-fractal james-hypernix james-ryzen ];

  fractal =
    "ssh-ed25519 AAAAC3NzaC1lZDI1NTE5AAAAIDdjavkGpkN4niiLWGAjNsaS3R3gxnLn7H4rTtkVkyAt";
  nexus =
    "ssh-ed25519 AAAAC3NzaC1lZDI1NTE5AAAAILmVRmGOyL441FQBbanju9x+VHqLKzwMoDk3dzWtHfKG";
  nixtarget1-hyperv =
    "ssh-ed25519 AAAAC3NzaC1lZDI1NTE5AAAAILiU0B1BYTeGojG+uo2siv2tpl7PEj3iV0CL8EHyM42e";
  nixtarget1-virtd =
    "ssh-ed25519 AAAAC3NzaC1lZDI1NTE5AAAAILozTQNcPY2BNQZNW+F29M2euRzD7wZ1XtsKsWFjzpeJ";

  test-nomads = [
    "ssh-ed25519 AAAAC3NzaC1lZDI1NTE5AAAAIDCXKdnyRuIWjhbHkh++ikDb3/UPiJucio+8CsZWIucE"
    "ssh-ed25519 AAAAC3NzaC1lZDI1NTE5AAAAILhwG7j+ysnXGXpXnUdUOIXO4m4LuWDdcmY0CTvPiRsp"
    "ssh-ed25519 AAAAC3NzaC1lZDI1NTE5AAAAIBmAxdrs5LhX835OMNUNqrlIXnIqTaLw35XMR9M8yR6A"
  ];

  systems = [ fractal nexus nixtarget1-hyperv nixtarget1-virtd ];
in {
  "cloudflare-dns-api.age".publicKeys = users ++ systems;

  "consul-encrypt.age".publicKeys = users ++ test-nomads;

  "influxdb-admin.age".publicKeys = users ++ systems;
  "influxdb-homeassistant.age".publicKeys = users ++ systems;
  "influxdb-telegraf.age".publicKeys = users ++ systems;

  "mqtt-admin.age".publicKeys = users ++ systems;
  "mqtt-sensor.age".publicKeys = users ++ systems;

  "nomad-encrypt.age".publicKeys = users ++ test-nomads;

  "nodered.age".publicKeys = users ++ systems;

  "tailscale.age".publicKeys = users ++ systems ++ test-nomads;
}
