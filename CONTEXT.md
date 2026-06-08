# No More World Quests

WoW **retail** addon that suppresses UI presentation of selected quest content while leaving quests completable. v1 does not target Classic or other clients.

## Language

**World quest (WQ)**:
A quest the game client classifies as a world quest (e.g. via `C_QuestLog.IsWorldQuest`). WQs do not require player acceptance; entering the quest area typically triggers intrusive UI (tracker entries, vignettes, pins).
_Avoid_: Accepted quest, picked-up WQ, map clutter

**Suppression**:
The player-chosen state where all **WQ presentation** for matching quests is hidden. The only WQ-related UI that may appear while suppression is on is **Completion UI** (manual turn-in and equivalent end-of-quest prompts).
_Avoid_: Hidden mode, off switch, filter on

**WQ presentation**:
Any client UI tied to a world quest: map/minimap pins, zone vignettes, talking-head frames and audio, objective tracker lines, intrusive on-enter banners, and similar—not including **Completion UI** or addon chrome (**Minimap control**, **Active WQ alert**).
_Avoid_: WQ element, quest UI

**Suppression default**:
Off on first install; the addon is inert until the player enables suppression.
_Avoid_: Opt-out, hidden by default

**Character setting**:
Per-character persisted preference for whether suppression is active (`suppressionEnabled`).
_Avoid_: Account-wide, profile, per-zone toggle

**Minimap control**:
A LibDBIcon (or equivalent) broker button on the minimap. Left-click toggles suppression. Right-click opens or closes the addon settings window.
_Avoid_: Minimap button, LDB button

**Slash commands (v1)**:
`/nmwq` toggles suppression; `/nmwq status` prints on/off. Settings are not opened via slash (minimap right-click only).
_Avoid_: /nowq, chat command

**Settings window**:
The addon configuration UI opened from the minimap control (right-click). v1 contains only master suppression and an about section; per-surface and alert options defer to v2.
_Avoid_: Options panel, config frame

**Active WQ zone**:
The player is in a state where at least one world quest is active for them locally—the same condition that would add **During-quest WQ presentation** if suppression were off (zone/task active state), not merely “a WQ pin exists on the map elsewhere.”
_Avoid_: Accepted WQ, in-progress (regular-quest sense), pin visible from afar

**Active WQ alert**:
A pulsing flash on the minimap control while suppression is on and the player is in an **Active WQ zone**. Always enabled in v1; not configurable until v2.
_Avoid_: Flash, warning, WQ ping

**Suppression surface**:
An implementation hook for one kind of **WQ presentation**. v1 covers minimap, world map, intrusion prompts (vignettes + talking heads), and objective tracker. New surfaces plug in without changing the invisibility rule.
_Avoid_: Hook point, frame


**Blizzard WQ map filter**:
The game’s built-in world-map “World Quests” visibility checkbox.
_Avoid_: Map filter, native filter

**Map filter sync**:
On suppression toggle only: turn the **Blizzard WQ map filter** off when suppression turns on, on when suppression turns off—no-op if already in that state. No saved snapshot; no re-apply while the map is open. If the API cannot read or write the filter, skip silently; addon hooks still enforce **World map suppression**.
_Avoid_: Filter state snapshot, CVar restore

**World map suppression**:
Hiding **WQ presentation** on the world map via addon hooks plus **Map filter sync** when the API allows.
_Avoid_: Map filter only, Blizzard-only

**Completion UI**:
Post-completion player prompts for a world quest: manual turn-in dialogs, reward selection, quest-complete banners, and reward toasts—whether the WQ auto-completed or not. Never suppressed while suppression is on.
_Avoid_: Turn-in only, hand-in

**During-quest WQ presentation**:
**WQ presentation** that appears before the quest is fully complete (pins, tracker, vignettes, talking heads while in **Active WQ zone**).
_Avoid_: In-progress UI

**Visibility rule**:
A pluggable decision that answers whether a given quest (or UI artifact) is subject to suppression. v1 ships one rule: world quests only. Additional rules (bonus objectives, rares, etc.) may be added without changing suppression surfaces.
_Avoid_: Filter function, hook

**Retail scope**:
Supported client is WoW retail only for v1; APIs and WQ behavior assume current retail.
_Avoid_: Classic, Era, expansion-agnostic

**Addon compatibility**:
No integration with other addons (e.g. World Quest Tracker) in v1. **Suppression** applies through this addon’s hooks only; conflicting addons are out of scope.
_Avoid_: WQT compat, plugin bridge

## Relationships

- When **Suppression** is active, each **Suppression surface** hides **WQ presentation** for quests matching **Visibility rules**.
- A **World quest** is hidden only when a WQ-only **Visibility rule** is registered and **Suppression** is active.
- **Suppression** does not block objective credit or quest completion; it only hides presentation on **Suppression surfaces** (except **Completion UI**).
- **Completion UI** is never suppressed; **During-quest WQ presentation** always is (when suppression is on).
- Each **Character setting** remembers one suppression on/off state across sessions.
- No per-zone or per-expansion suppression profiles in v1.
- **Minimap control** left-click flips **Character setting** (suppression on ↔ off).
- **Minimap control** right-click toggles **Settings window** visibility.
- **Slash commands (v1)** mirror minimap left-click toggle; they do not open **Settings window**.
- When suppression is on, all four **Suppression surfaces** hide matching content; v1 offers no per-surface opt-out in **Settings window**.
- **Map filter sync** runs once per suppression toggle (idempotent); addon hooks enforce **World map suppression** regardless.
- **WQ presentation** is suppressed in and out of **Active WQ zone**; awareness in-zone comes from **Active WQ alert**; finishing uses **Completion UI** only.
- **Active WQ alert** runs only while **Suppression** is on and the player is in an **Active WQ zone**; it targets the **Minimap control**, not the full screen.

## Example dialogue

> **Dev:** "Should we hide this bonus objective pin while suppression is on?"
> **Domain expert:** "No — v1 **Visibility rules** only target **World quests**. Bonus objectives stay visible unless we add a new rule later."

> **Dev:** "New install — are WQs hidden on first login?"
> **Domain expert:** "No — **Suppression default** is off. The player opts in; we persist that in **Character setting**."

> **Dev:** "Does right-click on the minimap icon turn WQs back on?"
> **Domain expert:** "No — left-click toggles suppression. Right-click opens the **Settings window**."

> **Dev:** "Can I hide WQs on the minimap but keep them on the world map in v1?"
> **Domain expert:** "No — suppression is all-or-nothing across surfaces until v2 settings exist."

> **Dev:** "I turned suppression on and walked into a WQ area — how do I know?"
> **Domain expert:** "The **Active WQ alert** pulses the **Minimap control** while you're in an **Active WQ zone**."

> **Dev:** "Suppression is on; I finished the objectives but the WQ needs a hand-in. Will the turn-in window show?"
> **Domain expert:** "Yes — **Completion UI** is never suppressed. Auto-complete WQs need no dialog; manual turn-ins always surface."

> **Dev:** "The WQ auto-completed — hide the reward toast?"
> **Domain expert:** "No — reward and quest-complete feedback are **Completion UI**, same as manual turn-ins."

> **Dev:** "I'm in the WQ area doing it organically — show tracker objectives?"
> **Domain expert:** "No — all **WQ presentation** stays hidden. Use the **Active WQ alert**; **Completion UI** when you're done."

> **Dev:** "Suppress talking-head audio but keep the frame?"
> **Domain expert:** "No — suppression hides every **WQ presentation** element, including audio and visuals."

> **Dev:** "I turned suppression off — do you restore my old map filter setting?"
> **Domain expert:** "No snapshot — **Map filter sync** turns the checkbox on (no-op if already on)."

## Flagged ambiguities

- "Accepted" / "in-progress world quest" (regular-quest model) — **resolved**: WQs activate on zone entry; use **Active WQ zone** instead.
- Restore **Blizzard WQ map filter** when suppression turns off — **resolved**: **Map filter sync** enables filter on suppression off (no snapshot).
- **Active WQ zone** detection — **resolved**: match “game would show during-quest presentation” local active state, not distant pins.
- **Retail scope** — **resolved**: v1 retail only.
- **Addon compatibility** — **resolved**: no third-party integration in v1.
