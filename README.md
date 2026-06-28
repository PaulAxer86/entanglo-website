# Entanglo website

Apple-style static marketing + download site for Entanglo.
Astro + Tailwind, deployed to Netlify.

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

       ./scripts/publish-release.sh /path/to/Entanglo-0.1.37.dmg

3. Commit & push — Netlify rebuilds automatically.

The app reads `https://entanglo.netlify.app/updates/latest.json` and uses
the `sha256` to verify the DMG before installing.

## Layout

- `src/pages/` — index, download, privacy, support, changelog, 404
- `src/components/` — Header, Footer, Hero, FeatureCard, DownloadButton, AdSlot, Logo
- `src/layouts/Base.astro` — shell with header/footer + meta + AdSense placeholder
- `public/updates/latest.json` — auto-update manifest
- `public/downloads/*.dmg` — release artifacts (gitignored)
- `netlify.toml` — Netlify build config + headers

## Ads

Slots are in place (`<AdSlot/>`). To enable Google AdSense:

1. Get approved + paste your `ca-pub-XXX` ID.
2. Uncomment the `<script>` in `src/layouts/Base.astro`.
3. Uncomment the `<ins class="adsbygoogle">` block in `src/components/AdSlot.astro`
   and set `data-ad-slot` per placement.
