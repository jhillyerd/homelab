{ self, llm-agents, ... }:
{
  imports = [
    ../common.nix
    ../common/onprem.nix
  ];

  roles.workstation.enable = true;

  roles.tailscale.enable = true;

  # Kandev agent-execution container. The control plane runs on the Nomad
  # cluster, so publish SSH on the LAN address only.
  roles.kandev-agent = {
    enable = true;
    bindAddress = self.ip.priv;
    extraPackages = [ llm-agents.packages.${self.system}.pi ];
  };

  networking.networkmanager.enable = true;
  networking.firewall.enable = false;
  virtualisation.libvirtd.enable = true;

  roles.upsmon = {
    enable = true;
    wave = 2;
  };
}
