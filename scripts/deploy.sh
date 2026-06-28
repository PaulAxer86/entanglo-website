#!/usr/bin/env bash
#
# deploy.sh — one-shot release pipeline for the Entanglo website.
#
# What it does:
#   1. Reads the current app version from Entanglo/project.yml.
#   2. Syncs release notes from the app's resources into src/data/.
#   3. Locates (or rebuilds) the DMG for that version.
#   4. Copies the DMG into public/downloads/ and writes public/updates/latest.json
#      with the correct SHA-256 + size.
#   5. Verifies the Astro build succeeds.
#   6. git add + commit + push  → Netlify rebuilds automatically.
#
# Usage:
#   ./scripts/deploy.sh                # use existing DMG, fail if missing
#   ./scripts/deploy.sh --build        # rebuild the DMG first
#   ./scripts/deploy.sh --dmg PATH     # use a specific DMG file
#   ./scripts/deploy.sh --dry-run      # do everything except git push
#
# First-time setup (run once, not via this script):
#   cd /Users/axerone/entanglo/website
#   git init && git add . && git commit -m "Initial website"
#   gh repo create entanglo-website --private --source=. --push
#   # then: https://app.netlify.com/start → import the repo → rename site to "entanglo"
#

set -euo pipefail

# --- paths ----------------------------------------------------------------
WEB_ROOT="$(cd "$(dirname "$0")/.." && pwd)"
APP_ROOT="$(cd "$WEB_ROOT/../Entanglo" && pwd)"
APP_DIST="$APP_ROOT/dist"
PROJECT_YML="$APP_ROOT/project.yml"
MAKE_DMG="$APP_ROOT/scripts/make-dmg.sh"

# --- args -----------------------------------------------------------------
DO_BUILD=0
DRY_RUN=0
DMG_OVERRIDE=""
while [ $# -gt 0 ]; do
  case "$1" in
    --build)    DO_BUILD=1; shift ;;
    --dry-run)  DRY_RUN=1; shift ;;
    --dmg)      DMG_OVERRIDE="$2"; shift 2 ;;
    -h|--help)  sed -n '1,30p' "$0"; exit 0 ;;
    *)          echo "Unknown arg: $1" >&2; exit 1 ;;
  esac
done

cd "$WEB_ROOT"

# --- helpers --------------------------------------------------------------
say()  { printf "\033[1;36m==>\033[0m %s\n" "$*"; }
warn() { printf "\033[1;33m!!\033[0m %s\n" "$*" >&2; }
fail() { printf "\033[1;31mxx\033[0m %s\n" "$*" >&2; exit 1; }

# --- 1. version -----------------------------------------------------------
[ -f "$PROJECT_YML" ] || fail "project.yml not found at $PROJECT_YML"
VERSION="$(grep -E 'CFBundleShortVersionString:' "$PROJECT_YML" | head -1 | sed -E 's/.*"([^"]+)".*/\1/')"
[ -n "$VERSION" ] || fail "Could not parse version from $PROJECT_YML"
say "App version: $VERSION"

# --- 2. sync release notes -----------------------------------------------
say "Syncing release notes from app..."
bash "$WEB_ROOT/scripts/sync-release-notes.sh"

# --- 3. locate or build the DMG ------------------------------------------
DMG=""
if [ -n "$DMG_OVERRIDE" ]; then
  [ -f "$DMG_OVERRIDE" ] || fail "DMG not found at: $DMG_OVERRIDE"
  DMG="$DMG_OVERRIDE"
else
  DMG="$APP_DIST/Entanglo-$VERSION.dmg"
fi

if [ "$DO_BUILD" -eq 1 ] || [ ! -f "$DMG" ]; then
  if [ ! -f "$DMG" ] && [ "$DO_BUILD" -eq 0 ]; then
    warn "DMG missing: $DMG"
    warn "Re-run with --build to compile it, or pass --dmg PATH"
    exit 1
  fi
  say "Building DMG for $VERSION ..."
  ENTANGLO_VERSION="$VERSION" bash "$MAKE_DMG"
  DMG="$APP_DIST/Entanglo-$VERSION.dmg"
  [ -f "$DMG" ] || fail "Build finished but DMG not found at $DMG"
fi
say "Using DMG: $DMG"

# --- 4. publish DMG + write latest.json ----------------------------------
say "Publishing DMG and updating latest.json..."
bash "$WEB_ROOT/scripts/publish-release.sh" "$DMG"

# --- 5. verify build ------------------------------------------------------
say "Running Astro build to verify..."
if ! npm run build >/tmp/entanglo-website-build.log 2>&1; then
  tail -50 /tmp/entanglo-website-build.log
  fail "Astro build failed. See /tmp/entanglo-website-build.log"
fi
say "Build OK ($(grep -c '└─' /tmp/entanglo-website-build.log) pages)"

# --- 6. git commit + push ------------------------------------------------
if [ ! -d "$WEB_ROOT/.git" ]; then
  warn "No git repo here yet. First-time setup required:"
  cat <<EOF

  cd $WEB_ROOT
  git init
  git add .
  git commit -m "Initial website"
  gh repo create entanglo-website --private --source=. --push

  Then go to https://app.netlify.com/start and import the repo.

EOF
  exit 0
fi

if [ -z "$(git status --porcelain)" ]; then
  say "Nothing to commit — repo is clean."
  exit 0
fi

git add -A
git status --short

if [ "$DRY_RUN" -eq 1 ]; then
  warn "Dry run — skipping commit/push."
  exit 0
fi

COMMIT_MSG="Release $VERSION

$(jq -r '.[0].title' "$WEB_ROOT/src/data/release-notes.json" 2>/dev/null || echo "")
"
git commit -m "$COMMIT_MSG"

if git remote get-url origin >/dev/null 2>&1; then
  say "Pushing to origin..."
  git push
  say "Done. Netlify is rebuilding now."
else
  warn "No 'origin' remote configured. Commit made locally only."
  warn "Add a remote with: gh repo create entanglo-website --private --source=. --push"
fi
