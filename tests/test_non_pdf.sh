#!/usr/bin/env bash
set -euo pipefail

IMAGE="${IMAGE:-pdf2john}"
TMPDIR_LOCAL=$(mktemp -d)
trap 'rm -rf "$TMPDIR_LOCAL"' EXIT

echo "not a pdf" > "$TMPDIR_LOCAL/notapdf.txt"

echo "[test_non_pdf] running container against a plain text file..."
output=$(docker run --rm \
  -v "$TMPDIR_LOCAL:/mount/target" \
  "$IMAGE" /app/pdf2john.pl /mount/target/notapdf.txt 2>&1) || true

# The script should produce no valid $pdf$ hash for a non-PDF input
if echo "$output" | grep -qE '\$pdf\$'; then
  echo "FAIL: script produced a \$pdf\$ hash for a non-PDF file"
  echo "  got: $output"
  exit 1
fi

echo "PASS: no \$pdf\$ hash produced for non-PDF input"
