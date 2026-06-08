# Changesets

Pending changelog entries for [Changesets](https://github.com/changesets/changesets).

Requires a global install:

```bash
bun install -g @changesets/cli
```

`package.json` here is only the version source Changesets bumps — not a Bun project dependency tree.

## Adding a changeset

After a user-facing change:

```bash
changeset
```

Pick the semver bump and write a short summary. Commit the generated `.changeset/*.md` file.

## Releasing

When changesets are ready to ship:

```bash
bun scripts/version.ts
```

This runs `changeset version`, updates `CHANGELOG.md` and `package.json`, syncs `NoMoreWorldQuests.toc`, and removes consumed changeset files.
