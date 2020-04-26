{
  webserver =
    { config, pkgs, ... }:
    { deployment.targetEnv = "libvirtd";
      deployment.libvirtd.imageDir = "/var/lib/libvirt/images";
      deployment.libvirtd.memorySize = 1024; # megabytes
      deployment.libvirtd.vcpu = 2; # number of cpus
    };
}
