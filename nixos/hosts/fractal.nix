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
        vllm = {
          # JRamirez-UAB EXL3 4.00bpw of Qwen3.6-35B-A3B served on vLLM.
          # Replaced llama.cpp (Oct 2026): aggregate decode collapsed under
          # concurrency (66 t/s single-stream but 7 t/s total at c3 after long
          # prefills), while this exact stack is validated by the model author
          # on an RTX 3090 24GB: 118 t/s single / 204 t/s with 2 concurrent
          # sessions, full 262k context, vision and MTP, ~1 GiB VRAM spare.
          # EXL3 is not a native vLLM format, hence the custom image (pinned
          # vLLM 0.31.0 + exllamav3 1.5.1 + OrcaSAQ2-kernel +
          # qwen38_exl3_vision plugins) built by fractal-vllm-image.service
          # from ./fractal-vllm/Containerfile. Bump nothing in isolation;
          # re-validate against the HF model card's tested stack. The llama.cpp
          # config this replaced is in git history (b11723 container, last
          # touched fc06944 era) if it ever needs to come back.
          image = "vllm-qwen36-exl3:v0.31.0";
          ports = [ "8000:8000" ];

          environment = {
            # Required by the fused EXL3 MoE kernel: it synchronises blocks
            # through global counters and needs the whole GPU -- without this
            # vLLM runs the shared expert on a side stream and decode hangs
            # after a few seconds (the plugin sets it; kept belt-and-braces).
            VLLM_DISABLE_SHARED_EXPERTS_STREAM = "1";
            # Match the model card's validated quick start.
            PYTORCH_CUDA_ALLOC_CONF = "expandable_segments:True";
            VLLM_USE_FLASHINFER_SAMPLER = "0";
          };

          # Flags follow the model card's Quick start (single RTX 3090):
          #   - 2 sessions x full context; HINDSIGHT_API_LLM_MAX_CONCURRENT=2
          #     in nomad/hindsight.nomad already matches.
          #   - MTP-1 only: deeper speculation activates extra experts per
          #     verified token and measured slower on MoE.
          #   - cudagraph capture 16 = max-num-seqs 2 x (1 + MTP 1): every
          #     decode step replays a graph. Raise both together for more
          #     sessions (card's "many users" profile: 32 seqs / capture 64,
          #     ~700 t/s aggregate at 16 concurrent).
          #   - fp8 KV (storage-only on Ampere, still ~2x capacity); this
          #     hybrid model's KV is tiny (~13 KiB/token fp8), so 262k context
          #     fits next to the 17.6 GiB of weights.
          #   - Vision stays on: the qwen38_exl3_vision plugin is required
          #     for the MoE experts regardless, so dropping vision saves no
          #     plugin complexity. max_pixels ~1MP; if tiny-image quality
          #     regresses (llama.cpp forced >=1024 image tokens via
          #     IMAGE_MIN_TOKENS), add min_pixels 802816 to mm-processor-kwargs.
          #   - enable_thinking=false replaces llama.cpp's think-budget=1024
          #     safety net: every lane routed here is a no-think lane
          #     (HINDSIGHT_API_LLM_REASONING_EFFORT=none); callers can still
          #     opt in per-request via chat_template_kwargs.
          #   - Sampling defaults now come from the checkpoint's
          #     generation_config (temp 1.0) instead of llama.cpp's 0.6. Lanes
          #     that care pin temperature per request already; if un-pinned
          #     document synthesis degrades, set an explicit temperature
          #     override in nomad/hindsight.nomad.
          cmd = [
            "JRamirez-UAB/Qwen3.6-35B-A3B-EXL3-4.00bpw-24GB"
            "--served-model-name" "qwen3.6-35b-a3b"
            "--max-model-len" "262144"
            "--kv-cache-dtype" "fp8_e4m3"
            "--kv-cache-memory-bytes" "3500000000"
            "--max-num-batched-tokens" "1024"
            "--max-num-seqs" "2"
            "--enable-prefix-caching"
            "--speculative-config" ''{"method":"mtp","num_speculative_tokens":1}''
            "--compilation-config" ''{"max_cudagraph_capture_size":16}''
            "--limit-mm-per-prompt" ''{"image":1,"video":0}''
            "--mm-processor-kwargs" ''{"max_pixels":1003520}''
            "--reasoning-parser" "qwen3"
            "--default-chat-template-kwargs" ''{"enable_thinking": false}''
            "--enable-auto-tool-choice"
            "--tool-call-parser" "qwen3_coder"
          ];
          # First activation is slow: ~19 GB of weights download into the
          # cache volume, plus torch.compile / flashinfer JIT warm-up.
          volumes = [
            "/data/llama/cache:/root/.cache"
          ];
          devices = [ "nvidia.com/gpu=all" ];
          extraOptions = [
            "--ipc=host"
            "--health-cmd=python3 -c \"import sys, urllib.request as u; sys.exit(0 if u.urlopen('http://localhost:8000/health', timeout=5).status == 200 else 1)\""
            "--health-interval=30s"
            "--health-timeout=10s"
            "--health-retries=3"
            "--health-start-period=15m"
          ];
        };
      };
    };
  };

  # Build the vLLM/EXL3 image before the container starts. Idempotent
  # (layer-cached after the first run) but the base image is ~10 GB, so the
  # first activation on a fresh install takes a while; podman-vllm restarts
  # until the image exists, so a slow build degrades to a late start, not a
  # failure.
  systemd.services.fractal-vllm-image = {
    description = "Build vllm-qwen36-exl3 container image";
    wants = [ "network-online.target" ];
    after = [ "network-online.target" ];
    before = [ "podman-vllm.service" ];
    wantedBy = [ "multi-user.target" ];
    serviceConfig = {
      Type = "oneshot";
      RemainAfterExit = true;
    };
    path = with pkgs; [ podman ];
    script = ''
      podman build -t vllm-qwen36-exl3:v0.31.0 ${./fractal-vllm}
    '';
  };

  fileSystems."/data/llama" = {
    device = "/dev/tank/llama";
    fsType = "ext4";
  };

  networking.firewall.enable = true;
  systemd.network.networks = util.mkClusterNetworks self;
}
