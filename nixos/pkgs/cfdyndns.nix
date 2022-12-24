final: prev: {
  cfdyndns = prev.cfdyndns.overrideAttrs (oldAttrs: rec {
    pname = "cfdyndns";
    version = "0.0.3";

    src = prev.fetchFromGitHub {
      owner = "sysr-q";
      repo = "cfdyndns";
      rev = "4e703506df0298423a79be3e0efec7ecf6ae8680";
      sha256 = "0plijgr5y58ir9mjvxgm6jszz90pd1g0qjf21z0v5xrzg6bs2sy1";
    };

    cargoDeps = oldAttrs.cargoDeps.overrideAttrs (prev.lib.const {
      inherit src;
      name = "${pname}-vendor.tar.gz";
      outputHash = "YjOTtkffQRLX5qYiVYcZ8+Fh39ZNIIeA/0W5lnZuwfo=";
    });
  });
}
