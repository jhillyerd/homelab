final: prev: {
  cfdyndns = prev.cfdyndns.overrideAttrs (oldAttrs: rec {
    pname = "cfdyndns";
    version = "0.3";

    src = prev.fetchFromGitHub {
      owner = "colemickens";
      repo = "cfdyndns";
      rev = "dfd6200bedc27ade55b24f396a773201c625de92";
      sha256 = "sha256-4f26oQIFnfyVUbahl476xq2vJ5DcFZ8AWetqBm2kDHE=";
    };

    cargoDeps = oldAttrs.cargoDeps.overrideAttrs (prev.lib.const {
      inherit src;
      name = "${pname}-vendor.tar.gz";
      outputHash = "sha256-JQIljUx6J2Ru/OAJsB77u/qTyk2TR2vTgJSltNmPHpg=";
    });
  });
}
