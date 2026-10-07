#!/bin/bash
set -euo pipefail
cd "$(dirname "$0")/.."
python3 scripts/smoke.py outputs/Lantern.app/Contents/MacOS/lantern-hook
python3 scripts/usage-smoke.py outputs/Lantern.app/Contents/MacOS/lantern-hook
