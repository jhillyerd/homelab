{ ... }: {
  imports = [ ../common.nix ];

  roles.workstation.enable = true;
  roles.workstation.graphical = true;

  networking.networkmanager.enable = true;
  networking.firewall.enable = false;

  services.resolved.enable = true;

  # Backlight controls.
  programs.light.enable = true;
  services.actkbd = {
    enable = true;
    bindings = [
      { keys = [ 224 ]; events = [ "key" ]; command = "/run/current-system/sw/bin/light -U 10"; }
      { keys = [ 225 ]; events = [ "key" ]; command = "/run/current-system/sw/bin/light -A 10"; }
    ];
  };

  virtualisation.libvirtd.enable = true;
}
