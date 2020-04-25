with import <nixpkgs> {};
writeTextFile {
  name = "home-website";

  destination = "/index.html";

  text = "Hello NixOps World! at 10:22";
}
