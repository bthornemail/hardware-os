#!/usr/bin/env bash
set -euo pipefail

tmp=/tmp/hd-demo-init
rm -rf "$tmp"

tools/hd init "$tmp"
tools/hd validate "$tmp"

echo "DEMO 01 PASS"
