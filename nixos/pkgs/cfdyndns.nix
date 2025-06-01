{
  fetchFromGitHub,
  rustPlatform,
  pkg-config,
  openssl,
}:
with rustPlatform;
buildRustPackage {
  pname = "cfdyndns";
  version = "0.0.3";

  src = fetchFromGitHub {
    owner = "sysr-q";
    repo = "cfdyndns";
    rev = "4e703506df0298423a79be3e0efec7ecf6ae8680";
    sha256 = "0plijgr5y58ir9mjvxgm6jszz90pd1g0qjf21z0v5xrzg6bs2sy1";
  };

  cargoHash = "sha256-celZ1QtGlgmhRax1SzXorl82NA8yw/Ik7uXwKxH0RSg=";

  nativeBuildInputs = [ pkg-config ];
  buildInputs = [ openssl ];
}
