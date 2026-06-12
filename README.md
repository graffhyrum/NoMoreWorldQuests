# No More World Quests

<p align="center">
  <img src="assets/logo/logo-128.png" alt="No More World Quests" width="128" height="128">
</p>

**Retail-only** World of Warcraft addon that hides world quest UI while you play. Quests still complete normally — only presentation is suppressed.

Suppression is **off by default**. Turn it on when you want a quieter world.

## What it does

When suppression is **on**, the addon hides **during-quest world quest presentation**:

| Surface | Hidden content |
|---------|----------------|
| Minimap | World quest pins |
| World map | World quest pins (plus Blizzard WQ map filter sync when the API allows) |
| Intrusion | Zone vignettes and talking-head frames (visual + audio) |
| Objective tracker | World quest objective lines |

**Always shown** (never suppressed):

- Manual turn-in dialogs and reward selection
- Quest-complete banners and reward toasts
- Any other completion UI

While suppression is on and you enter an **active world quest zone**, the minimap control **pulses** so you know a WQ is nearby — without restoring pins, tracker lines, or talking heads.

## Controls

| Action | Result |
|--------|--------|
| Minimap button — **left-click** | Toggle suppression on/off |
| Minimap button — **right-click** | Open settings |
| `/nmwq` | Toggle suppression |
| `/nmwq status` | Print current on/off state |

Settings are per **character** and persist across sessions. v1 is all-or-nothing: no per-surface toggles yet.

## Installation

1. Download or clone this repository.
2. Copy the `NoMoreWorldQuests` folder into your WoW addons directory:
   ```
   World of Warcraft\_retail_\Interface\AddOns\NoMoreWorldQuests\
   ```
3. Enable **No More World Quests** on the character select or in-game AddOns list.

Required libraries (LibStub, LibDataBroker, LibDBIcon) are **bundled** under `libs/` — no separate installs.

## Requirements

- **WoW Retail** (Classic / Era not supported in v1)
- Interface version: **120005** (see `NoMoreWorldQuests.toc`)

## What it does *not* do

- Block quest credit, progress, or completion
- Hide bonus objectives, rares, or regular quests (world quests only in v1)
- Integrate with other addons (e.g. World Quest Tracker)
- Restore a saved snapshot of your Blizzard map filter — turning suppression off re-enables the WQ filter checkbox

## Project layout

```
core/          Controller, visibility rules, debounce
surfaces/      Minimap, world map, objective tracker, intrusion hooks
sync/          Blizzard WQ map filter sync on toggle
active/        Active WQ zone detection and minimap alert
ui/            Settings, minimap button, slash commands
libs/          Vendored LibDBIcon stack
assets/logo/   Addon icon assets
docs/          Design notes and ADRs
CONTEXT.md     Domain glossary and product language
```

Architecture follows a pluggable **suppression controller + visibility rules + surfaces** model. See [docs/adr/0001-pluggable-suppression-architecture.md](docs/adr/0001-pluggable-suppression-architecture.md).

## Development

Domain terms and behavior contracts live in [CONTEXT.md](CONTEXT.md). Agent and issue-tracker notes are under [docs/agents/](docs/agents/).

Blizzard UI reference (optional, local): `%USERPROFILE%\.agents\repos\wow-ui-source\` — see `wow-ui-source` skill in `~/.agents/skills/`. Not shipped with the addon.

### Dev dependencies

| Tool | Role |
|------|------|
| [just](https://github.com/casey/just) | Project command runner (`just --list`) |
| [Mechanic](https://github.com/Falkicon/Mechanic) | Offline tests, lint, format, in-game dashboard |
| [Bun](https://bun.sh) | Runs version/publish scripts |
| [Changesets](https://github.com/changesets/changesets) | Changelog + semver (`bun add -d @changesets/cli`) |

Quick start:

```bash
just bootstrap   # first-time Mechanic setup (see docs/mechanic-setup.md)
just test        # sandbox + Busted
just check       # validate TOC + lint
```

Mechanic install and `~/.mechanic/config.json` paths: [docs/mechanic-setup.md](docs/mechanic-setup.md).

### Changelog and releases

Uses [Changesets](https://github.com/changesets/changesets) + GitHub Actions:

1. After a user-facing change: `bun run changeset`, pick semver bump, commit the `.changeset/*.md` file.
2. Open PR → **Changesets** workflow verifies a changeset exists when needed.
3. Merge → **Version Packages** opens a PR bumping `CHANGELOG.md`, `package.json`, and `NoMoreWorldQuests.toc`.
4. Merge that PR → CI pushes tag `v*` → **Release** workflow publishes to CurseForge and GitHub Releases.

Local only: `just version` (same as CI version step). Before tagging: `just pre-release`. Release: `just release vX.Y.Z` or `just publish-tag` after version bump. See [.changeset/README.md](.changeset/README.md).

## License

Original addon code is [MIT](LICENSE).

Bundled **LibDBIcon-1.0** in `libs/` is **GPL-2.0-or-later** and is not covered by MIT — see [libs/THIRD_PARTY_NOTICES.md](libs/THIRD_PARTY_NOTICES.md).
