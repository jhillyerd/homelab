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

  webserver =
    { config, pkgs, ... }:
    {
      deployment.targetEnv = "libvirtd";
      deployment.libvirtd = {
        storagePool = "default";
        memorySize = 1024; # megabytes
        vcpu = 1; # number of cpus
      };
    };
}
