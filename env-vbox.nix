{
  nexus =
    { config, pkgs, ... }:
    {
      deployment.targetEnv = "virtualbox";
      deployment.virtualbox = {
        headless = true;
        memorySize = 2048; # megabytes
        vcpu = 2; # number of cpus
      };
    };

  webserver =
    { config, pkgs, ... }:
    {
      deployment.targetEnv = "virtualbox";
      deployment.virtualbox = {
        headless = true;
        memorySize = 1024; # megabytes
        vcpu = 1; # number of cpus
      };
    };
}
