# Entanglo website

Apple-style static marketing + download site for Entanglo.
Astro + Tailwind, deployed to Cloudflare Pages (`entanglo.pages.dev`).

## Develop

    npm install
    npm run dev

## Build

    npm run build      # outputs to dist/

## Sync release notes from the app

    npm run sync-notes

This copies `Entanglo/Entanglo/Resources/release-notes.json` into `src/data/`,
which feeds the homepage version pill, the download page, and the changelog.

## Publish a new release

1. Sync release notes:

       npm run sync-notes

2. Publish the DMG (copies it under `public/downloads/` and rewrites
   `public/updates/latest.json` with the right SHA-256 + size):

       ./scripts/publish-release.sh /path/to/Entanglo-0.1.58.dmg

3. Commit & push — Cloudflare Pages rebuilds automatically on push to `main`.

The Mac app reads `https://entanglo.pages.dev/updates/latest.json` and uses
the `sha256` to verify the DMG before installing. The Windows app reads
`https://entanglo.pages.dev/updates/latest-win.json`; the installer itself
lives on GitHub Releases because Cloudflare Pages caps single assets at
25 MiB and the self-contained `.exe` is ~45 MB.

### Auto-update timing

Every running Mac / Windows client polls its manifest on launch and every
60 minutes afterwards. That means once step 3 is done, no manual
notification is needed — within the poll window each peer downloads the
DMG / installer into its per-user Updates cache, verifies the SHA-256 that
`publish-release.sh` wrote, and lights up the **News & Updates** tab with
an Install button. The user clicks once, the helper replaces the app
bundle, and (since 0.1.54) all previously-granted TCC permissions
(Accessibility, Screen Recording, Local Network) carry over across the
upgrade because signing is stable-cert based.

If a peer is offline when a release lands, it picks up the manifest on its
next launch — there's no time bound. The rollout is entirely pull-based
from the CDN; no push, no LAN broadcast required.

## Layout

- `src/pages/` — index, download, privacy, support, changelog, 404
- `src/components/` — Header, Footer, Hero, FeatureCard, DownloadButton, AdSlot, Logo
- `src/layouts/Base.astro` — shell with header/footer + meta + AdSense placeholder
- `public/updates/latest.json` — Mac auto-update manifest
- `public/updates/latest-win.json` — Windows auto-update manifest
- `public/updates/release-notes.json` — full changelog (in sync with the
  copy bundled inside the Mac app under `Entanglo/Resources/`)
- `public/downloads/*.dmg` — Mac release artifacts (gitignored)

## Ads

Slots are in place (`<AdSlot/>`). To enable Google AdSense:

1. Get approved + paste your `ca-pub-XXX` ID.
2. Uncomment the `<script>` in `src/layouts/Base.astro`.
3. Uncomment the `<ins class="adsbygoogle">` block in `src/components/AdSlot.astro`
   and set `data-ad-slot` per placement.
