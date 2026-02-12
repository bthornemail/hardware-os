#!/usr/bin/env bash
set -euo pipefail

tmp=/tmp/hd-demo-tamper
rm -rf "$tmp"
cp -r examples/infinity-cube "$tmp"

# corrupt history
sed -i '1s/create/hack/' "$tmp/build/history.ndjson"

if tools/hd validate "$tmp"; then
  echo "ERROR: tamper not detected"
  exit 1
fi

echo "DEMO 03 PASS (tamper detected)"
