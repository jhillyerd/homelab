# An overlay of packages we want full control (not just overlays) of.
final: prev:
{
  # Package template: x = final.callPackage ./x { };
  consul = final.callPackage ./consul.nix { };
}
