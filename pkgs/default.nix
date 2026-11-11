# Packages owned by this repo, as a set built against an imported pkgs.
{ pkgs }:

{
  cfdyndns = pkgs.callPackage ./cfdyndns.nix { };
  octodns-cloudflare = pkgs.python3Packages.callPackage ./octodns-cloudflare.nix { };
}
