---
status: accepted
---

# Pluggable suppression controller with rules and surfaces

Retail v1 must hide only world quests but later quest types (bonus objectives, rares) and UI channels may grow. We split responsibilities into a **suppression controller** (on/off state, SavedVariables, minimap/slash/settings toggles), **visibility rules** (`ShouldSuppress` per quest/artifact; v1 registers `WorldQuestRule` only), and **suppression surfaces** (one implementation per **WQ presentation** channel: minimap, world map, intrusion prompts, objective tracker). A bootstrap table registers rules and surfaces at load; no dynamic plugin loading in v1.

Rejected for v1: a monolithic script that branches on quest type inside each hook (fast to write, every new type touches every hook). **Map filter sync** stays separate from surfaces so Blizzard checkbox idempotent toggling does not complicate presentation hooks. New rules and surfaces register without editing existing ones (Open/Closed: open for extension, closed for modification).

**Minimap control** uses LibStub, LibDataBroker-1.1, and LibDBIcon-1.0 vendored under `libs/` (not a separate user-installed addon).
