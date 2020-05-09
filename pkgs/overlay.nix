super: self: {
  homesite = super.callPackage ./homesite {};
  open-sans-webfont = super.callPackage ./open-sans-webfont {};
  website = super.callPackage ./website {};
}
