{ lib, buildGoModule, fetchFromGitLab, pkg-config, libusb1 }:
buildGoModule rec {
  pname = "nomad-usb-device-plugin";
  version = "0.4.0";

  src = fetchFromGitLab {
    owner = "CarbonCollins";
    repo = pname;
    rev = version;

    hash = "sha256-k5L07CzQkY80kHszCLhqtZ0LfGGuV07LrHjvdgy04bk=";
  };

  vendorHash = "sha256-gf2E7DTAGTjoo3nEjcix3qWjHJHudlR7x9XJODvb2sk=";

  nativeBuildInputs = [ pkg-config libusb1 ];
  buildInputs = [ libusb1 ];
}
