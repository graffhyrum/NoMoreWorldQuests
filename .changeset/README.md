# Changesets

Pending changelog entries for [Changesets](https://github.com/changesets/changesets).

`package.json` is the version source Changesets bumps; `@changesets/cli` is a devDependency — run via `bun run changeset`.

Retail TOC bumps do **not** use this folder. Use `just retail-bump` (`.agents/skills/retail-release/SKILL.md`).

## Adding a changeset

After a user-facing **code** change:

```bash
bun run changeset
```

Pick the semver bump and write a short summary. Commit the generated `.changeset/*.md` file with your PR.

PRs to `master` run the **Changesets** workflow (`changeset status --since=origin/master`).

## Releasing

On merge to `master`, **Version Packages** opens a version PR when changesets exist, or tags `v{package.json version}` if that tag is missing.

**Release** publishes to CurseForge + GitHub on `v*` tag push, and when Version Packages completes (`GITHUB_TOKEN` tags do not fire `push: tags`). The job no-ops if HEAD is not an exact tag or the GitHub release already exists.

`just version` is the Changesets version step only. It is not the retail Interface bump.
