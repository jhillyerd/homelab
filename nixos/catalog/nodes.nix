{ system }:
{
  agent-zero = {
    ip.priv = "192.168.131.8";
    config = ../hosts/agent-zero.nix;
    hw = ../hw/proxmox-vda.nix;
    system = system.x86_64-linux;
  };

  boss = {
    ip.priv = "192.168.131.12";
    ip.tail = "100.99.120.2";
    config = ../hosts/boss.nix;
    hw = ../hw/proxmox-vda.nix;
    system = system.x86_64-linux;
  };

  carbon = {
    ip.priv = "192.168.1.108";
    config = ../hosts/carbon.nix;
    hw = ../hw/tp-x1g3.nix;
    system = system.x86_64-linux;
  };

  ci-runner1 = {
    ip.priv = "192.168.131.4";
    config = ../hosts/ci-runner.nix;
    hw = ../hw/proxmox.nix;
    system = system.x86_64-linux;
  };

  fastd = {
    ip.priv = "192.168.131.5";
    hostId = "f4fa7292";
    config = ../hosts/fastd.nix;
    hw = ../hw/proxmox.nix;
    system = system.x86_64-linux;
  };

  fractal = {
    ip.priv = "192.168.128.20";
    config = ../hosts/fractal.nix;
    hw = ../hw/asus-b350.nix;
    system = system.x86_64-linux;
  };

  game = {
    ip.priv = "192.168.131.6";
    config = ../hosts/game.nix;
    hw = ../hw/proxmox.nix;
    system = system.x86_64-linux;
  };

  hermes = {
    ip.priv = "192.168.131.9";
    config = ../hosts/hermes.nix;
    hw = ../hw/proxmox-vda.nix;
    system = system.x86_64-linux;
  };

  metrics = {
    ip.priv = "192.168.128.41";
    ip.wg = "10.99.128.41";
    wg.pub = "tSEodiD+7Df78NzEukuBzpbsBB/nq8V+dZqQGix4z0o=";
    ip.tail = "100.108.135.101";
    config = ../hosts/metrics.nix;
    hw = ../hw/proxmox.nix;
    system = system.x86_64-linux;
  };

  nc-um350-1 = {
    ip.priv = "192.168.128.36";
    ip.wg = "10.99.128.36";
    wg.pub = "xsbCbvDSkNjAFxSJMqQLl4aTOjhjktaoi1RhQWIMB1I=";
    config = ../hosts/nc-um350.nix;
    hw = ../hw/minis-um350.nix;
    system = system.x86_64-linux;
    nomad.meta.zwave = "aeotec";
  };

  nc-um350-2 = {
    ip.priv = "192.168.128.37";
    ip.wg = "10.99.128.37";
    wg.pub = "LDSIOTB261u3Z95UzrjtaO6sRzwYHwCBmpXMAxrToGE=";
    config = ../hosts/nc-um350.nix;
    hw = ../hw/minis-um350.nix;
    system = system.x86_64-linux;
  };

  nc-virt-1 = {
    ip.priv = "192.168.133.1";
    ip.wg = "10.99.133.1";
    wg.pub = "8XEVbWXNKpmlEaxDvLTZTiiAbQ5yb+3RwFEgb2yH3Xc=";
    config = ../hosts/nc-virt.nix;
    hw = ../hw/proxmox.nix;
    system = system.x86_64-linux;
  };

  ryzen = {
    ip.priv = "192.168.1.50";
    ip.tail = "100.112.232.73";
    config = ../hosts/ryzen.nix;
    hw = ../hw/asus-x570p.nix;
    system = system.x86_64-linux;
  };

  scratch = {
    ip.priv = "192.168.131.2";
    config = ../hosts/scratch.nix;
    hw = ../hw/proxmox.nix;
    system = system.x86_64-linux;
  };

  web = {
    ip.priv = "192.168.128.11";
    ip.wg = "10.99.128.11";
    wg.pub = "TMb4xzFK7Q0LmQmCCnnP7IemonrhfWkDJfCpxAMyMgg=";
    ip.tail = "100.90.124.31";
    config = ../hosts/web.nix;
    hw = ../hw/proxmox.nix;
    system = system.x86_64-linux;
  };

  witness = {
    ip.priv = "192.168.131.3";
    ip.wg = "10.99.131.3";
    wg.pub = "GMWPzXyEtVppxG023OjHbC4B3Q2fbK4lEW4JM+sJLVk=";
    config = ../hosts/witness.nix;
    hw = ../hw/proxmox.nix;
    system = system.x86_64-linux;
  };
}
