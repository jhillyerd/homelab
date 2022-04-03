{ pkgs, faasd, ... }:
let
  # Import low security credentials.
  lowsec = import ./../lowsec.nix;
in {
  imports = [ faasd.nixosModules.faasd ];

  services.faasd = let
    passwordFile = pkgs.writeText "faasd-basic-auth" lowsec.faasd.admin.password;
  in {
    enable = true;
    basicAuth = {
      enable = true;
      user = lowsec.faasd.admin.user;
      passwordFile = "${passwordFile}";
    };
  };

  networking.firewall.allowedTCPPorts = [ 8080 ];
}
