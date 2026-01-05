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
  roles.gui-wayland.enable = true;

  environment.systemPackages = with pkgs; [
    nvtopPackages.nvidia
  ];

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
          ports = [ "8001:8080" ]; # healthcheck runs against 8080.
          devices = [ "nvidia.com/gpu=all" ];
          extraOptions = [ "--ipc=host" ];
          volumes = [
            "/data/llama/cache:/root/.cache"
            "/data/llama/models:/models"
          ];
          environment = {
            LLAMA_ARG_CTX_SIZE = "65536";
            LLAMA_ARG_JINJA = "true";
            LLAMA_ARG_TEMP = "0.7";
            LLAMA_ARG_TOP_K = "20";
            LLAMA_ARG_MIN_P = "0.0";
            LLAMA_ARG_TOP_P = "0.8";
            LLAMA_ARG_REPEAT_PENALTY = "1.05";
            LLAMA_ARG_GPU_LAYERS = "99";
          };
          cmd = [
            "-hf"
            "unsloth/Qwen3-Coder-30B-A3B-Instruct-GGUF:IQ4_NL"
          ];
        };
      };
    };
  };

  networking.firewall.enable = true;
  systemd.network.networks = util.mkClusterNetworks self;
}
