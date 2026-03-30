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
  roles.gui-xfce.enable = true;

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
        embeddings = {
          image = "ollama/ollama:0.13.5";
          ports = [ "8002:11434" ];
          environment = {
            NVIDIA_VISIBLE_DEVICES = "all";
          };
          volumes = [
            "/data/embed/ollama:/root/.ollama"
          ];
          devices = [ "nvidia.com/gpu=all" ];
          extraOptions = [ "--ipc=host" ];
          entrypoint = "/bin/sh";
          cmd = [
            "-c"
            "ollama serve & sleep 5 && ollama pull nomic-embed-text && wait"
          ];
        };

        llama = {
          image = "ghcr.io/ggml-org/llama.cpp:server-cuda13-b8672";
          ports = [ "8001:8080" ]; # healthcheck runs against 8080.
          environment = {
            # Serving
            LLAMA_ARG_IMAGE_MIN_TOKENS = "1024"; # Improves small image results
            LLAMA_ARG_GPU_LAYERS = "all";
            # LLAMA_ARG_CTX_SIZE = "";
            # LLAMA_ARG_UBATCH = "1024"; # Faster PP, but more VRAM usage

            # Sampling
            LLAMA_ARG_TEMP = "0.6";
            LLAMA_ARG_MIN_P = "0.0";
            LLAMA_ARG_TOP_P = "0.95";
            LLAMA_ARG_TOP_K = "20";
            LLAMA_ARG_THINK_BUDGET = "1500";
            # LLAMA_ARG_REPEAT_PENALTY = "";
          };
          cmd = [
            "-hf"
            "unsloth/Qwen3.5-27B-GGUF:IQ4_NL"
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

  services.xrdp = {
    enable = true;
    openFirewall = true;
    defaultWindowManager = "xfce4-session";
  };

  fileSystems."/data/embed" = {
    device = "/dev/tank/embed";
    fsType = "ext4";
  };

  fileSystems."/data/llama" = {
    device = "/dev/tank/llama";
    fsType = "ext4";
  };

  networking.firewall.enable = true;
  systemd.network.networks = util.mkClusterNetworks self;
}
