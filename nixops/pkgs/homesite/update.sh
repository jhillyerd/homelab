#!/usr/bin/env nix-shell
#!nix-shell -i bash -p curl gnused jq yarn2nix

set -eu -o pipefail

PKG="homesite"
OWNER="jhillyerd"
REPO="$PKG"
BRANCH="main"

GITHUBAPI="Accept: application/vnd.github.v3+json"

# Determine latest commit on branch.
branchUrl="https://api.github.com/repos/$OWNER/$REPO/branches/$BRANCH"
latestSha="$(curl -s -L -H "$GITHUBAPI" "$branchUrl" | jq -r '.commit.sha')"

if [ "null" = "${latestSha}" ]; then
  echo "Update failed, commit was null"
  exit 1
fi

# Determine commit checksum.
tgzUrl="https://github.com/$OWNER/$REPO/archive/$latestSha.tar.gz"
mapfile -t < <(nix-prefetch-url --print-path --unpack --type sha256 "$tgzUrl")
latestSum="${MAPFILE[0]}"
storePath="${MAPFILE[1]}"

if [ -z "$latestSum" ]; then
  echo "Update failed, latestSum was empty"
  exit 1
fi

if [ -z "$storePath" ]; then
  echo "Update failed, storePath was empty"
  exit 1
fi

# Update default.nix.
echo "Updating rev to $latestSha"
sed -E -i -e 's/^(\s*rev\s*=\s*")[^"]+(".*)$/\1'$latestSha'\2/' default.nix

echo "Updating sha256 to $latestSum"
sed -E -i -e 's/^(\s*sha256\s*=\s*")[^"]+(".*)$/\1'$latestSum'\2/' default.nix

yarn2nix --lockfile="$storePath/yarn.lock" > yarn.nix
