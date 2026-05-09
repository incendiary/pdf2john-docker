#!/usr/bin/env bash
set -euo pipefail

IMAGE="${IMAGE:-pdf2john}"
FIXTURE="$(cd "$(dirname "$0")/fixtures" && pwd)/protected.pdf"
# Hash extracted from fixtures/protected.pdf — update if fixture is regenerated
EXPECTED_HASH='$pdf$5*6*256*-4*1*16*bbb9a75a67ec3a1b24354a4039737e4b*48*c84240acdcbfd026a8493102d9be7a8a649a53848ce30eeccacb606c76a9a166b5dede4a5a8e4d5542073a1911bc4088*48*6d6c423141662b49480ab2a96e92a31b39e9f04658c495da8423536bc210574b63cbcadcc8656ce8a4205323ab04b849*32*cd4355434230161c125470aab6d9d2f0296f23c5cc7a3b62be8da51c53817974*32*7a2a021ba667278bf50e40635a07c8a20b863fa0d78f277979a725c9d541a08d'

echo "[test_extraction] running container against fixture PDF..."
actual=$(docker run --rm -v "$(dirname "$FIXTURE"):/mount/target" "$IMAGE" \
  /app/pdf2john.pl /mount/target/protected.pdf)

# Assert output is non-empty
if [[ -z "$actual" ]]; then
  echo "FAIL: no output produced"
  exit 1
fi

# Assert output contains a $pdf$ hash
if ! echo "$actual" | grep -qE '\$pdf\$'; then
  echo "FAIL: output does not contain a \$pdf\$ hash"
  echo "  got: $actual"
  exit 1
fi

# Assert exact hash match
actual_hash="${actual#*:}"
if [[ "$actual_hash" != "$EXPECTED_HASH" ]]; then
  echo "FAIL: hash mismatch"
  echo "  expected: $EXPECTED_HASH"
  echo "  got:      $actual_hash"
  exit 1
fi

echo "PASS: hash extracted and matches expected value"
