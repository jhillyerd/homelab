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
  roles.gui-sway.enable = true;

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
        ollama =
          let
            modelName = "Nemotron-3-Nano-30B-A3B-GGUF";
            modelPath = "hf.co/unsloth/${modelName}:IQ4_NL";
            modelFile = pkgs.writeText "ollama-modelfile" ''
              FROM ${modelPath}

              PARAMETER temperature 0.6
              PARAMETER top_p 0.95
              PARAMETER min_p 0
              PARAMETER top_k -1

              PARAMETER num_ctx 262144
              PARAMETER num_predict 32768
              PARAMETER num_gpu 99

              RENDERER nemotron-3-nano
              PARSER nemotron-3-nano
              TEMPLATE {{ .Prompt }}
            '';
          in
          {
            image = "ollama/ollama:0.13.5";
            ports = [ "11434:11434" ];
            environment = {
              NVIDIA_VISIBLE_DEVICES = "all";
              OLLAMA_KEEP_ALIVE = "-1";
            };
            volumes = [
              "/data/ollama:/root/.ollama"
              "${modelFile}:/Modelfile:ro"
            ];
            devices = [ "nvidia.com/gpu=all" ];
            extraOptions = [ "--ipc=host" ];
            entrypoint = "/bin/sh";
            cmd = [
              "-c"
              ''
                ollama serve &
                sleep 5
                ollama pull nomic-embed-text
                ollama create "${modelName}" -f /Modelfile

                # Preload the model
                ollama run "${modelName}" ""
                wait
              ''
            ];
          };
      };
    };
  };

  fileSystems."/data/ollama" = {
    device = "/dev/tank/ollama";
    fsType = "ext4";
  };

  networking.firewall.enable = true;
  systemd.network.networks = util.mkClusterNetworks self;
}
