# Kandev agent-execution container (SSH executor target, "Host B").
#
# Long-lived podman container running sshd: Kandev connects over SSH and
# never knows the target is a container. Persistent state (agent home and
# SSH host keys, which Kandev pins) lives on the host filesystem so tooling
# installed once survives rebuilds and stays visible to every session.
#
# First boot: add the Kandev SSH public key before it can connect:
#   echo '<ed25519 pub key>' >> /srv/kandev-agent/home/.ssh/authorized_keys
# Git identity must also be configured inside the container once (the SSH
# executor does not apply its Git name/email fields).
#
# Design notes: ~/devel/planning/homelab/plans/kandev-nix-container.md
{
  config,
  pkgs,
  lib,
  ...
}:
with lib;
let
  cfg = config.roles.kandev-agent;

  agentUser = "agent"; # SSH login user; remote-auth material lands in this home
  agentUid = 1000;

  # FHS compatibility: the real ELF interpreter, and the library dirs the
  # nix-ld shim should expose to binaries downloaded by agents.
  realLoader = fileContents "${pkgs.stdenv.cc.bintools}/nix-support/dynamic-linker";
  # Conventional PT_INTERP path that prebuilt (non-Nix) binaries request.
  # The nix-ld shim is placed here; it reads NIX_LD/NIX_LD_LIBRARY_PATH and
  # execs the real loader. Do NOT shadow the store loader itself: every
  # Nix-built binary in the image uses it as PT_INTERP.
  conventionalLoaderDir = if pkgs.stdenv.hostPlatform.isx86_64 then "/lib64" else "/lib";
  fhsLibs = makeLibraryPath (
    with pkgs;
    [
      stdenv.cc.cc.lib # libstdc++
      zlib
      zstd
      xz
      bzip2
      openssl
    ]
  );

  # Publish spec: [<bindAddress>]:<port>:22, omitting the address publishes
  # on all interfaces.
  publishPort = concatStringsSep ":" (
    filter (s: s != "") [
      (optionalString (cfg.bindAddress != null) cfg.bindAddress)
      (toString cfg.port)
      "22"
    ]
  );

  sshdConfig = pkgs.writeText "sshd_config" ''
    Port 22
    HostKey /var/lib/ssh/ssh_host_ed25519_key
    HostKey /var/lib/ssh/ssh_host_rsa_key

    PermitRootLogin no
    PasswordAuthentication no
    KbdInteractiveAuthentication no
    PubkeyAuthentication yes
    AllowUsers agent
    UsePAM no

    # Kandev opens one SSH connection per session and port-forwards the
    # agentctl controller back to its loopback.
    AllowTcpForwarding yes
    PermitOpen any
    X11Forwarding no
    MaxSessions 32
    MaxStartups 30

    Subsystem sftp internal-sftp
    # Same exports for non-login command sessions (ssh host <cmd> runs
    # bash -c, which never reads /etc/profile). Login shells get them from
    # /etc/profile instead. PATH/NPM_CONFIG_PREFIX mirror the profile so
    # npm/npx resolve the persistent ~/.npm-global prefix in both cases.
    SetEnv PATH=/home/${agentUser}/.npm-global/bin:/bin:/sbin NPM_CONFIG_PREFIX=/home/${agentUser}/.npm-global NIX_LD=${realLoader} NIX_LD_LIBRARY_PATH=${fhsLibs} LD_LIBRARY_PATH=${pkgs.stdenv.cc.cc.lib}/lib SSL_CERT_FILE=${pkgs.cacert}/etc/ssl/certs/ca-bundle.crt
    ClientAliveInterval 300
    ClientAliveCountMax 3
    PrintMotd no
    LogLevel VERBOSE
  '';

  entrypoint = pkgs.writeShellScriptBin "kandev-agent-entrypoint" ''
    set -euo pipefail

    # Host keys live in a persistent volume: Kandev pins the host key
    # fingerprint and refuses a changed key, so they must survive restarts.
    mkdir -p /var/lib/ssh
    [ -e /var/lib/ssh/ssh_host_ed25519_key ] || ssh-keygen -t ed25519 -N "" -f /var/lib/ssh/ssh_host_ed25519_key
    [ -e /var/lib/ssh/ssh_host_rsa_key ]     || ssh-keygen -t rsa -b 3072 -N "" -f /var/lib/ssh/ssh_host_rsa_key

    # OpenSSH privilege separation
    mkdir -p /var/empty && chmod 711 /var/empty
    mkdir -p /run/sshd /tmp && chmod 1777 /tmp

    exec "$(command -v sshd)" -D -e
  '';

  agentImage = pkgs.dockerTools.buildLayeredImage {
    name = "kandev-agent-host";
    tag = "latest";
    contents = [ agentRoot ];
    config = {
      Entrypoint = [ "/bin/kandev-agent-entrypoint" ];
      Env = [
        "PATH=/bin:/sbin"
        "SSL_CERT_FILE=${pkgs.cacert}/etc/ssl/certs/ca-bundle.crt"
      ];
    };
    fakeRootCommands = ''
      install -D -m 644 ${sshdConfig} etc/ssh/sshd_config

      echo 'root:x:0:0::/root:/bin/bash' > etc/passwd
      # OpenSSH 9.8+ fatals at startup without a privilege separation user.
      echo 'sshd:x:74:74:Privilege separation user:/var/empty:/sbin/nologin' >> etc/passwd
      echo '${agentUser}:x:${toString agentUid}:${toString agentUid}::/home/${agentUser}:/bin/bash' >> etc/passwd
      echo 'root:x:0:' > etc/group
      echo 'sshd:x:74:' >> etc/group
      echo '${agentUser}:x:${toString agentUid}:' >> etc/group
      echo 'hosts: files dns' > etc/nsswitch.conf

      # FHS shim: npm/pip .bin shims shebang `#!/usr/bin/env <tool>`.
      # The image has no /usr tree otherwise, and the store closure only
      # links /bin, so provide the conventional location.
      mkdir -p usr/bin
      ln -s ${pkgs.coreutils}/bin/env usr/bin/env

      # nix-ld shim at the conventional loader path (see above). Paths are
      # relative: fakeRootCommands run with the image root as CWD.
      mkdir -p .${conventionalLoaderDir}
      ln -s ${pkgs.nix-ld}/libexec/nix-ld .${conventionalLoaderDir}/${baseNameOf realLoader}

      # Login shells source this: runtime-installed tooling (npm -g, etc.)
      # persists in the mounted home and stays visible to Kandev sessions.
      # The interactive block is the skeleton equivalent (there is no
      # /etc/skel flow: the home is a pre-made bind mount).
      cat > etc/profile <<'PROFILE'
      export PATH="$HOME/.npm-global/bin:/bin:/sbin"
      export NPM_CONFIG_PREFIX="$HOME/.npm-global"
      export NIX_LD=${realLoader}
      export NIX_LD_LIBRARY_PATH=${fhsLibs}
      export LD_LIBRARY_PATH=${pkgs.stdenv.cc.cc.lib}/lib
      export SSL_CERT_FILE=${pkgs.cacert}/etc/ssl/certs/ca-bundle.crt

      if [ -n "''${PS1:-}" ]; then
        PS1='\u@\h:\w\$ '
        alias ll='ls -l'
        alias la='ls -lAh'
        alias grep='grep --color=auto'
        # Per-user overrides live in the persistent home.
        [ -f "$HOME/.bashrc" ] && . "$HOME/.bashrc"
      fi
      PROFILE

      mkdir -p home/${agentUser} root var/empty
      chmod 711 var/empty
      chown ${toString agentUid}:${toString agentUid} home/${agentUser}
    '';
  };

  agentRoot = pkgs.buildEnv {
    name = "kandev-agent-root";
    paths =
      with pkgs;
      [
        entrypoint
        # SSH executor requirements: bash login shell, git
        bashInteractive
        coreutils
        curl
        findutils
        gawk
        gh
        git
        gnugrep
        gnused
        less
        openssh
        procps
        which
        # agent CLIs + repo tooling
        nodejs
        python3
        # Toolchain so agents can build native npm modules (node-gyp)
        gcc
        gnumake
        pkg-config
        unzip
        gnutar
        # Inspection/repair for agent-downloaded binaries
        patchelf
        file
        binutils
        # FHS shim, see fakeRootCommands
        nix-ld
        cacert
        # Other tools
        bat
        bzip2
        chezmoi
        cmake
        diffutils
        fd
        gzip
        jq
        lsof
        neovim
        openssl
        patch
        ripgrep
        tree
        uv
        wget
        zstd
      ]
      ++ cfg.extraPackages;
    pathsToLink = [
      "/bin"
      "/sbin"
    ];
  };
in
{
  options.roles.kandev-agent = with types; {
    enable = mkEnableOption "Kandev agent-execution container (SSH executor target)";

    port = mkOption {
      type = port;
      description = "Host port published for the container's SSH daemon.";
      default = 2222;
    };

    bindAddress = mkOption {
      type = nullOr str;
      description = "Address to bind the published SSH port to. Null binds all interfaces.";
      default = null;
    };

    stateDir = mkOption {
      type = path;
      description = "Host directory backing persistent state (agent home, SSH host keys).";
      default = "/srv/kandev-agent";
    };

    extraPackages = mkOption {
      type = listOf package;
      description = "Additional packages installed into the container image (e.g. agent CLIs).";
      default = [ ];
    };
  };

  config = mkIf cfg.enable {
    virtualisation = {
      containers.enable = true;
      podman.enable = true;

      oci-containers = {
        backend = "podman";

        containers.kandev-agent = {
          image = "kandev-agent-host:latest";
          imageFile = agentImage; # built locally, no registry pull
          autoStart = true;
          ports = [ publishPort ];
          volumes = [
            "${cfg.stateDir}/home:/home/${agentUser}" # tooling, caches, ~/.kandev task dirs
            "${cfg.stateDir}/ssh:/var/lib/ssh" # pinned host keys
          ];
          extraOptions = [
            "--memory=8g"
            "--cpus=4"
          ];
        };
      };
    };

    systemd.tmpfiles.rules = [
      "d ${cfg.stateDir}/home 0700 ${toString agentUid} ${toString agentUid} -"
      "d ${cfg.stateDir}/home/.ssh 0700 ${toString agentUid} ${toString agentUid} -"
      "d ${cfg.stateDir}/ssh 0700 0 0 -"
    ];

    networking.firewall.allowedTCPPorts = [ cfg.port ];
  };
}
