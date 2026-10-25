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
          image = "ghcr.io/ggml-org/llama.cpp:server-cuda-b11723";
          ports = [ "8000:8080" ]; # healthcheck runs against 8080.
          environment = {
            # Back on Qwen3.6-35B-A3B after the LFM2.5-24B-A2B experiment
            # (Oct 19–25): LFM's pythonic tool-call format kept emitting
            # malformed done-document args through llama.cpp — deterministically
            # truncated pages, ID leakage, json_repair "fixing" stubs into place
            # across every Hindsight bank. Qwen's JSON tool calls ride llama.cpp's
            # mature Qwen parser, and this exact config is the known-good one from
            # Sep 30 – Oct 19 (fc06944 + a7ae3d5); the quant blob is verified
            # byte-current against unsloth main, so no re-download.

            # Serving. Qwen3.6-35B-A3B is a hybrid-recurrent multimodal MoE
            # (~6 KiB/token of KV; the mmproj vision encoder loads with -hf).
            LLAMA_ARG_IMAGE_MIN_TOKENS = "1024"; # Improves small image results
            LLAMA_ARG_GPU_LAYERS = "all";
            LLAMA_ARG_UBATCH = "1024"; # Faster PP, but more VRAM usage

            # Explicit parallelism so llama.cpp partitions the KV pool into
            # fixed per-slot buffers. With n_parallel on auto it enables
            # kv_unified, and 4 slots competing for contiguous ranges in the
            # shared 3090-sized pool fragment it — requests well under the
            # nominal capacity died with "Context size has been exceeded".
            # 3 x 196608 = 192k per slot; ~3.45 GiB of KV at ~6 KiB/token,
            # leaving ~1.4 GiB VRAM headroom over the 19.5 GiB of IQ4_NL_XL
            # weights for the vision encoder and compute buffers.
            LLAMA_ARG_N_PARALLEL = "3";
            LLAMA_ARG_CTX_SIZE = "589824";

            # NOTE: the LFM-era serving flags (FLASH_ATTN=on, q8_0 KV cache,
            # ngram spec decoding) are deliberately NOT carried over — none of
            # them ever ran on Qwen here, and this change is about returning to
            # a known-good baseline. Re-add them one at a time with A/B if the
            # slower decode hurts: ngram spec especially suits the verbatim-copy
            # consolidation workload (and was proven unrelated to the LFM
            # corruption via a no-spec container test on Oct 25).

            # Monitoring: expose Prometheus-format /metrics, scraped by the
            # prometheus host (job "llama"). Concurrency gauges of interest:
            # llamacpp:requests_processing / requests_deferred /
            # n_busy_slots_per_decode (see tools/server/README.md).
            LLAMA_ARG_ENDPOINT_METRICS = "1";

            # Sampling: Qwen-recommended (as per the pre-LFM config).
            LLAMA_ARG_TEMP = "0.6";
            LLAMA_ARG_MIN_P = "0.0";
            LLAMA_ARG_TOP_P = "0.95";
            LLAMA_ARG_TOP_K = "20";

            # --reasoning-budget (env name unchanged since the
            # Qwen3.5 days) auto-detects the think tags from the rendered
            # prompt and forces </think> once N thinking tokens are spent.
            LLAMA_ARG_THINK_BUDGET = "1024";
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

  fileSystems."/data/llama" = {
    device = "/dev/tank/llama";
    fsType = "ext4";
  };

  networking.firewall.enable = true;
  systemd.network.networks = util.mkClusterNetworks self;
}
