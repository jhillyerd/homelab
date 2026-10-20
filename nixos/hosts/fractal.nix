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
            # Serving. LFM2.5-24B-A2B is text-only (30 conv + 10 GQA
            # layers, 8 KV heads, head_dim 64 → ~20 KiB/token of KV).
            LLAMA_ARG_GPU_LAYERS = "all";
            LLAMA_ARG_UBATCH = "1024"; # Faster PP, but more VRAM usage

            # Explicit parallelism so llama.cpp partitions the KV pool into
            # fixed per-slot buffers. With n_parallel on auto it enables
            # kv_unified, and 4 slots competing for contiguous ranges in the
            # shared 3090-sized pool fragment it — requests well under the
            # nominal capacity died with "Context size has been exceeded".
            # 3 x 131072 = full native context per slot. LFM2.5-24B-A2B is
            # text-only hybrid (30 conv + 10 GQA layers, 8 KV heads, head_dim
            # 64 = 20 KiB/token fp16); the q8_0 KV cache below halves that
            # to ~10 KiB/token, so the pool costs ~3.6 GiB and leaves ~3.5
            # GiB VRAM headroom over the 14.9 GiB of Q4_K_XL weights for
            # compute buffers.
            LLAMA_ARG_N_PARALLEL = "3";
            LLAMA_ARG_CTX_SIZE = "393216";

            # Quantized KV cache (near-lossless at q8_0): halves the
            # per-token KV cost so every slot gets full native context.
            # Requires flash attention, so pin it on rather than auto.
            LLAMA_ARG_FLASH_ATTN = "on";
            LLAMA_ARG_CACHE_TYPE_K = "q8_0";
            LLAMA_ARG_CACHE_TYPE_V = "q8_0";

            # Self-speculative drafting from the request's own n-grams — no
            # draft model, no extra VRAM, output distribution unchanged
            # (rejected drafts are resampled by the target model). Chosen for
            # the summarization / memory-consolidation workload, which copies
            # verbatim from context, so acceptance should be high. A/B the
            # ngram-map-k4v variant (longer repeated spans) if curious;
            # acceptance rate shows up in llamacpp:spec_* on /metrics.
            LLAMA_ARG_SPEC_TYPE = "ngram-map-k";

            # Monitoring: expose Prometheus-format /metrics, scraped by the
            # prometheus host (job "llama"). Concurrency gauges of interest:
            # llamacpp:requests_processing / requests_deferred /
            # n_busy_slots_per_decode (see tools/server/README.md).
            LLAMA_ARG_ENDPOINT_METRICS = "1";

            # Sampling: LiquidAI-recommended (generation_config.json).
            # Always-reasoning model; <think> handled by the chat template,
            # so no --think-budget knob.
            LLAMA_ARG_TEMP = "0.1";
            LLAMA_ARG_TOP_K = "50";
            LLAMA_ARG_REPEAT_PENALTY = "1.05";
          };
          cmd = [
            "-hf"
            "unsloth/LFM2.5-24B-A2B-GGUF:UD-Q4_K_XL"
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
