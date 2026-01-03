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
            LLAMA_ARG_CTX_SIZE = "49152";
            LLAMA_ARG_JINJA = "true";
            LLAMA_ARG_TEMP = "0.15";
            LLAMA_ARG_MIN_P = "0.01";
            LLAMA_ARG_GPU_LAYERS = "99";
          };
          cmd = [
            "-hf"
            "unsloth/Devstral-Small-2-24B-Instruct-2512-GGUF:IQ4_NL"
          ];
        };
      };
    };
  };

  networking.firewall.enable = true;
  systemd.network.networks = util.mkClusterNetworks self;
}
