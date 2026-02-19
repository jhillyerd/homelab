{ system }:
{
  agent-zero = {
    ip.priv = "192.168.131.8";
    config = ../hosts/agent-zero.nix;
    hw = ../hw/proxmox.nix;
    system = system.x86_64-linux;
  };

  boss = {
    ip.priv = "192.168.1.30";
    ip.tail = "100.115.100.34";
    config = ../hosts/boss.nix;
    hw = ../hw/bosgame-m4.nix;
    system = system.x86_64-linux;
  };

  carbon = {
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

  eph = {
    ip.priv = "192.168.128.44";
    ip.tail = "100.119.252.34";
    config = ../hosts/eph.nix;
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

  kube1 = {
    ip.priv = "192.168.132.1";
    config = ../hosts/k3s.nix;
    hw = ../hw/proxmox.nix;
    system = system.x86_64-linux;
  };

  kube2 = {
    ip.priv = "192.168.132.2";
    config = ../hosts/k3s.nix;
    hw = ../hw/proxmox.nix;
    system = system.x86_64-linux;
  };

  metrics = {
    ip.priv = "192.168.128.41";
    ip.tail = "100.108.135.101";
    config = ../hosts/metrics.nix;
    hw = ../hw/proxmox.nix;
    system = system.x86_64-linux;
  };

  nc-um350-1 = {
    ip.priv = "192.168.128.36";
    config = ../hosts/nc-um350.nix;
    hw = ../hw/minis-um350.nix;
    system = system.x86_64-linux;
    nomad.meta.zwave = "aeotec";
  };

  nc-um350-2 = {
    ip.priv = "192.168.128.37";
    config = ../hosts/nc-um350.nix;
    hw = ../hw/minis-um350.nix;
    system = system.x86_64-linux;
  };

  nc-virt-1 = {
    ip.priv = "192.168.133.1";
    config = ../hosts/nc-virt.nix;
    hw = ../hw/proxmox.nix;
    system = system.x86_64-linux;
  };

  nexus = {
    ip.priv = "192.168.128.40";
    ip.tail = "100.96.6.112";
    config = ../hosts/nexus.nix;
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
    ip.tail = "100.90.124.31";
    config = ../hosts/web.nix;
    hw = ../hw/proxmox.nix;
    system = system.x86_64-linux;
  };

  witness = {
    ip.priv = "192.168.131.3";
    config = ../hosts/witness.nix;
    hw = ../hw/proxmox.nix;
    system = system.x86_64-linux;
  };
}
