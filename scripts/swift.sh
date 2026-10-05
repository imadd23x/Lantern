#!/bin/bash
set -euo pipefail
cd "$(dirname "$0")/.."
task_root="$PWD"
# Keep signing/build products off File Provider volumes, which attach FinderInfo during signing.
project_hash="$(printf '%s' "$task_root" | shasum -a 256 | cut -c1-16)"
build_root="${LANTERN_BUILD_DIR:-${TMPDIR:-/private/tmp}/lantern-build-$project_hash}"
mkdir -p "$build_root/clang-cache" "$build_root/swift-cache" "$build_root/configuration" "$build_root/security"
export CLANG_MODULE_CACHE_PATH="$build_root/clang-cache"
export SWIFTPM_MODULECACHE_OVERRIDE="$build_root/clang-cache"
swift_compiler="$(xcrun --find swiftc)"
plugin_dir="$(dirname "$swift_compiler")/../lib/swift/host/plugins/testing"
args=(--scratch-path "$build_root/products" --cache-path "$build_root/swift-cache" --config-path "$build_root/configuration" --security-path "$build_root/security" --disable-sandbox)
# CLT Swift 6.4 ships Testing macros in a nested plugin directory which SwiftBuild does not discover.
if [ -f "$plugin_dir/libTestingMacros.dylib" ]; then
  args+=(-Xswiftc -plugin-path -Xswiftc "$plugin_dir")
fi
command="${1:-build}"
shift || true
exec swift "$command" "${args[@]}" "$@"
