#!/bin/bash
set -euo pipefail
cd "$(dirname "$0")/.."
bash scripts/swift.sh build -c release
binary_dir="$(bash scripts/swift.sh build -c release --show-bin-path)"
stage="$(mktemp -d /private/tmp/lantern-package.XXXXXX)"
trap 'rm -rf "$stage"' EXIT
app="$stage/Lantern.app"
mkdir -p "$app/Contents/MacOS" "$app/Contents/Resources" outputs
cp "$binary_dir/Lantern" "$app/Contents/MacOS/Lantern"
cp "$binary_dir/lantern-hook" "$app/Contents/MacOS/lantern-hook"
cp Resources/Info.plist "$app/Contents/Info.plist"
cp Resources/ThirdPartyNotices.txt "$app/Contents/Resources/ThirdPartyNotices.txt"
release_version="$(/usr/libexec/PlistBuddy -c 'Print :CFBundleShortVersionString' Resources/Info.plist)"
if [[ ! "$release_version" =~ ^[0-9]+\.[0-9]+\.[0-9]+$ ]]; then
  printf 'Invalid release version: %s\n' "$release_version" >&2
  exit 1
fi
"$binary_dir/Lantern" --render-icon "$stage/Lantern.iconset"
iconutil -c icns -o "$app/Contents/Resources/Lantern.icns" "$stage/Lantern.iconset"
codesign --force --sign - "$app/Contents/MacOS/lantern-hook"
codesign --force --sign - "$app"
codesign --verify --deep --strict "$app"
# Copy an already signed bundle; File Provider metadata on Documents can block signing in place.
ditto "$app" outputs/Lantern.app
# This synced Documents volume adds FinderInfo to new bundle roots. Remove only
# that generated metadata, preserving provenance and any other extended attributes.
if xattr -p com.apple.FinderInfo outputs/Lantern.app >/dev/null 2>&1; then
  xattr -d com.apple.FinderInfo outputs/Lantern.app
fi
codesign --verify --deep --strict outputs/Lantern.app
ditto -c -k --keepParent "$app" "outputs/Lantern-$release_version.zip"
shasum -a 256 "outputs/Lantern-$release_version.zip" > outputs/SHA256SUMS
printf 'Built %s/outputs/Lantern.app\n' "$PWD"
