# A scratch host for building up new service configurations.
{ pkgs, lib, self, ... }: {
  imports = [ ../common.nix ];

  roles.tailscale.enable = lib.mkForce false;

  users.users.root.initialPassword = "root";
  users.users.james.initialPassword = "james";

  networking.firewall.enable = false;
}
