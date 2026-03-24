#!/bin/sh
# Regenerate Wayland client protocol headers from the XML definitions
# bundled in glfw/deps/wayland/.
#
# These generated headers are committed to the repository so that
# building with -f Wayland does not require wayland-scanner at build
# time. Re-run this script after updating the bundled GLFW sources if
# the Wayland protocol XML files change.
#
# Requires: wayland-scanner (from the wayland package)

set -e

SCRIPT_DIR=$(cd "$(dirname "$0")" && pwd)
WL_DIR="$SCRIPT_DIR/glfw/deps/wayland"
OUT_DIR="$SCRIPT_DIR/glfw/src"

if ! command -v wayland-scanner >/dev/null 2>&1; then
    echo "Error: wayland-scanner not found. Install the wayland package." >&2
    exit 1
fi

for xml in "$WL_DIR"/*.xml; do
    base=$(basename "$xml" .xml)
    echo "Generating $base..."
    wayland-scanner client-header "$xml" "$OUT_DIR/${base}-client-protocol.h"
    wayland-scanner private-code  "$xml" "$OUT_DIR/${base}-client-protocol-code.h"
done

echo "Done. Generated protocol headers in $OUT_DIR"
