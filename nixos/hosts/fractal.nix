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
  roles.telegraf.nvidia_smi = true;

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
          image = "ghcr.io/ggml-org/llama.cpp:server-cuda-b10830";
          ports = [ "8000:8080" ]; # healthcheck runs against 8080.
          environment = {
            # Serving
            LLAMA_ARG_IMAGE_MIN_TOKENS = "1024"; # Improves small image results
            LLAMA_ARG_GPU_LAYERS = "all";
            # LLAMA_ARG_CTX_SIZE = "";
            LLAMA_ARG_UBATCH = "1024"; # Faster PP, but more VRAM usage

            # Sampling
            LLAMA_ARG_TEMP = "0.6";
            LLAMA_ARG_MIN_P = "0.0";
            LLAMA_ARG_TOP_P = "0.95";
            LLAMA_ARG_TOP_K = "20";
            # LLAMA_ARG_THINK_BUDGET = "1000";
            # LLAMA_ARG_REPEAT_PENALTY = "";
          };
          cmd = [
            "-hf"
            "peculiar-ragdoll/Tiel-Coder-35B-A3B-GGUF-MTP:UD-IQ4_XS"
          ];
          volumes = [
            "/data/llama/cache:/root/.cache"
          ];
          devices = [ "nvidia.com/gpu=all" ];
          extraOptions = [ "--ipc=host" ];
        };
      };
    };
  };

  fileSystems."/data/llama" = {
    device = "/dev/tank/llama";
    fsType = "ext4";
  };

  networking.firewall.enable = true;
  systemd.network.networks = util.mkClusterNetworks self;
}
