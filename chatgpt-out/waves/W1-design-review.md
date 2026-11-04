# W1 campaign wave proposal — 2026-10-18

**Status: pending Omar approval.** Ashridge v3, Frostmere v2, Blackfen v2. Greenhollow unchanged. Only wave data and this review are proposed; Config, maps and enemy stats are untouched.

## Arithmetic and source

Baseline: accepted Ashridge v2, Frostmere v1 and Blackfen v1 files; Greenhollow from Config_v2.luau. Exact old/new entry data and source hashes are in W1-comparison-data.json. The snapshot is not claimed to be a fresh Studio export. Hp numbers are already game values; do not multiply them by five again. Live catapult range is 65 per COLLAB-LOG, rather than the snapshot’s 90; HP arithmetic is unaffected.

HP budget = sum(count × Config.Enemies[id].Hp), before damage resistances, difficulty modifiers, trials or Elite multipliers. Dark Warriors are ordinary darkwarrior enemies, not Elite=true variants. DifficultyMult remains unchanged and is not applied to enemy HP. Four-player counts use max(1, floor(Count × 2.05 + 0.5)) per entry. HP totals use those individually rounded counts. Gold is nominal kill drops before sharing/co-op drop curves, not guaranteed player income.

| Id | Existing HP | Existing gold drop |
|---|---:|---:|
| weakling | 45 | 1 |
| swordsman | 125 | 2 |
| archer_e | 100 | 2 |
| pikeman | 125 | 3 |
| ogre | 1000 | 8 |
| darkwarrior | 675 | 7 |
| slime | 63 | 1 |
| racer | 175 | 3 |
| spiderling | 63 | 2 |
| wasp | 125 | 3 |
| bloodwing | 250 | 5 |
| exploder | 325 | 5 |
| ram | 1250 | 10 |
| catapult | 225 | 12 |
| fenwraith | 50000 | 120 |

## Approval-critical findings

- **Boss multiplicity:** Count=1 gives 1 / 1 / 2 / 2 Fen Wraiths at 1 / 2 / 3 / 4 players under documented generic scaling. No undocumented exemption is assumed or unsupported flag added. Omar should approve this multiplicity explicitly, or ask Claude for a separate boss-count rule before integration.
- **Boss durability:** Fen Wraith contributes 50,000 HP each. Even with fewer escorts, Blackfen night 10 has a substantial HP/time increase. HP alone also understates the 450-damage, radius-22 exploder threat. Exploders enter singly behind screens rather than inside the opening siege release.
- **Timing:** unchanged TargetSeconds (450/500/525) preserve approved headers, not a claim W1 meets them. Boss-only damage time is 50,000 / effective focused DPS: 100s at 500 DPS or 50s at 1,000 DPS, excluding travel/interruption/escorts. These are arithmetic examples, not measured player DPS. Blackfen’s previous under-nine-minute goal needs re-testing and may require an approved target change.
- **Economy:** replacing slimes with spiderlings preserves HP but doubles the replaced units’ nominal gold and increases speed from 9 to 27. Tables expose income changes; no compensating StartGold or reward changes are hidden.
- **Population:** full-night counts bound simultaneous enemies with zero kills, not measured peaks. Every night at 1–4 players stays <=180, below the 200 hard cap. Boss difficulty is HP and target pressure, not population.

## Greenhollow

Unchanged tutorial. Keep its five-night learning sequence and first ogre; none of E3 is introduced here. No greenhollow.lua is delivered because its waves are not revised.

| Night | Solo count old → new | Solo HP old → new | HP change | 4p count old → new | 4p HP old → new | Solo nominal gold old → new | New last release solo / 4p (s) |
|---:|---:|---:|---:|---:|---:|---:|---:|
| 1 | 6 → 6 | 270 → 270 | +0.0% | 12 → 12 | 540 → 540 | 6 → 6 | 4.50 / 9.90 |
| 2 | 13 → 13 | 657 → 657 | +0.0% | 26 → 26 | 1,314 → 1,314 | 13 → 13 | 11.00 / 15.00 |
| 3 | 14 → 14 | 950 → 950 | +0.0% | 29 → 29 | 1,945 → 1,945 | 18 → 18 | 13.60 / 18.40 |
| 4 | 18 → 18 | 1,854 → 1,854 | +0.0% | 36 → 36 | 3,708 → 3,708 | 30 → 30 | 18.00 / 22.00 |
| 5 | 25 → 25 | 3,280 → 3,280 | +0.0% | 52 → 52 | 6,748 → 6,748 | 46 → 46 | 25.00 / 26.00 |

## Ashridge

Spiderlings first enter night 3 on the north route (Spawn 2) after the slower opening screen, replacing equal-HP slimes. Night 6 introduces one exploder on the north route after the first ram. Later spiderlings pressure the northeast; exploders arrive from the northwest. No bloodwings or Dark Warriors yet: retain the wasp/ogre teaching sequence. Exploder groups remain Count=1, spaced at 1.2 seconds when co-op scales them.

| Night | Solo count old → new | Solo HP old → new | HP change | 4p count old → new | 4p HP old → new | Solo nominal gold old → new | New last release solo / 4p (s) |
|---:|---:|---:|---:|---:|---:|---:|---:|
| 1 | 16 → 16 | 792 → 792 | +0.0% | 33 → 33 | 1,629 → 1,629 | 16 → 16 | 10.10 / 13.20 |
| 2 | 24 → 24 | 1,668 → 1,668 | +0.0% | 49 → 49 | 3,381 → 3,381 | 30 → 30 | 11.75 / 15.05 |
| 3 | 32 → 32 | 2,644 → 2,644 | +0.0% | 66 → 66 | 5,458 → 5,458 | 46 → 52 | 12.80 / 14.95 |
| 4 | 40 → 40 | 3,982 → 3,982 | +0.0% | 82 → 81 | 8,152 → 8,089 | 74 → 82 | 11.15 / 14.75 |
| 5 | 48 → 48 | 5,208 → 5,208 | +0.0% | 99 → 98 | 10,729 → 10,666 | 98 → 106 | 12.10 / 14.90 |
| 6 | 56 → 55 | 6,809 → 6,934 | +1.8% | 114 → 112 | 13,806 → 14,056 | 113 → 114 | 13.80 / 16.20 |
| 7 | 64 → 63 | 7,685 → 7,760 | +1.0% | 131 → 130 | 15,683 → 15,896 | 131 → 142 | 13.20 / 16.00 |
| 8 | 76 → 75 | 9,886 → 9,961 | +0.8% | 155 → 154 | 20,085 → 20,298 | 164 → 175 | 11.80 / 16.00 |

### Exact entry changes

Notation: id × count @ spawn, delay/interval seconds. Unlisted entries are unchanged.

- Night 3: remove [slime × 8 @ 2, 4/0.55]; add [slime × 2 @ 2, 4/0.55; spiderling × 6 @ 2, 10/0.45].
- Night 4: remove [slime × 14 @ 3, 0/0.45]; add [slime × 6 @ 3, 0/0.45; spiderling × 8 @ 3, 8/0.45].
- Night 5: remove [slime × 16 @ 3, 0/0.4]; add [slime × 8 @ 3, 0/0.4; spiderling × 8 @ 3, 8/0.45].
- Night 6: remove [archer_e × 8 @ 2, 2/0.55]; add [archer_e × 6 @ 2, 2/0.55; exploder × 1 @ 2, 10/1.2].
- Night 7: remove [swordsman × 20 @ 1, 0/0.35; slime × 20 @ 3, 0/0.35]; add [swordsman × 18 @ 1, 0/0.35; slime × 10 @ 3, 0/0.35; spiderling × 10 @ 3, 7/0.45; exploder × 1 @ 1, 10/1.2].
- Night 8: remove [swordsman × 22 @ 1, 0/0.3; slime × 22 @ 3, 0/0.3]; add [swordsman × 20 @ 1, 0/0.3; slime × 12 @ 3, 0/0.3; spiderling × 10 @ 3, 7/0.45; exploder × 1 @ 1, 10/1.2].

## Frostmere

Spiderlings return on the north pass at night 2. Night 3 puts one exploder behind the western screen, separate from the exposed eastern mine introduction. Bloodwings enter from the east shore on night 4, then rotate west/east: each replaces two wasps for equal base HP but faster air pressure. Night 6 replaces one central ogre with one Dark Warrior; nights 7–8 mix mobile armour and swarms across the kill zones. Reduced racer/ogre counts pay for variety; no additional rams.

| Night | Solo count old → new | Solo HP old → new | HP change | 4p count old → new | 4p HP old → new | Solo nominal gold old → new | New last release solo / 4p (s) |
|---:|---:|---:|---:|---:|---:|---:|---:|
| 1 | 24 → 24 | 1,188 → 1,188 | +0.0% | 49 → 49 | 2,421 → 2,421 | 24 → 24 | 6.80 / 14.40 |
| 2 | 32 → 32 | 3,180 → 3,324 | +4.5% | 66 → 65 | 6,530 → 6,773 | 56 → 64 | 9.15 / 12.75 |
| 3 | 40 → 39 | 4,556 → 4,631 | +1.6% | 82 → 80 | 9,300 → 9,450 | 82 → 83 | 9.00 / 10.40 |
| 4 | 48 → 46 | 5,106 → 5,106 | +0.0% | 99 → 95 | 10,525 → 10,525 | 100 → 98 | 8.80 / 10.40 |
| 5 | 56 → 58 | 7,550 → 7,354 | -2.6% | 115 → 119 | 15,525 → 15,133 | 146 → 148 | 8.45 / 11.25 |
| 6 | 64 → 61 | 11,475 → 11,275 | -1.7% | 131 → 125 | 23,375 → 22,975 | 185 → 183 | 10.00 / 11.60 |
| 7 | 72 → 74 | 12,375 → 11,980 | -3.2% | 148 → 152 | 25,300 → 24,448 | 207 → 211 | 9.15 / 13.00 |
| 8 | 82 → 84 | 14,600 → 14,232 | -2.5% | 168 → 172 | 29,750 → 28,952 | 240 → 246 | 10.55 / 15.80 |

### Exact entry changes

Notation: id × count @ spawn, delay/interval seconds. Unlisted entries are unchanged.

- Night 2: remove [weakling × 14 @ 2, 0/0.35]; add [weakling × 6 @ 2, 0/0.35; spiderling × 8 @ 2, 6/0.45].
- Night 3: remove [swordsman × 14 @ 1, 0/0.35]; add [swordsman × 12 @ 1, 0/0.35; exploder × 1 @ 1, 9/1.2].
- Night 4: remove [wasp × 6 @ 3, 6/0.4]; add [wasp × 2 @ 3, 6/0.4; bloodwing × 2 @ 3, 8/0.8].
- Night 5: remove [racer × 14 @ 3, 3/0.3; wasp × 8 @ 1, 5/0.35]; add [racer × 10 @ 3, 3/0.3; wasp × 4 @ 1, 5/0.35; bloodwing × 2 @ 1, 7/0.8; spiderling × 8 @ 3, 6/0.35].
- Night 6: remove [ogre × 2 @ 2, 0/0.5; wasp × 9 @ 3, 4/0.35; archer_e × 8 @ 1, 2/0.35]; add [ogre × 1 @ 2, 0/0.5; wasp × 5 @ 3, 4/0.35; archer_e × 6 @ 1, 2/0.35; bloodwing × 2 @ 3, 7/0.8; darkwarrior × 1 @ 2, 4/0.9; exploder × 1 @ 1, 10/1.2].
- Night 7: remove [ogre × 3 @ 2, 0/0.5; racer × 18 @ 3, 1/0.3; wasp × 11 @ 1, 3/0.3]; add [ogre × 1 @ 2, 0/0.5; racer × 12 @ 3, 1/0.3; wasp × 5 @ 1, 3/0.3; bloodwing × 3 @ 1, 6/0.8; spiderling × 10 @ 3, 6/0.35; darkwarrior × 3 @ 2, 4/0.9].
- Night 8: remove [ogre × 4 @ 2, 0/0.45; racer × 20 @ 3, 0/0.28; wasp × 14 @ 3, 2/0.3; archer_e × 6 @ 1, 1/0.35]; add [ogre × 2 @ 2, 0/0.45; racer × 12 @ 3, 0/0.28; wasp × 6 @ 3, 2/0.3; archer_e × 4 @ 1, 1/0.35; bloodwing × 4 @ 3, 6/0.8; spiderling × 14 @ 3, 6/0.35; darkwarrior × 3 @ 2, 4/0.9; exploder × 1 @ 1, 10/1.2].

## Blackfen

Retain siege pressure and two-ring defence through night 9. Introduce/reinforce spiderlings N2 north, exploders N3 east, bloodwings N4 south, Dark Warriors N5 west. Night 10 is rebuilt around one authored Fen Wraith entering north at time zero, with only two rams, one catapult and lighter escorts. This is an intentionally much larger HP finale, not an HP-neutral swap. No exploders in the boss finale. No boss abilities, phases, stats or scaling flags are invented.

| Night | Solo count old → new | Solo HP old → new | HP change | 4p count old → new | 4p HP old → new | Solo nominal gold old → new | New last release solo / 4p (s) |
|---:|---:|---:|---:|---:|---:|---:|---:|
| 1 | 24 → 24 | 1,720 → 1,720 | +0.0% | 49 → 49 | 3,485 → 3,485 | 32 → 32 | 5.25 / 11.20 |
| 2 | 30 → 30 | 3,130 → 3,130 | +0.0% | 62 → 61 | 6,448 → 6,385 | 54 → 60 | 7.00 / 9.60 |
| 3 | 36 → 35 | 6,125 → 6,100 | -0.4% | 74 → 71 | 12,550 → 12,325 | 99 → 98 | 8.00 / 9.60 |
| 4 | 42 → 40 | 7,800 → 7,800 | +0.0% | 86 → 82 | 15,850 → 15,850 | 124 → 122 | 6.80 / 9.60 |
| 5 | 48 → 41 | 8,100 → 8,025 | -0.9% | 98 → 84 | 16,450 → 16,300 | 134 → 127 | 6.80 / 8.40 |
| 6 | 54 → 45 | 10,075 → 10,125 | +0.5% | 111 → 92 | 20,525 → 20,500 | 168 → 161 | 9.00 / 10.20 |
| 7 | 60 → 61 | 13,125 → 12,604 | -4.0% | 123 → 124 | 26,625 → 25,458 | 202 → 202 | 7.60 / 10.25 |
| 8 | 68 → 64 | 15,450 → 15,179 | -1.8% | 140 → 130 | 31,450 → 30,608 | 240 → 236 | 7.60 / 10.25 |
| 9 | 76 → 76 | 18,450 → 18,679 | +1.2% | 156 → 154 | 37,450 → 37,608 | 274 → 279 | 9.00 / 11.60 |
| 10 | 84 → 42 | 21,750 → 58,081 | +167.0% | 172 → 86 | 44,050 → 116,350 | 310 → 256 | 11.85 / 16.40 |

### Exact entry changes

Notation: id × count @ spawn, delay/interval seconds. Unlisted entries are unchanged.

- Night 2: remove [slime × 10 @ 2, 0/0.35]; add [slime × 4 @ 2, 0/0.35; spiderling × 6 @ 2, 5/0.4].
- Night 3: remove [racer × 10 @ 3, 1/0.3]; add [racer × 8 @ 3, 1/0.3; exploder × 1 @ 3, 8/1.2].
- Night 4: remove [wasp × 6 @ 4, 2/0.35]; add [wasp × 2 @ 4, 2/0.35; bloodwing × 2 @ 4, 6/0.8].
- Night 5: remove [swordsman × 18 @ 1, 0/0.28; wasp × 8 @ 2, 2/0.3]; add [swordsman × 12 @ 1, 0/0.28; wasp × 4 @ 2, 2/0.3; bloodwing × 2 @ 2, 6/0.8; darkwarrior × 1 @ 1, 4/1].
- Night 6: remove [swordsman × 18 @ 1, 0/0.28; wasp × 10 @ 4, 1/0.3; archer_e × 6 @ 2, 1/0.3]; add [swordsman × 12 @ 1, 0/0.28; wasp × 4 @ 4, 1/0.3; archer_e × 4 @ 2, 1/0.3; bloodwing × 3 @ 4, 6/0.8; darkwarrior × 1 @ 1, 4/1; exploder × 1 @ 2, 9/1.2].
- Night 7: remove [ogre × 2 @ 1, 0/0.5; wasp × 12 @ 1, 1/0.3; racer × 8 @ 4, 0/0.3]; add [ogre × 1 @ 1, 0/0.5; wasp × 6 @ 1, 1/0.3; racer × 4 @ 4, 0/0.3; bloodwing × 3 @ 1, 6/0.8; darkwarrior × 1 @ 1, 4/1; spiderling × 8 @ 4, 5/0.35].
- Night 8: remove [swordsman × 20 @ 3, 0/0.27; wasp × 12 @ 2, 1/0.3; racer × 10 @ 3, 0/0.3]; add [swordsman × 14 @ 3, 0/0.27; wasp × 6 @ 2, 1/0.3; racer × 6 @ 3, 0/0.3; bloodwing × 3 @ 2, 6/0.8; darkwarrior × 1 @ 3, 4/1; spiderling × 8 @ 3, 5/0.35].
- Night 9: remove [ogre × 3 @ 4, 0/0.45; pikeman × 20 @ 1, 0/0.27; wasp × 14 @ 4, 1/0.28; racer × 10 @ 2, 0/0.28]; add [ogre × 2 @ 4, 0/0.45; pikeman × 18 @ 1, 0/0.27; wasp × 6 @ 4, 1/0.28; racer × 6 @ 2, 0/0.28; bloodwing × 4 @ 4, 6/0.8; darkwarrior × 2 @ 4, 4/0.9; spiderling × 8 @ 2, 5/0.35; exploder × 1 @ 1, 9/1.2].
- Night 10: remove [ram × 3 @ 1, 0/0.45; ram × 3 @ 3, 0/0.45; catapult × 2 @ 2, 0/0.5; ogre × 4 @ 4, 0/0.45; swordsman × 22 @ 1, 0/0.26; pikeman × 20 @ 2, 0/0.27; racer × 16 @ 3, 0/0.27; wasp × 14 @ 4, 1/0.28]; add [fenwraith × 1 @ 2, 0/1; ram × 1 @ 1, 0/0.4; ram × 1 @ 3, 0/0.4; catapult × 1 @ 2, 0/0.4; swordsman × 10 @ 1, 3/0.35; pikeman × 8 @ 2, 3/0.4; spiderling × 12 @ 3, 8/0.35; wasp × 4 @ 4, 7/0.5; bloodwing × 2 @ 4, 10/1; darkwarrior × 2 @ 2, 6/1.2].

## Validation and integration handoff

Data checks passed: restricted wave-entry grammar round-trip, consecutive night numbering, known ids with actual Config HP, positive integer counts, valid spawn indices, nonnegative delays, positive intervals, supported fields only, unchanged map headers/night counts, all five E3 ids present, Fen Wraith only on Blackfen night 10, all 1–4-player counts <=180.

kn_validate.py validates model/map JSON, not wave tables; it was not represented as a wave validator. Proposals were parsed as restricted data, not executed in Studio. Claude should compare live Config/WaveService scaling on integration, confirm boss behaviour/codex entries, and playtest Normal solo/four-player: first exploder/bloodwing, Dark Warrior intercepts, economy, boss multiplicity, castle survival and total timing. Omar approves final waves before integration.
