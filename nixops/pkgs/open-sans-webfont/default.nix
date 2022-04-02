{ pkgs }:
with pkgs;
runCommand "open-sans-webfont" {} ''
  # woff2_compress only outputs to same dir as source font
  export HOME=$(mktemp -d)

  cd $HOME
  cp ${open-sans}/share/fonts/truetype/*.ttf .

  for ttf in *.ttf; do
    ${woff2}/bin/woff2_compress $ttf
  done

  mkdir $out
  mv *.woff2 $out
''
