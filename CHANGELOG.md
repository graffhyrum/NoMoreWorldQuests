# Changelog

## 1.0.2

### Patch Changes

- Bump Interface to 120007 for WoW 12.0.7

## 1.0.1

### Patch Changes

- a82ffe4: Improved objective tracker suppression reliability by only installing hooks when Blizzard tracker APIs are present, and centralized skip rules in SuppressionPolicy.
- a82ffe4: Updated vendored LibDBIcon, LibDataBroker, CallbackHandler, and LibStub libraries.

## 1.0.0

- Initial release: suppress during-quest world quest UI on minimap, world map, intrusion, and objective tracker
- Completion UI always shown; minimap alert in active WQ zones
- Per-character suppression toggle (minimap + `/nmwq`); retail only
