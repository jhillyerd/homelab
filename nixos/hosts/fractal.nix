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
        llama = {
          image = "ghcr.io/ggml-org/llama.cpp:server-cuda13-b8895";
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
            LLAMA_ARG_THINK_BUDGET = "1000";
            # LLAMA_ARG_REPEAT_PENALTY = "";
          };
          cmd = [
            "-hf"
            "unsloth/Qwen3.6-35B-A3B-GGUF:UD-IQ4_NL_XL"
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

  fileSystems."/data/llama" = {
    device = "/dev/tank/llama";
    fsType = "ext4";
  };

  networking.firewall.enable = true;
  systemd.network.networks = util.mkClusterNetworks self;
}
