#!/bin/sh
# Runs inside vmactions/freebsd-vm.
# Builds the os-repo-aendryn bootstrap package plus a signed pkg repo that
# carries over every plugin package already published to gh-pages. This is the
# repository's own bootstrap — plugins live in their own repos and publish
# independently; this workflow never rebuilds them.
# Usage: build-bootstrap.sh <version> [existing-pkgs-dir]
set -e

VERSION="${1:-1.0.1}"
EXISTING_PKGS="${2:-}"
ARCH="FreeBSD:14:amd64"
REPO_PATH="FreeBSD_14_amd64"
DIST="dist"
REPO="$DIST/repo/$REPO_PATH/latest"

mkdir -p "$DIST" "$REPO/All"

stage=$(mktemp -d)
meta=$(mktemp -d)
plist=$(mktemp)

mkdir -p "$stage/usr/local/etc/pkg/repos" "$stage/usr/local/share/aendryn"
install -m 0644 net/repo-bootstrap/src/usr/local/etc/pkg/repos/aendryn.conf \
    "$stage/usr/local/etc/pkg/repos/aendryn.conf"
install -m 0644 net/repo-bootstrap/src/usr/local/share/aendryn/pubkey.rsa \
    "$stage/usr/local/share/aendryn/pubkey.rsa"

find "$stage" -type f | sed "s|$stage/||" | sort > "$plist"
flatsize=$(find "$stage" -type f | xargs stat -f '%z' | awk '{sum+=$1} END{print sum+0}')

cat > "$meta/+MANIFEST" <<EOF
name: "os-repo-aendryn"
version: "${VERSION}"
origin: "net/os-repo-aendryn"
comment: "aendryn OPNsense plugin repository configuration"
desc: "Configures pkg to use the aendryn OPNsense plugin repository so that os-cloudflare-zt and future plugins appear in System -> Firmware -> Plugins."
arch: "${ARCH}"
www: "https://github.com/aendryn/opnsense-repo"
maintainer: "aendryn@github"
prefix: "/"
flatsize: ${flatsize}
EOF

pkg create -m "$meta" -r "$stage" -p "$plist" -o "$DIST/"
rm -rf "$stage" "$meta" "$plist"
echo "==> Built: $DIST/os-repo-aendryn-${VERSION}.pkg"

# Carry over existing packages (all plugins) so packagesite.yaml lists them all
if [ -n "$EXISTING_PKGS" ] && [ -d "$EXISTING_PKGS" ]; then
    cp "$EXISTING_PKGS"/*.pkg "$REPO/All/" 2>/dev/null || true
fi

cp "$DIST"/*.pkg "$REPO/All/"
pkg repo "$REPO" "$(pwd)/.ci-signing.key"

echo "==> Repo contents:"
ls -la "$REPO/All/"
ls -la "$REPO/"
