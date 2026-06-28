#!/usr/bin/env bash
# Sync release notes from the app's resources into the website data folder.
set -euo pipefail

SRC="$(cd "$(dirname "$0")/.." && pwd)/../Entanglo/Entanglo/Resources/release-notes.json"
DST="$(cd "$(dirname "$0")/.." && pwd)/src/data/release-notes.json"

if [ ! -f "$SRC" ]; then
  echo "release-notes.json not found at $SRC" >&2
  exit 1
fi

cp "$SRC" "$DST"
echo "Synced $(basename "$DST") from app resources."
