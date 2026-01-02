{
  lib,
  pkgs,
  self,
  util,
  ...
}:
{
  imports = [
    ../common.nix
    ../common/onprem.nix
  ];

  roles.workstation.enable = true;

  environment.systemPackages = with pkgs; [
    nvtopPackages.nvidia
  ];

  networking.firewall.enable = false;
  systemd.network.networks = util.mkClusterNetworks self;

  virtualisation = {
    docker.enable = lib.mkForce false;
    containers.enable = true;
    podman = {
      enable = true;
      defaultNetwork.settings.dns_enabled = true;
    };

    oci-containers = {
      containers = {
        llama = {
          image = "ghcr.io/ggml-org/llama.cpp:server-cuda13-b7609";
          ports = [ "8080:8080" ];
          devices = [ "nvidia.com/gpu=all" ];
          extraOptions = [ "--ipc=host" ];
          volumes = [
            "/data/llama/cache:/root/.cache"
            "/data/llama/models:/models"
          ];
          environment = {
            LLAMA_ARG_PORT = "8080";
            LLAMA_ARG_CTX_SIZE = "512000";
            LLAMA_ARG_JINJA = "true";
          };
          cmd = [
            "-hf"
            "unsloth/Nemotron-3-Nano-30B-A3B-GGUF:IQ4_NL"
          ];
        };
      };
    };
  };
}
