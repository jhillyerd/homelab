# An overlay of packages we want full control (not just overlays) of.
final: prev:
let
  inherit (final) callPackage;
in
{
  # Package template: x = callPackage ./x { }
  cfdyndns = callPackage ./cfdyndns.nix { };
  nomad-usb-device-plugin = callPackage ./nomad-usb-device-plugin.nix { };
  sesh = callPackage ./sesh.nix { };

  # forgejo-cli 0.6.0 prints a keys-file status line to stdout when running
  # `fj completion`, so it lands as line 1 of every generated completion
  # file and fish errors when sourcing it. Fixed upstream after 0.6.0
  # (forgejo-contrib/forgejo-cli#626, #630); drop this once we're past that.
  forgejo-cli = prev.forgejo-cli.overrideAttrs (old: {
    postInstall = (old.postInstall or "") + ''
      for f in \
        $out/share/fish/vendor_completions.d/fj.fish \
        $out/share/bash-completion/completions/fj.bash \
        $out/share/zsh/site-functions/_fj
      do
        sed -i '1{/^Could not find keys file/d}' "$f"
      done
    '';
  });
}
