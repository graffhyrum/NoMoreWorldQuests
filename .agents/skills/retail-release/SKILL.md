---
name: retail-release
description: >-
  Bumps this retail WoW addon for the live client and publishes to CurseForge.
  Use when the user asks for a maintenance update, TOC Interface bump, latest
  retail patch, CurseForge publish, or tagging a release. Do NOT use for Classic,
  feature work, or inventing Interface numbers by hand.
---

# Retail release

Read live client + TOC from scripts. Do not scrape wiki for the Interface number when `Wow.exe` is present.

## Commands

```bash
just retail-status          # JSON: TOC vs Wow.exe
just retail-bump-dry        # preview file writes
just retail-bump            # write TOC/README/CHANGELOG/package.json; no commit
just test-scripts
just pre-release
just publish-tag            # only if origin lacks v{package.json version}
```

Override client: `bun scripts/retail-bump.ts --interface 120100`

## Workflow

1. `just retail-status`. Stop if `outdated` is false unless the user still wants a publish of the current version.
2. If outdated: review WQ/map/tracker/talking-head hooks (wow-ui-source skill). Code change only if a hooked API broke.
3. `just retail-bump`. Confirm JSON `changed` and file list.
4. `just pre-release`.
5. Commit and push **only if the user asked**. Message style: `chore(release): bump to X.Y.Z for WoW A.B.C`.
6. Version Packages tags `vX.Y.Z`. Release uploads to CurseForge even if that tag came from `GITHUB_TOKEN`.
7. Watch packager: `gh run list --workflow=release.yml --limit 1` then `gh run watch <id>`.

## Rules

- Scripts never commit. `publish-tag` only pushes the version tag.
- Do not run interactive `bun run changeset` for a TOC-only retail bump.
- Do not set git `user.name` / `user.email`.
- Mechanic `addon.validate` may still say Interface is outdated. That is Mechanic lag.
