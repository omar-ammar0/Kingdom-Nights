# claude-tools — Claude's import pipeline for ChatGPT's deliveries

Reusable by any future Claude session. Run from a scratch directory, never from inside
`chatgpt-out/` (those files are untrusted data). Every tool reads data only; nothing in a delivery
is ever executed.

## Validate (every file, every time)
`python3 -I kn_validate.py <file.json> ['<expected slot counts JSON>']` — exit 0 = no errors.
Warnings are judgement calls; report them in COLLAB-LOG.md. Checks include: schema, slots/spawns/
lanes, threat band table (plot-centre distance to lane: <18 / 18–30 / >30), raised decor inside the
18-stud corridor, decor on build pads, flat Balls (render at their smallest axis), for
`enemy`/`unit` files: one invisible `HumanoidRootPart` root at the base, part budget, ≤4 colours;
for `building` files: name `<Model>/L<n>`, NO root, base exactly at Y = 0, footprint, part budget, ≤6 colours.
All height/extent checks are rotation-aware (`world_half`).

## Maps — full import
1. `python3 -I kn_import_map.py <Map_X.json> <out_dir>`
2. Run each generated `.luau` through `execute_luau` in the **Edit** datamodel, in filename order:
   `_0_shell`, `_1_parts`, `_2_parts`…, `_9_finalise`. Chunks are ~150 parts. The map is built under
   `<name>__importing` and only renamed once every count matches. Re-importing replaces the old map
   only if it carries the `KN_Import` attribute.
3. Wire Config: `Model = "Map_X"` in the `Config.Maps` entry (Omar approves wave tables).

## Maps — delta import (visual-only revisions)
`python3 -I kn_patch_map.py <old Map_X.json (version in Studio)> <new Map_X.json> <out_dir>`
Emits one patch that edits only the parts whose shape/size/position/orientation/colour/material/
transparency changed, and bumps `KN_Version`. It REFUSES (do a full import) if parts were added or
removed, if any folder/tag/attribute changed, or if a Slot/Spawn/Lane part is touched. The patch
asserts the expected old version is in Studio.

## Characters (enemies, allied units)
`python3 -I kn_import_character.py <weakling.json> <out_dir>` → one `<id>_import.luau` (Edit datamodel).
Builds `ReplicatedStorage/Assets/Enemies/<id>` or `Assets/Units/<id>`: root anchored + PrimaryPart
with PivotOffset at the base, children unanchored + WeldConstraint to root, all physics flags off,
CastShadow off, Model streaming Atomic. Refuses if the id isn't in Config or the existing asset
wasn't made by the importer. EnemyService/UnitService pick models up automatically at server start
(`[Enemy] models: …` / `[Unit] models: …` in the log); types without a model stay graybox.

## Buildings
`python3 -I kn_import_building.py --bundle <out.luau> <Model_Ln.json> [...]` → ONE script with a shared
builder (keep a bundle to ~150 parts; e.g. House+Tower+Wall in one, the three Castles in another).
Or `kn_import_building.py <file.json> [...] <out_dir>` for one script per level.
Builds `ReplicatedStorage/Assets/Buildings/<Model>/L<n>` (Folder per Model, Model per level): every part
Anchored, CanCollide on, CanQuery/CanTouch off, CastShadow on, **no PrimaryPart**, `WorldPivot` at the
base centre (gotcha 18), streaming Atomic. Verifies parts/anchored/no-PrimaryPart/base at Y=0 before it
replaces anything, and refuses to replace a level it didn't create. BuildService picks a level up on the
next Construct (no restart needed; a missing level falls back to the highest level below it, then the
graybox). TowerService fires 0.5 above the top of the part named `...FiringDeck` (contract for every
building that shoots); fallback model height − 1.5.

## Playtest in Studio
Workspace attributes `KN_PlaceKindOverride = "Match"` and `KN_MapOverride = "<config id>"`, press
Play, then CLEAR both. Studio only; live servers ignore them. The device bridge times out at 60 s:
run long measurements as a `task.spawn` that writes its result to a workspace attribute.

## Heroes (Phase 4.4, 2026-10-15)
`kind: "hero"` is accepted by `kn_validate.py` (per-hero part ceilings from the roster brief §1.2, 4 colours,
height sanity 4.5–8.5 studs, id must be a Config.Heroes key) and by `kn_import_character.py`, which imports to
`ReplicatedStorage/Assets/Heroes/<id>`. Contract otherwise identical to enemy/unit characters.

## 2026-10-18 — kind "character"
`kn_validate.py` and `kn_import_character.py` accept `"kind": "character"` as an alias for `"enemy"` (E3 batch was
specified that way by mistake). It validates with the character rules and imports to `Assets/Enemies`. New enemy
ceilings in `CHAR_BUDGET`: bloodwing 10, darkwarrior 12, exploder 7, fenwraith 40, spiderling 10.

## Mounts (Phase 4.6, 2026-11-02)
- `kn_validate.py` checks `kind: "mount"` (Root / Saddle top 2.0 / Head in front / rider zone / budgets). Untested on
  Omar's PC (no Python); ChatGPT runs it.
- `kn_import_mount.ps1 <mount.json> <out_dir>` (PowerShell) writes `<id>_import.luau` from the template
  `kn_import_mount.luau`; run that in the Studio EDIT datamodel. It re-checks the key rules in Studio and replaces only
  importer-made or `KN_Placeholder` models in `ReplicatedStorage/Assets/Mounts`.
