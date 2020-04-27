{
  webserver =
    { config, pkgs, ... }:
    {
      deployment.targetEnv = "virtualbox";
      deployment.virtualbox = {
        headless = true;
        memorySize = 2048; # megabytes
        vcpu = 2; # number of cpus
      };
    };
}
