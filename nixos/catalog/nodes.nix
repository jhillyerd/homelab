{ system }: {
  eph = {
    ip.priv = "192.168.128.44";
    ip.tail = "100.119.252.34";
    config = ../hosts/eph.nix;
    hw = ../hw/proxmox.nix;
    system = system.x86_64-linux;
  };

  fractal = {
    ip.priv = "192.168.1.12";
    ip.tail = "100.112.232.73";
    config = ../hosts/fractal.nix;
    hw = ../hw/asus-b350.nix;
    system = system.x86_64-linux;
  };

  nc-um350-1 = {
    ip.priv = "192.168.128.36";
    ip.tail = "100.109.33.10";
    config = ../hosts/nc-um350.nix;
    hw = ../hw/minis-um350.nix;
    system = system.x86_64-linux;
  };

  nc-um350-2 = {
    ip.priv = "192.168.128.37";
    ip.tail = "100.97.169.111";
    config = ../hosts/nc-um350.nix;
    hw = ../hw/minis-um350.nix;
    system = system.x86_64-linux;
  };

  nexus = {
    ip.priv = "192.168.128.40";
    ip.tail = "100.96.6.112";
    config = ../hosts/nexus.nix;
    hw = ../hw/proxmox.nix;
    system = system.x86_64-linux;
  };

  nixpi3 = {
    config = ../hosts/nixpi3.nix;
    hw = ../hw/sd-image-pi3.nix;
    system = system.aarch64-linux;
  };

  scratch = {
    ip.priv = "10.0.2.15";
    config = ../hosts/scratch.nix;
    hw = ../hw/qemu.nix;
    system = system.x86_64-linux;
  };

  web = {
    ip.priv = "192.168.128.11";
    ip.tail = "100.90.124.31";
    config = ../hosts/web.nix;
    hw = ../hw/proxmox.nix;
    system = system.x86_64-linux;
  };
}
