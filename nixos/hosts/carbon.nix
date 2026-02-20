{ ... }:
{
  imports = [ ../common.nix ];

  roles.gui-sway.enable = true;
  roles.workstation.enable = true;

  # NetworkManager for wifi.
  networking = {
    firewall.enable = false;
    networkmanager.enable = true;
  };

  # systemd-network for everything else.
  systemd.network = {
    enable = true;
    wait-online.enable = false;
  };

  services.resolved.enable = true;

  # Backlight controls.
  programs.light.enable = true;
  services.actkbd = {
    enable = true;
    bindings = [
      {
        keys = [ 224 ];
        events = [ "key" ];
        command = "/run/current-system/sw/bin/light -U 10";
      }
      {
        keys = [ 225 ];
        events = [ "key" ];
        command = "/run/current-system/sw/bin/light -A 10";
      }
    ];
  };

  virtualisation.libvirtd.enable = true;
}
