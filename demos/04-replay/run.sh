#!/usr/bin/env bash
set -euo pipefail

h1=$(tools/hd replay examples/infinity-cube)
h2=$(tools/hd replay examples/infinity-cube)

if [ "$h1" != "$h2" ]; then
  echo "Replay not deterministic"
  exit 1
fi

echo "Replay digest: $h1"
echo "DEMO 04 PASS"
