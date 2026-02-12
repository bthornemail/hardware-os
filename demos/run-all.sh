#!/usr/bin/env bash
set -euo pipefail

for d in demos/*/run.sh; do
  echo "Running $d"
  bash "$d"
done

echo "ALL DEMOS PASS"
