#!/bin/bash
set -euo pipefail
cd "$(dirname "$0")/.."
stage="$(mktemp -d /private/tmp/lantern-package.XXXXXX)"
trap 'rm -rf "$stage"' EXIT
binary_dirs=()
for arch in arm64 x86_64; do
  triple="$arch-apple-macosx15.0"
  task_build="$stage/build-$arch"
  flags=(-c release --triple "$triple" -Xswiftc -file-prefix-map -Xswiftc "$PWD=/Lantern"
         -Xswiftc -debug-prefix-map -Xswiftc "$PWD=/Lantern" -Xcc "-ffile-prefix-map=$PWD=/Lantern")
  LANTERN_BUILD_DIR="$task_build" bash scripts/swift.sh build "${flags[@]}"
  binary_dirs+=("$(LANTERN_BUILD_DIR="$task_build" bash scripts/swift.sh build "${flags[@]}" --show-bin-path)")
done
app="$stage/Lantern.app"
mkdir -p "$app/Contents/MacOS" "$app/Contents/Resources" outputs
for executable in Lantern lantern-hook; do
  lipo -create "${binary_dirs[0]}/$executable" "${binary_dirs[1]}/$executable" -output "$app/Contents/MacOS/$executable"
  for arch in arm64 x86_64; do
    lipo "$app/Contents/MacOS/$executable" -verify_arch "$arch"
  done
done
cp Resources/Info.plist "$app/Contents/Info.plist"
cp Resources/ThirdPartyNotices.txt "$app/Contents/Resources/ThirdPartyNotices.txt"
cp -R "${binary_dirs[0]}/Lantern_LanternApp.bundle" "$app/Contents/Resources/"
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
# Reject embedded personal home/source paths; remapping must be effective in both slices.
python3 scripts/audit-release.py "$app"
# The release archive must come from verified unsynced staging, not the volatile workspace copy.
archive="Lantern-$release_version.zip"
mkdir -p "$stage/release" outputs/releases
ditto -c -k --keepParent "$app" "$stage/release/$archive"
unzip -tq "$stage/release/$archive"
ditto -x -k "$stage/release/$archive" "$stage/extracted"
codesign --verify --deep --strict "$stage/extracted/Lantern.app"
python3 scripts/audit-release.py "$stage/extracted/Lantern.app"
cp docs/INSTALL.md "$stage/release/INSTALL.md"
(cd "$stage/release" && shasum -a 256 "$archive" > SHA256SUMS)
# Publish the archive/checksum as one same-volume directory rename. Never truncate
# an earlier checked archive when a release version is accidentally reused.
release="outputs/releases/$release_version"
if [[ -e "$release" ]]; then
  cmp "$stage/release/SHA256SUMS" "$release/SHA256SUMS" || { printf 'Release already exists; use a new version.\n' >&2; exit 1; }
else
  output_stage="$(mktemp -d outputs/releases/.staging.XXXXXX)"
  cp "$stage/release/"* "$output_stage/"
  (cd "$output_stage" && shasum -a 256 -c SHA256SUMS)
  mv "$output_stage" "$release"
fi
# Flat paths are convenience links; the immutable release directory is authoritative.
ln -f "$release/$archive" "outputs/$archive"
cp "$release/SHA256SUMS" outputs/.SHA256SUMS.new
mv outputs/.SHA256SUMS.new outputs/SHA256SUMS
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
