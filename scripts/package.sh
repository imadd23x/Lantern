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
cp -R "$binary_dir/Lantern_LanternApp.bundle" "$app/Contents/Resources/"
release_version="$(/usr/libexec/PlistBuddy -c 'Print :CFBundleShortVersionString' Resources/Info.plist)"
if [[ ! "$release_version" =~ ^[0-9]+\.[0-9]+\.[0-9]+$ ]]; then
  printf 'Invalid release version: %s\n' "$release_version" >&2
  exit 1
fi
"$app/Contents/MacOS/Lantern" --render-icon "$stage/Lantern.iconset"
iconutil -c icns -o "$app/Contents/Resources/Lantern.icns" "$stage/Lantern.iconset"
codesign --force --sign - "$app/Contents/MacOS/lantern-hook"
codesign --force --sign - "$app"
codesign --verify --deep --strict "$app"
# The release archive must come from verified unsynced staging, not the volatile workspace copy.
ditto -c -k --keepParent "$app" "outputs/Lantern-$release_version.zip"
shasum -a 256 "outputs/Lantern-$release_version.zip" > outputs/SHA256SUMS
# Copy an already signed bundle; File Provider metadata on Documents can block signing in place.
# ditto merges directories: replace the generated resource bundle, rather than retaining stale assets.
# Earlier release ZIPs are retained for rollback.
if [[ -d outputs/Lantern.app/Contents/Resources/Lantern_LanternApp.bundle ]]; then
  mv outputs/Lantern.app/Contents/Resources/Lantern_LanternApp.bundle "$stage/obsolete-portrait.bundle"
fi
ditto "$app" outputs/Lantern.app
# This synced Documents volume adds FinderInfo to new bundle roots. Remove only
# that generated metadata, preserving provenance and any other extended attributes.
for bundle in outputs/Lantern.app; do
  if xattr -p com.apple.FinderInfo "$bundle" >/dev/null 2>&1; then
    xattr -d com.apple.FinderInfo "$bundle"
  fi
done
if ! workspace_verification="$(codesign --verify --deep --strict outputs/Lantern.app 2>&1)"; then
  if [[ "$workspace_verification" == *'resource fork, Finder information, or similar detritus not allowed'* ]]; then
    printf 'File Provider reapplied metadata to the workspace app. Extract the verified release ZIP to an unsynced folder.\n' >&2
  else
    printf '%s\n' "$workspace_verification" >&2
    exit 1
  fi
fi
printf 'Built %s/outputs/Lantern-%s.zip\n' "$PWD" "$release_version"
