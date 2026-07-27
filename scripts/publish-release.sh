#!/usr/bin/env bash
# Publish a new Entanglo release:
#   1. Copy the DMG into public/downloads/
#   2. Compute SHA-256 + size
#   3. Update public/updates/latest.json with version/url/sha256/size + highlights
#
# Usage:
#   ./scripts/publish-release.sh path/to/Entanglo-0.1.37.dmg
#
# The version is read from the DMG filename (Entanglo-X.Y.Z.dmg).
# Highlights are pulled from src/data/release-notes.json (top entry).

set -euo pipefail

if [ "$#" -ne 1 ]; then
  echo "Usage: $0 path/to/Entanglo-X.Y.Z.dmg" >&2
  exit 1
fi

DMG="$1"
[ -f "$DMG" ] || { echo "DMG not found: $DMG" >&2; exit 1; }

ROOT="$(cd "$(dirname "$0")/.." && pwd)"
DOWNLOADS="$ROOT/public/downloads"
UPDATES="$ROOT/public/updates/latest.json"
NOTES="$ROOT/src/data/release-notes.json"

mkdir -p "$DOWNLOADS"

BASENAME="$(basename "$DMG")"
VERSION="$(echo "$BASENAME" | sed -nE 's/Entanglo-([0-9]+\.[0-9]+\.[0-9]+)\.dmg/\1/p')"
[ -n "$VERSION" ] || { echo "Could not parse version from $BASENAME" >&2; exit 1; }

cp "$DMG" "$DOWNLOADS/$BASENAME"

SHA="$(shasum -a 256 "$DOWNLOADS/$BASENAME" | awk '{print $1}')"
SIZE="$(stat -f%z "$DOWNLOADS/$BASENAME")"
URL="https://entanglo.pages.dev/downloads/$BASENAME"

# Build latest.json from the top release-notes entry, overriding url/sha256/size.
python3 - "$VERSION" "$URL" "$SHA" "$SIZE" "$NOTES" "$UPDATES" <<'PY'
import json, sys
version, url, sha, size, notes_path, updates_path = sys.argv[1:]
notes = json.load(open(notes_path))
top = notes[0] if notes else {}
out = {
    "version": version,
    "date": top.get("date", ""),
    "title": top.get("title", ""),
    "minimumSystemVersion": "13.0",
    "url": url,
    "sha256": sha,
    "size": int(size),
    "notesUrl": f"https://entanglo.pages.dev/changelog#{version.replace('.', '-')}",
    "highlights": top.get("highlights", [])[:3],
}
json.dump(out, open(updates_path, "w"), indent=2)
PY

echo "Published $BASENAME"
echo "  version: $VERSION"
echo "  sha256:  $SHA"
echo "  size:    $SIZE bytes"
echo "  url:     $URL"
echo "Updated $UPDATES"
