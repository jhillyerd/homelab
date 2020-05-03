{
  nexus =
    { config, pkgs, ... }:
    {
      deployment.targetEnv = "libvirtd";
      deployment.libvirtd = {
        storagePool = "default";
        memorySize = 2048; # megabytes
        vcpu = 2; # number of cpus
      };
    };
}
