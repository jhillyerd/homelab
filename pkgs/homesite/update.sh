#!/usr/bin/env nix-shell
#!nix-shell -i bash -p curl gnused jq

set -eu -o pipefail

PKG="homesite"
OWNER="jhillyerd"
REPO="$PKG"
BRANCH="master"

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
latestSum="$(nix-prefetch-url --unpack --type sha256 "$tgzUrl")"

if [ -z "$latestSum" ]; then
  echo "Update failed, sum was empty"
  exit 1
fi

# Update default.nix.
echo "Updating rev to $latestSha"
sed -E -i -e 's/^(\s*rev\s*=\s*")[^"]+(".*)$/\1'$latestSha'\2/' default.nix

echo "Updating sha256 to $latestSum"
sed -E -i -e 's/^(\s*sha256\s*=\s*")[^"]+(".*)$/\1'$latestSum'\2/' default.nix
