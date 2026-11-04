# Handoff — Kingdom Nights: Castle Defense (Roblox)

**Date:** 2026-11-02 (W1 waves + boss co-op rule; 4.3–4.5 published by Omar) · **Owner:** Omar · **Phase:** 4 in progress — **4.1 rewards + 4.2 shop + map picker + parties + 4.3 daily challenges built; 4.4 heroes started (ChatGPT modelling H1)**; **Map_Frostmere + GoldMine model in Studio**; **Blackfen + catapult model imported (all 4 campaign maps done)**; parties live-verified; building models B1 imported; B1 v2 + B2 imported (all 7 building families modelled). Last publish = Batch 2 characters (confirmed live)

You are the lead engineer continuing an in-progress build. Work is delivered through a live
**Roblox Studio MCP** connection. This document covers *conversational* context only — all
design/balance detail lives in the spec files below. **Read those three files completely before
writing any code.**

---

## 1. Authoritative source files

Connected workspace folder: `X:\Documents\Thronefall Roblox`

| File | Role |
|---|---|
| `kingdom-nights-build-spec-v2.md` | The contract. Section numbers (§7, §34.3…) are referenced throughout the code. |
| `Config_v2.luau` | Balance source of truth. Every gameplay number traces here. |
| `thronefall-research-and-roblox-plan.md` | Background research. |
| `character-roster-and-design-brief.md` | Character style bible (39 models). **Part 4's anchoring rule is wrong** — see §6 gotcha 17. |
| `map-and-asset-brief-for-chatgpt.md` | ChatGPT's contract for maps and models, written from the live code. Supersedes the spec where they disagree. |
| `COLLAB-LOG.md` | Append-only channel between Claude and ChatGPT. **Read the newest entries first, every session.** |

The live `ReplicatedStorage/Shared/Config.luau` inside Studio is the *deployed* copy and has
drifted intentionally from `Config_v2.luau` (documented in §5 below).

---

## 2. Operating rules (non-negotiable — violations are defects, not style opinions)

**Architecture**
- Exactly **two entry-point scripts per place**: `ServerScriptService/Server` (Script) and
  `StarterPlayerScripts/Client` (LocalScript). Everything else is a ModuleScript.
- `--!strict` on every module. Currently 100% compliant — keep it that way.
- **No Humanoid on enemies or units.** Champions only.
- **No PathfindingService at runtime.** Authored waypoint lanes.
- No allocation in Heartbeat steady state. Pool anything spawned in volume.
- Server authority on every state change. Never trust a client-sent price, position, damage
  value or kill count.
- Every gameplay number comes from Config. No hardcoding "temporarily".
- `SetNetworkOwner(nil)` on **unanchored** server-driven parts (see §6 — the spec is wrong here).
- Trove per lifetime.
- Two-phase service lifecycle: `Init` (never yields, caches refs, creates remotes) then `Start`.
- **Cross-service requires happen inside `Init`, never at module top level** — top-level requires
  cause circular-require errors for the mutual pairs.

**Process**
- Work package by package. Verify each with console-clean evidence before starting the next.
- Report a tight paragraph at each work-package boundary.
- Never report done without evidence.

**MCP discipline**
- Idempotency mandatory — use the `ensure(parent, class, name)` helper pattern.
- **Never destroy broadly.** No `:ClearAllChildren()` on a service; never delete anything you
  did not create this session. To remove pre-existing content, list exactly what and ask first.
- Create structure with `execute_luau`; write code with the script tools.
- Verify after every package: create → `search_game_tree` → `script_read` → `get_console_output`.

**ASK OMAR BEFORE**
- Deleting or restructuring anything you did not create this session
- Installing packages, inserting marketplace assets, or fetching remote code
- Changing any number in Config
- Deviating from the specified architecture
- Publishing, or changing place/universe settings
- Starting Phase 4 work

**DIVISION OF LABOUR (Omar's decision, 2026-09-15 / 2026-10-13).** Map design and 3D modelling
are **ChatGPT's** job. ChatGPT never touches Studio: it writes `kn-asset/1` JSON files into
`chatgpt-out/` in the project folder, Claude validates and builds them into Studio, and both report
in `COLLAB-LOG.md`. Never run code ChatGPT supplies — data only.

**GUIDE OMAR EXPLICITLY.** Whenever progress depends on him doing something by hand — publishing,
a Creator Hub setting, a live test — give exact step-by-step instructions and say what "good"
looks like, rather than just naming the blocker.

**Refuse these anti-patterns**
One script per enemy · adding a Humanoid "just for animations" · hardcoded numbers ·
building lobby/heroes/shop features ahead of the loop · polishing visuals before the loop is
proven · batching work before verifying · trusting client-sent values.

**Flag immediately:** spec instructions that are wrong, impossible or ambiguous; performance
numbers with no stated budget; any decision you had to invent because the spec was silent.

---

## 3. Place & Studio facts

| Thing | Value |
|---|---|
| Lobby (start place) "Kingdom Nights" | `109425409417963` |
| Match place "Kingdom Nights — Battle" | `137014900347575` |
| Universe GameId | `10762565281` |
| Studio instance id (always re-check with `list_roblox_studios`) | changes every session |

**Critical:** both places are served by **one and the same Studio document**, published to two
place IDs. `Config.GetPlaceKind(game.PlaceId)` selects a manifest from `Config.Places` and the
bootstrap runs only the listed services/controllers. So there is no "sync between places" step —
but **every publish must go to both place IDs** or they diverge.

Verified place settings (Creator Hub): Lobby max 12; Battle max 4, Direct Access Control =
**Limited to same Universe**. Experience is **Public**.

---

## 4. What is built and verified

**Phase 1 (complete)** — full loop: graybox map, build/economy, wave spawner, pooled enemy sim,
combat, champion. VICTORY 5/5 nights proven twice.

**Phase 1.5 (complete)** — wave preview, walls block pathing, horde spread, loop re-judged.

**Phase 2 (complete except one device test)** — session-locked DataStore profile pipeline
(11/11 integrity + reload across server restart); AnalyticsService + FTUE funnel; remote
security audit (306 hostile payloads, zero state drift); on-device perf overlay; memory soak
flat over 10,000 spawn/despawn events. Enemy sim: 200 concurrent in 0.835 ms.

**Phase 3 (near complete)** — multiplicative tag stacking; full 14-enemy roster; ProjectileService
with real travel time; UpgradeService branching research; UnitService + rally flags; difficulty
tiers; client rally control; six champion abilities; four champions from profile; champion auras;
place-gated bootstrap; minimal lobby world; PartyService + reserved-server teleport; Quick Play
matchmaking (P3.15); rejoin (P3.16); **match→lobby return teleport**; **rejoin record lifecycle**.

### Session of 2026-09-14 — §7A closed, then the live gate found two real gaps

**§7A.2 — Quick Play toggle through the real UI: PASSED as written.** `Lobby_QuickPlay(true)` →
`SEARCHING Ns - TAP TO CANCEL` on Danger red, PLAY greyed from Good to PanelLight, counter ticking
live across poll cycles; `(false)` reverts all three. Console clean. One incidental `ReserveServer
403` proved the `SoloSeconds` ceiling fires and that its failure handler releases the party back to
the queue without disturbing the UI.

**§7A.1 — stale rejoin record: FAILED, fixed, re-verified.** `PartyService:Rejoin` fired
`Lobby_Result(false, …)` directly and returned, bypassing the `recover()` funnel. The toast
appeared but the REJOIN button survived, because the client restores its visibility from the last
state snapshot and no state re-push ever happened. A player whose run had ended sat on a dead
button that would fail forever. **Fix:** route the no-record path through `recover()`, which
re-pushes lobby state. Re-verified on a fresh boot: `Rejoin.Visible` true → false, toast correct,
PLAY and QUICK PLAY both left usable.

**Live gate (both places published, real client) — what it proved and what it broke open:**

Proven live: teleport lobby→match; `ReserveServer` works outside Studio; Battle boots
`[Match]` 14 services / 0 failed / 3 correctly skipped; TeleportData validated; map validates 0
errors; champion spawns; join-to-playable ≈ 4 s against an 8 s budget.

**Gap 1 — rejoin offered a run that could not be resumed.** Leaving a solo run and tapping REJOIN
teleported the player into a *brand-new night 1*. Cause: the reserved server dies with its last
player, `endRun` never fires, and `RejoinStore.Clear` was called **only** from inside `endRun`.
The record outlived its own server, and Roblox answers a dead access code by cold-booting a fresh
server with that code. Diagnosed from the log: `[Match] Loading` adjacent to `[Server] … ready
21ms` is a cold boot, not a join.

**Gap 2 — there was no return teleport at all.** `TeleportService` appeared only in PartyService
and MatchmakingService, both lobby-side, both outbound. `MatchService` carried the comment
`-- Phase 3 teleports back to the lobby here. Phase 1 stops.` — never written. Consequence: no
`DataService:Release` on the match side either, so §30's "no session-lock stall" criterion was
not merely unverified, half of it did not exist.

**WP1 — return leg (built, VERIFIED LIVE).** `returnAllToLobby(summary)` in MatchService, at the
spot the spec's own comment marked. Holds the result for `Config.Match.ResultsSeconds`, re-reads
the player list (people leave during the dwell, and `TeleportAsync` throws on a list containing a
departed player), calls `DataService:ReleaseMany` **before** teleporting per §2.2, then
`TeleportAsync` to `LobbyPlaceId` with `{ LastRunSummary = summary }` and the same 3-attempt
backoff PartyService uses outbound. Placed in MatchService rather than a new `ReturnService`
because §3.3's match-place service list has no such service and PartyService is not in this
place's manifest. Live evidence: `RUN ENDED - DEFEAT` → `[Match] returned 1 player(s) to the lobby`.

**WP2 — honest rejoin offers (built, VERIFIED LIVE).** Record clearing extracted from `endRun`
into `clearRejoinRecords()`, with two new callers: `PlayerRemoving` when the run is still live and
the leaver is the last one out (the count reads **1**, not 0 — `PlayerRemoving` fires before the
list updates), and `game:BindToClose` for shutdowns that produce no last `PlayerRemoving`. Live
evidence: left a run mid-night, returned to the lobby, **REJOIN correctly absent**.

**`Debug_EndRun` added to DebugService.** Losing a run honestly takes ~8 minutes, which made every
round-trip test too expensive to repeat. Goes through the real `MatchService:EndRun` so the thing
under test stays the real code path. Same three gates as the stress spawn (`EnablePerfTools`,
owner-or-Studio, rate limited) and dies with that flag. **Not yet confirmed working** — see §7.

### Session of 2026-09-15 — teammate hold-to-revive (§12.5) and lock instrumentation

- **Teammate revive built** (ChampionService + HUDController). No remote: proximity is
  server-known. Runs on the 10 Hz slow tick with real elapsed time. Revives **in place** at
  `ReviveHpFraction`; stepping away resets (never pauses). Three server→client events drive a
  locally-animated bar. Read-back caught a 4-player bug (a cancel for someone else's revive hid
  your banner); the banner now tracks its own `reviveFor`.
- **DataService:** `[Data] loaded … Nms` now reports load time, and the lock-wait retry **warns**
  instead of retrying silently. Session-lock round trip proven live: 4 s matchmaking + 1.5 s load,
  well under one 7 s lock wait, so no contention.
- **Live:** `Debug_EndRun` must be called in server context —
  `require(game.ServerScriptService.Services.MatchService):EndRun(false)` works from the live F9
  console (it shares the server's require cache, unlike Studio's plugin).

### Session of 2026-10-13 — Phase 3 closed on systems; content pipeline

Omar chose to close Phase 3 on systems, with the campaign maps becoming a ChatGPT content track
alongside Phase 4. **Compile check of last month's work:** Match manifest booted 14 services / 5
controllers / **0 failed**, so the revive and DataService changes load cleanly.

- **Building loader (VERIFIED).** `BuildService` uses
  `ReplicatedStorage/Assets/Buildings/<Model>/L<n>` when present (else the highest level below it),
  otherwise the graybox. It forces `Anchored`/`CanQuery`/`CanTouch` and pivots to the slot. Tested:
  a test House built from the asset beside a graybox Castle in one run; the test asset was removed.
- **Silent gold loss fixed.** Seven SlotTypes had no `Config.Graybox.Sizes` entry, so
  `makeGrayboxModel` threw *after* `TrySpend`. Fixed three ways: entries added (approved), an
  unguarded index replaced by a House-size fallback with a warning, and `Construct` now builds the
  new model before destroying the old one. The build handler pcalls `Construct` and **refunds**
  if the level did not advance.
- **`Config.GetPlaceKind` Studio override.** The workspace attribute `KN_PlaceKindOverride =
  "Match"` (or `"Lobby"`) forces a manifest — **Studio only**, ignored live. This is how match code
  is tested from the Lobby-associated document. Clear it afterwards.
- `Assets/Buildings`, `Assets/Enemies`, `Assets/Units` skeleton created (empty).
- ChatGPT brief and collab log written and placed in the project folder.

**Later the same day — first ChatGPT delivery, and a core engine bug it exposed**
- **`Map_Greenhollow` v1 (ChatGPT) imported and accepted.** 294 parts; 0 errors in Claude's
  validator and in the game's own validator; Mill built; night 1 survived; **wall interception
  verified** (9/9 lane-1 enemies stopped at `wal_01`). `Config.Maps.greenhollow.Model =
  "Map_Greenhollow"` added (the default `Map_<id>` would have looked for lower-case `greenhollow`).
- **ENGINE BUG FIXED — ground enemies ignored lanes entirely.** `acquireTarget` took the nearest
  built building at *any* distance; the castle always stands, so every ground enemy beelined at a
  building from its first search and lanes were never used. Hidden for months because graybox
  lanes are straight lines to the castle. Now: ground enemies walk the lane and break off only for
  something within `AggroRadius` (or a blocking wall); lane end → castle; boss walks the lane and
  takes only the castle; flyers unchanged (nearest building anywhere). Plus skip-ahead in
  `advanceAlongLane` so a detoured enemy never walks backwards to a node it passed. Verified:
  lane-1 enemies' `x − z` averaged −35.7 against the lane's −36. **This changes difficulty**:
  off-lane buildings are no longer attacked by ground enemies. Needs Omar's playtest.
- **`KN_MapOverride`** (Studio only, MatchService) picks the map for local tests.
- **Import pipeline saved to `claude-tools/`** in the project folder (`kn_validate.py`,
  `kn_import_map.py`, README). Tool output was compile-checked in Studio, including the finalise
  gate refusing an incomplete import.

### Session of 2026-10-13 (evening) — ChatGPT batch 2 processed (§7B steps 1–3)

Omar confirmed **both places were published** after the difficulty fix.
- **Greenhollow v3 accepted** (372/372, 0/0 validator, game validator 0 errors). **Threat band proven in
  play:** lane-2 slimes left the road and destroyed a House at `hou_03` in night 2;
  `Morning 2: +0 gold (1 suppressed - buildings lost last night)`. Defect sent back: `RoadJoin_*` are
  flat Balls → invisible (Roblox renders a Ball at its smallest axis) → green notch at every road bend.
- **Ashridge v2 imported** (492/492, 45 slots, 3 lanes, game validator 0 errors). Same RoadJoin defect.
- **Ashridge waves approved by Omar as written** and added as `Config.Maps.ashridge` (38/38 entries
  diffed identical to ChatGPT's file). Engine 4p totals (round, not ceil): 33/49/66/82/99/114/131/155.
- **Found:** `DifficultyMult`, `UnlockLevel`, `HeroLevelCap`, `TargetSeconds` are typed in `Types` but
  read by **no script**; only `StartGold` is live. Difficulty today = counts/mix/timing only.
- Undefended solo Ashridge: night 1 survived, **castle falls 62 s into night 2** (Greenhollow lasts to
  night 4). Needs Omar's hands-on playtest before tuning.
- `kn_validate.py` gained: raised-decor vs 18-stud corridor (segment-to-rotated-rect), a threat-band
  table, a no-threat-band warning, and a flat-Ball warning. Committed to `claude-tools/`.
- MCP note: **the device bridge times out at 60 s.** For longer measurements, `task.spawn` the
  sampler in the Client/Server datamodel, have it write results to a `workspace` attribute, and read
  that back later.
- `script_grep` takes **Lua patterns: no `|` alternation.** A query with `|` silently returns "No
  matches". Scan `.Source` via `execute_luau` for several tokens.

**Later the same evening — §7B step 4 done: character models are live in the engine.**
- **Validator bug (mine), found by ChatGPT:** height checks ignored rotation, so an end-on Cylinder
  read as 18.5 tall. Now rotation-aware (`world_half`). Greenhollow **v4** and Ashridge **v3** (RoadJoin
  → flat Cylinder) are 0/0 and were applied with the new **delta importer** `kn_patch_map.py`
  (visual-only diffs; refuses structural changes). Bend notches confirmed gone by screenshot.
- **Character importer** `kn_import_character.py` → `ReplicatedStorage/Assets/Enemies/<id>` /
  `Assets/Units/<id>` (id = exact Config id, map brief §8.2). Imported **weakling, swordsman (enemies),
  knight (unit)** v1.
- **`Shared/Util/ModelPool`** (new, `--!strict`): per-type pools of whole models; `Get` returns the
  anchored root; hide = park the assembly at Y −400 (above FallenPartsDestroyHeight); elite =
  `ScaleTo(EliteScale)` + lerp each part toward `EnemyElite` by `EliteModelTint`, undone on return.
- **EnemyService:** uses a model pool for any def with an asset, graybox pool otherwise
  (`[Enemy] models: …` at boot). Model ground offset = root half-height. `EnemyService:Reserve(id, n)`.
- **WaveService:RunNight** reserves each night's scaled per-type counts before spawning, so nothing
  is cloned in the tick. Strict model pools warn once if a reservation was missed.
- **UnitService:** same pattern (`[Unit] models: …`); dead/respawning units use `hideUnit`/`showUnit`
  (park vs Transparency) so a model's invisible root is never shown.
- **DebugService stress** reserves the hard cap for both stressed types.
- **Evidence (Greenhollow, Studio):** 186 model enemies with feet at Y 0.50 and 0 stray parts; pool reuse
  (night 2 total 9 weaklings, not 15); 4 knight models from a Barracks fought at night; console clean
  over 4 nights. **Perf at 186 enemies: graybox 0.482 ms avg / 1.92 ms peak → models 0.825 ms / 3.0 ms;**
  server send ~720 → ~730 kbps.
- **Not yet exercised:** knight death→respawn path (none died), elite models (no wave spawns elites).
- Design note: when a Barracks is destroyed its knights stay on the field and are re-garrisoned at
  morning (pre-existing behaviour; Omar may want a ruling).

### Session of 2026-10-14 — Batch 2 characters: every current enemy and unit has a model

- ChatGPT delivered `slime, racer, archer_e, pikeman, wasp, ram, ogre` (enemies) + `archer` (unit), v1.
  It correctly flagged that `CHAR_BUDGET` lacked their ceilings; Claude verified them against the roster
  (E3–E13) and added them. **All 8: 0 errors / 0 warnings.** All imported with `kn_import_character.py`
  (welds N−1, pivot 0.00). Boot log: `[Enemy] models: archer_e, ogre, pikeman, racer, ram, slime,
  swordsman, wasp, weakling` · `[Unit] models: archer, knight`.
- **Debug_Stress "mix" mode** (DebugService): `Debug_Stress:FireServer(n, "mix")` from the Client spawns
  n enemies cycling through every modelled type, every 5th elite. Same gates as the stress test.
  `EnemyService:GetModelIds()` and `EnemyService:ReserveExtra(id, n)` added for it.
- **Verified in play:** archer units from an Archery Range (Ashridge) with feet at 0.50; all 9 types on
  the field at once; **wasp bottom at Y 20.5 = ground + FlightHeight 20, applied once**; 18/90 elites
  scaled ×1.35 and tinted. Screenshot: all silhouettes distinct at the gameplay camera.
- **Perf, 186 mixed enemies incl. 36 elites: avg enemy tick 1.37 ms** vs spec budget **≤ 4 ms at 180**
  (spec line ~2131). Batch 1 alone was 0.825 ms.
- **BUG FIXED:** `ModelPool:Return` undid elite scale with `Model:ScaleTo` inside the enemy tick →
  24.8 ms spike when 18 elites were cleared at once. Now `Return` only parks; `EnemyService:Spawn`
  calls `ClearElite` for non-elite spawns (outside the tick). Same end-of-run clear now peaks 5.8 ms.
- **Still untested:** unit death→respawn (`hideUnit`/`showUnit`); no knight/archer has died in a test.

### Session of 2026-10-14 (second) — live map → Greenhollow; units are now mortal

Omar confirmed **both places published after Batch 2** (live F9 `[Enemy] models:` line not yet pasted).
He deferred all device testing (FPS, 2-device Quick Play, 4p, revive) **to the end of the project**.
- **Live PLAY / Quick Play → Greenhollow (Omar approved).** New `Config.Matchmaking.DefaultMapId =
  "greenhollow"`, read by `LobbyService:RequestPlay`, `MatchmakingService` (enqueue + reservation fallback) and
  `MatchService`'s `DEFAULT_MAP_ID` (TeleportData fallback; also the Studio default with no `KN_MapOverride`).
  Evidence: match boot with no override → `Run started - map 'greenhollow'`; Lobby boots 5/5, Quick Play enqueues.
- **ENGINE GAP FIXED — units were immortal.** `acquireTarget` never considered units and nothing ever reduced
  `u.Hp`, so the unit death path was unreachable (that is why "no knight ever died"). Spec §11.6 says standard
  ("Nearest") enemies take the nearest Building/Unit/Champion within aggro radius. Now: `Types.UnitTarget`,
  `TargetRef.Kind` gains `"Unit"` + `Unit` field; EnemyService scans `UnitService:GetActiveUnits()` (flat, no
  alloc) in the Nearest block and refreshes/drops dead unit targets; CombatService `EnemyAttack` → `UnitService:Damage`,
  exploders → `UnitService:DamageInRadius`. Siege/Flying/Castle-priority enemies still ignore units.
  **Changes difficulty** — needs Omar's playtest. Evidence: `[Unit] knight #2 died - respawn in 14s`; sampler
  `94s 3/1 → 106s 4/0` (death→park→respawn ≈ 12–14 s).
- **Ruling (Omar): units die with their building.** `BuildService:OnDestroyed` → `UnitService:OnBuildingDestroyed`
  (whole squad dead, `RespawnAt = math.huge`, garrison `Suppressed`). `SetGarrison` on rebuild clears it
  (`RespawnAt = 0`); `RestoreAll` skips suppressed garrisons. `SetGarrison` now tops up by **record count**,
  not alive count (counting the living would have spawned duplicates beside dead records). Evidence:
  `[Unit] bar_01 destroyed - 3 unit(s) fell with it`, sampler held `0/4` for the rest of the night.
  **Not yet seen live: the morning return** (castle fell the same night in all 3 tests).
- **Correction:** this handoff previously said "spec Phase 4 = monetization". Wrong — spec §30 Phase 4 is
  **Meta, collection and lobby**; monetization is **Phase 6**. Phase 4 scope proposal sent to Omar (§7B.1).

**Continued the same day — Phase 4.1 run rewards + Building Batch B1**
- **Publish confirmed live** by Omar's F9 screenshot: `[Enemy] models: archer_e, ogre, pikeman, racer, ram, slime,
  swordsman, wasp, weakling` / `[Unit] models: archer, knight`.
- **Omar's choices:** Phase 4 starts with **4.1 run rewards**; ChatGPT's track = **building models**.
- **Correction:** spec §30 Phase 4 = meta/collection/lobby; monetization is Phase 6.
- **ProgressionService (new, strict, Match manifest):** `ComputeCrowns`, `ComputeXp`, `ApplyXp` (Xp = progress within
  the level; loops level-ups; cap 40), `AddXp(player, n)` (for challenge claims later), `GrantRunRewards(player, ctx)`
  → adds Crowns/XP, writes `profile.Data.LastRun: Types.RunReward` (Seen=false), logs economy Source.
  `MatchService.endRun` builds the ctx (map, won, nights, team champion kills, buildings standing incl. castle,
  tier, player count), grants per player before the save, and fires `Match_Rewards` to each player.
  Leavers before run end are not paid (not on the server).
- **Lobby results screen (§18.2):** reads `LastRun` from the PROFILE (not TeleportData — shared, client-reachable,
  lost on failed teleport). `Lobby_State.Results` while unseen; `Lobby_ResultsSeen` (idempotent) marks it seen.
  LobbyController panel: VICTORY/DEFEAT, map + nights + tier, Crowns count-up, XP bar tween, LEVEL UP, CONTINUE.
  Top bar now `LV n - won/played`. Match HUD toast: `+N CROWNS +M XP (…)`.
- **Evidence:** loss after 1 night = `+128 crowns, +12 xp` (100+25+3); win = `+428, +160, L1->L2`, XpAfter 52 =
  bar 0.1705 (52/305). Results show once; after CONTINUE + rejoin → hidden; double-fire no-op. Screenshots
  checked (fixed: unreadable PanelLight text, panel overlapping PLAY/tier button). Match 15/15 services, Lobby 5/5.
- **Not built in 4.1 (deliberately):** next-unlock teaser (needs the shop, 4.2), mutator/pass multipliers
  (systems don't exist), map select by `UnlockLevel`. `DifficultyMult` is now LIVE (crown multiplier).
- **Building Batch B1 (ChatGPT) — 11 files accepted 0/0** with new validator building rules; imported with the new
  `kn_import_building.py --bundle` (2 bundles: 145 + 126 parts). In a real match: castle L1, tower L1, house L1→L2
  render on their pads (base Y 0.70 = pad centre, pad top 0.90). **TowerService muzzle** now = imported model
  height − 1.5 → live shots at Y 14.2 (tower deck) / 15.2 (castle). Feedback sent: palette washes to near-white in
  Studio lighting; castle not distinct enough from tower from above → B1 v2 colour pass, then B2 (Barracks,
  ArcheryRange, Mill).
- **B1 v2 (colour pass + castle keep caps) and B2 (Barracks, ArcheryRange, Mill) — 20/20 accepted 0/0**, imported
  in 4 bundles. **TowerService muzzle rule changed:** fire 0.5 above the top of the part named `...FiringDeck`
  (fallback: model height − 1.5), because castle v2's caps sit above the deck. Live shots: castle 15.7, tower 14.7.
  Match: castle v2, barracks + 4 knights, tower v2, night 2 survived, clean. Every enemy/building used by
  Greenhollow and Ashridge now has a model. ChatGPT is idle pending Omar's next track (B3 buildings, 6 enemies,
  heroes, or Frostmere).
- **Phase 4.2 — Crown shop + loadout (§19), Omar approved the existing Config prices and "a champion includes its
  signature weapon".** `ShopService` (new, strict, Lobby manifest): `Buy(player, kind, id)` → (ok, reason): unknown /
  Owned (idempotent) / LevelLocked (`UnlockLevel`, champions have none = 1) / NotEnoughCrowns, then pay-before-grant,
  champion grants `DefaultWeapon`, economy Sink logged. `Equip` = ownership check in the owned map. Remotes
  `Shop_Buy`, `Loadout_Equip` (Guard.keyOf kind + id, rate-limited) → `Shop_Result(kind,id,ok,reason)` + state push.
  Perks/castle skins NOT sold (no gameplay). LobbyService state adds `OwnedChampions/OwnedWeapons`; Weapons and
  Champions kiosk pads get a client-only "OPEN" ProximityPrompt (attr `KioskType`). `ShopController` (new, strict,
  Lobby manifest): SHOP button (hidden on first run), panel with Champions/Weapons tabs, cards EQUIPPED / EQUIP /
  LEVEL n / BUY cost, toasts. Results screen gained the S18.2 teaser ("You can now unlock X!" / "Next unlock: X - N to go").
- **Evidence:** refusals LevelLocked/NotEnoughCrowns/Owned/NotOwned; garbage ids dropped silently; equip via the real
  UI button → match spawned `Ranger - … greatsword` (loadout honoured); after 2 wins (L3, 2411) teaser showed
  "You can now unlock the War Spear!"; **same-frame double Shop_Buy → one charge (2411 → 1411), second = Owned**;
  E at the Champions kiosk opened the shop on that tab. Lobby 6/6 services + 2 controllers, Match 15/15. Screenshots
  checked. **Not exercised:** buying a champion (test account can't afford 4,000+), so the weapon bundle is code-read only.
- **Map_Frostmere v1 (ChatGPT) accepted 0/0**, imported 253/253 (2 chunks), game validator 0 errors, 3 lanes,
  castle at **(0, 50)** (first map whose castle isn't at the origin; nothing broke). **Waves approved by Omar as
  written** → `Config.Maps.frostmere` (8 nights, 24→82 solo, StartGold 6, UnlockLevel 6, DifficultyMult 1.4,
  HeroLevelCap 3, TargetSeconds 500); per-night totals/entry counts cross-checked against `chatgpt-out/waves/frostmere.lua`.
  Undefended solo: night 1 = 72 s, castle fell 34 s into night 2 (expected undefended); loss paid 180 = 129 × 1.4.
  **Not reachable live:** PLAY always launches `DefaultMapId` (greenhollow); a map-select is needed (UnlockLevel gate).
  ChatGPT then assigned **GoldMine/L1** (≤ 9×9, ≤ 30 parts; validator updated).
- **GoldMine/L1 (ChatGPT) accepted 0/0** (29 parts), imported, built on Frostmere `gol_01` in a match (base 0.70, top 6.50).
  All placed building types and all enemies on the three maps now have models.
- **Omar published both places** after Phase 4.2 + Frostmere (shop, rewards, B1 v2/B2, Frostmere data — Frostmere is not
  reachable live without a map picker). He played Frostmere in Studio: lost night 2, thinks it was his play.
  **He published with `KN_PlaceKindOverride="Match"` / `KN_MapOverride="frostmere"` still set** (he ran the setup
  line but not the clear line — the Command Bar prints nothing, so he thought nothing happened). Harmless live
  (both are `IsStudio()`-guarded); cleared in Studio afterwards. Next publish carries the cleared state.
- **Lobby map picker (Omar's choice, 2026-10-14).** `Config.Matchmaking.CampaignMaps = {greenhollow, ashridge, frostmere}`
  (list only, no numbers); new `Shared/Util/MapAccess` (List / IsCampaign / UnlockLevel / Check(level, mapId)) used
  by both sides. `LobbyService`: session-only `selectedMap[player]`, remote **`Lobby_SelectMap`** (Rate 4/Burst 8,
  Guard.keyOf + MapAccess.Check, refusal → Lobby_Result toast + state push), `GetSelectedMap` (first run always
  DefaultMapId), RequestPlay re-checks the level at play time, state carries `SelectedMap`. `MatchmakingService`:
  **one MemoryStore queue per map** (`KN_QuickPlay_v1_<mapId>`), `queuedMap`, assemble per waiting map, Enqueue
  re-checks the level, Quick Play uses the picked map. `LobbyController`: `< MAP - n nights - Difficulty >` row at
  Y 0.575 (hidden on first run, while REJOIN shows, and while the results panel is up); arrows browse locked maps
  too ("FROSTMERE - LOCKED: LEVEL 6", red; PLAY greys and tapping it/Quick Play toasts the reason without a server
  call). Toast moved to Y 0.48. **Verified in Studio (L3 profile):** Lobby_SelectMap frostmere → "Reach level 6 to
  play Frostmere." and selection unchanged; ashridge → state `sel=ashridge`; "map_hax" / 123 ignored; Quick Play →
  `joined the Quick Play queue for 'ashridge'`; PLAY → `[Party] ALTRA77 -> match place, map 'ashridge'` (403 =
  Studio teleport block); UI Next → locked label, PLAY tap → toast; results panel hides the row, CONTINUE restores
  it. Lobby 6/0 failed, no errors. Selection is per session (resets to Greenhollow on rejoin) — fine for now.
- **Lobby parties (Omar: "guarantee I'm in a party with my friends", 2026-10-14).** Root cause: no party existed —
  PLAY was solo, Quick Play = strangers, and first-run accounts only see PLAY. `PartyService` now holds per-server
  parties (`partyOf`, `offers` with 60 s expiry, kinds Invite/Request), remotes `Party_Invite/Respond/Leave/Kick/
  JoinFriend` (UserId only, rate-limited) + `Party_State/Offer/Notice`; `StartRun` from a member → refused, from the
  leader → `StartPartyRun(members)` = ONE TeleportAsync to ONE reserved server (all-or-nobody, inFlight on all).
  JOIN: server checks `IsFriendsWith` + `GetPlayerPlaceInstanceAsync` (must be LobbyPlaceId) → TeleportAsync with
  `ServerInstanceId`, TeleportData `FollowUserId`; arrival (also Roblox profile-Join via `player.FollowUserId`) sends
  the friend's party leader a "Request" pop-up. MatchmakingService refuses party members; joining a party dequeues.
  Lobby_State gains `PartyRole`/`PartySize`; LobbyController shows "WAITING FOR PARTY LEADER" / "PLAY WITH PARTY (n)",
  hides Quick Play + picker for members. New `PartyController` (PARTY button visible from the FIRST run, panel,
  pop-up) added to `Config.Places.Lobby.Controllers`. Map = leader's pick, level gate = leader's level (Claude's
  default; Omar can change). Verified: Lobby 6 services/3 controllers 0 failed; hostile inputs refused, no errors.
  **Untested with 2 real players** (Studio MCP is single-client) — first live test with Omar's friend.
- **Parties verified LIVE by Omar with his friend (2026-10-15): "the party is working".**
- **Blackfen v1 + catapult v1 (2026-10-15).** Validator exit 0 / 0 warnings; wave file parsed (not executed), totals
  match ChatGPT exactly. Omar approved header + waves as written and catapult spec stats. Imported 483/483 parts,
  70 slots, 4 spawns, 40 nodes. `Config.Maps.blackfen` (StartGold 8, UnlockLevel 10, DifficultyMult 1.6, HeroLevelCap 5,
  TargetSeconds 525, 10 nights) + `"blackfen"` in CampaignMaps. Match boot: 0 errors, 4 lanes, 10 nights, 8 gold.
  Lobby: "Reach level 10 to play Blackfen." at L3. **Catapult finding:** at spec AttackRange 90 it out-ranged all towers
  (70/75/82) and castle L1/L2 (70/80); 2 catapults deleted the castle within seconds of standing at 93/103 studs.
  **Omar: AttackRange 90 → 65** (other stats spec: 225 HP, 750 dmg / 5 s); re-measured stop ≈ 66 studs. Enemy ranged
  hits (archer_e, catapult) are instant with NO projectile visual — suggested as a later juice item.
  Catapult model v1 (ChatGPT) imported 13/13 parts, welds 12/12, pivot 0; in play: model listed, base Y 0.50 on
  ground, faces travel. Validator gained `CHAR_BUDGET["catapult"]=14`. `DebugService` Debug_Stress gained an
  enemy-id mode (`FireServer(n, "catapult")`, with ReserveExtra) for testing types `mix` skips.
- **Omar published both places after Blackfen + catapult (2026-10-15).** He wants device/live testing deferred to the end
  and development to continue.
- **Phase 4.3 daily challenges (2026-10-15).** Omar approved spec rewards unchanged and an ALWAYS-DOABLE pool (no Trial
  challenge until mutators exist; map challenge ParamPool = greenhollow/ashridge; weapon challenge = "your champion's own
  weapon"). New: `Shared/Util/DailyChallenges` (deterministic set from UTC day, Random.new(day*7919); GetSet/Find/
  DayIndex/SecondsUntilReset/StreakBonus), `ChallengeTracker` (Match manifest; team kills incl. towers/units via
  EnemyService onDeath hook, Monster-tagged kills, clean nights via MatchService morning `buildingsLost`, per-player
  BuildsMade incl. upgrades, result; one Commit per player in endRun before Save; PlayCoop counts any finished run with
  ≥2 players), `ChallengeService` (Lobby; GetView in Lobby_State `Challenges`; `Challenge_Claim` 3/5 rate, mark-then-pay,
  all-three bonus + streak, save; `Challenge_Claimed` reply), `ChallengesController` (DAILY button at 0.02/0.65, badge,
  Challenges kiosk prompt). Lobby manifest + ProgressionService, ChallengeService, ChallengesController.
  Verified: commit `survive 5/12, win_signature 1/1, no_loss 0/3`; claim +300/+120 once (2741→3041), double/incomplete/
  foreign/junk ignored; stubbed-profile run of the real Claim: streak 4→5 (1450), re-claim 0, missed day → 1 (1250),
  cap at streak 21 (1700), XP level-ups correct. Lobby 8 services / 4 controllers 0 failed.
- **Phase 4.4 heroes started (2026-10-15, Omar: "ChatGPT models the hero characters first").** Studio already has all
  12 `Config.Heroes` (spec stats) and `Config.Buildings.HeroQuarters`, but **no shipped map has a HeroQuarters slot**, so
  heroes cannot deploy until maps are patched (ChatGPT, later) — or Omar picks another deploy rule. Pipeline: validator
  + importer accept `kind:"hero"` (per-hero ceilings = top of brief §1.2 ranges, 4 colours, height 4.5–8.5 warn, id must
  be a Config.Heroes key); importer → `Assets/Heroes` (folder created). **Assigned ChatGPT batch H1** = stoneguard,
  bowcaptain, houndhandler, torchbearer, skylancer, siegebreaker, fieldmedic (COLLAB-LOG 2026-10-15). H2 = golem,
  frostwarden, firewing, lizardrider, ashenqueen. Engineering (HeroService: shards, unlock, roster, deploy via UnitService)
  needs Omar's approval of Config.Shards / level costs / roster slots before it starts.
- **2026-10-17: H1 v1 delivered and ACCEPTED** (my validator 0/0 on all 7; Commons 0 Neon/0 metal, Rares exactly 1+1;
  heights 5.5–6.9). Import scripts generated in /tmp/claude-0/kntest/h1/out (regenerate with kn_import_character.py if
  the container was reset) — **Studio was offline, so NOT yet imported**. **Omar: spec hero numbers approved unchanged;
  heroes deploy FROM THE CASTLE at night start (no Hero's Quarters / map patches).** ChatGPT assigned **H2** (golem,
  frostwarden, firewing, lizardrider, ashenqueen). Next for Claude: import H1, then build HeroService (shards roll at
  run end, unlock/level-up/roster in lobby, deploy equipped heroes at night start via UnitService) + hero UI.
- **2026-10-17/18: H2 v1 ACCEPTED + hero system (4.4) BUILT and play-tested — NOT yet published.**
  All 12 hero models in `Assets/Heroes`. New: `Shared/Util/HeroRules` (MaxLevel 5, Def, SortedIds, RosterSlots from
  `Config.HeroRosterSlots` {L1 3, L15 4, L30 5} capped by MaxHeroRosterSlots 6, Cost (unlock = ShardsToUnlock; level n =
  ceil(unlock × HeroLevels[n].ShardCostMult)), StatMult, PassiveMult, CleanRoster). ProgressionService `RollShards`
  (budget floor((8 + 2×nights + 12 win) × Difficulty.ShardMult), grants 1..4, rarity weights .55/.30/.12/.03,
  NearCompletionBias 2) → `RunReward.Shards`, log "+N hero shards". `HeroCollectionService` (Lobby): GetView in
  Lobby_State `Heroes`; `Hero_Unlock/LevelUp/SetRoster` (2/4 rate, ≤6 entries, keyOf → CleanRoster) → `Hero_Result`.
  `HeroService` (Match, after UnitService): deploys each player's cleaned roster ONCE on `MatchService.NightStarted`
  (night 1) at POST_RADIUS 16 around the castle via `UnitService:SpawnHero` (garrison, no flag; Flying lifted by
  FlightHeight); Hp/Damage × StatMult, passive Radius AND Value × PassiveMult; TagDamage → TagBonus; Taunt (EnemyService
  treats distance as 0 inside TauntRadius); Slow via EnemyService:ApplySlow; Burn BURN_SECONDS 3; Splash via SpatialGrid;
  10 Hz aura tick (UnitHeal, PeriodicNova); WallResistAt (BuildService:Damage, clamp 0–0.9); TowerRateAt (TowerService).
  `HeroesController` (HEROES button 0.02/0.75, hidden on first run, DisplayOrder 8). `Debug_GrantShards(heroId, n)` —
  Studio-only + isAuthorised. Manifests: Lobby + HeroCollectionService, HeroesController; Match + HeroService, ChallengeTracker.
  Verified: Match 17/0 failed; debug win "+30 hero shards"; unlock/level/refusals ("Need 156 more", "Unlock that hero
  first", "already have") correct; night 1 `[Hero] ALTRA77 deployed 3: torchbearer L2, golem L1, ashenqueen L1`; night 2
  (13 + 20 debug swordsmen) heroes survived and engaged; panel screenshot correct. **Not individually measured:**
  numeric passive effects (taunt/nova/burn values) — judge in Omar's playtest.
- **2026-10-18 (later): E3 v1 ACCEPTED + Phase 4.5 codex/score/leaderboards BUILT — NOT yet published.**
  E3 (bloodwing, darkwarrior, exploder, fenwraith, spiderling) arrived as `kind:"character"` in
  `chatgpt-out/characters/` — Claude's own prompt error; validator + importer now accept `character` as an enemy
  alias (Omar-approved) and CHAR_BUDGET has the 5 ceilings. All exit 0; imported; `[Enemy] models:` lists 15 (0 graybox).
  **None of the E3 enemies is in any wave** (incl. fenwraith on Blackfen) → ChatGPT assigned W1 (waves).
  Omar's 4.5 decisions: per-night score (`Config.Score` PerBuilding 10, PerKill 1, WinBonus 0.25, × map
  DifficultyMult), codex `Config.Codex` (EntryCrowns 10, PageCrowns 250, Buildings list of the 8 slot types on maps),
  per-map all-time + weekly boards (`Config.Leaderboards` CacheSeconds 90, TopN 50).
  New: `Shared/Util/Codex` (pages: Enemies = union of campaign wave EnemyIds, Buildings = Config.Codex.Buildings,
  Champions; keys "e:/b:/c:<id>", paid flags "paid:<key>" / "page:<id>" in the same `Data.Codex` table — no template
  change). `CodexTracker` (Match; enemy deaths via `MatchService:NoteKill` from EnemyService onDeath; Commit at run
  end marks enemies killed, building types with Level>0, champion played). `MatchService`: `nightKills`, morning
  score (`[Score] night N: ...`), win bonus, codex commit, leaderboard submit (campaign maps, score>0).
  `ServerScriptService/Lib/LeaderboardStore` (NOT a service): OrderedDataStore `KN_Best_v1_<map>` + MemoryStore
  SortedMap `KN_Week_v1_<map>_<week>` (week from Monday 00:00 UTC, entry TTL = week end + 1 day), **"_studio" suffix
  in Studio** so tests never reach live boards. `CodexService` (Lobby; `Codex_Claim` no args, mark-then-pay,
  `Codex_Claimed`), `LeaderboardService` (Lobby; `Leaderboard_Get(map, tab)` → `Leaderboard_Data`; shared 90 s cache,
  single in-flight fetch). `CodexController` (CODEX 0.02/0.85, viewport models, black silhouettes when unseen, Codex
  kiosk now has a prompt), `LeaderboardController` (RANKS right edge 0.85/0.45). HUD morning toast shows SCORE.
  Lobby_State gains `Codex`, `BestScores`. Manifests: Lobby + CodexService, LeaderboardService, CodexController,
  LeaderboardController; Match + CodexTracker.
  Verified: Match 18/0 failed; `[Score] night 1: 1 standing x10 + 6 kills x1, x1 = 16`; victory 16 → 20; `[Codex]
  3 new entries`; `[Leaderboard] ALTRA77 greenhollow 20 - all-time ok, weekly ok`. Lobby 11 services / 7 controllers
  0 failed; codex screenshot correct; claim +30 once (double click → one `[Codex] ... +30 crowns -> 3927`); stubbed
  real-module test: full page 350 once, re-claim 0, +1 entry 10, junk keys 0; RANKS all-time + weekly show #1 ALTRA77 20,
  "resets in 4h 20m" (correct); 4 hostile Leaderboard_Get calls → 0 replies.
  **Known limits:** score ignores the Casual/Normal/Heroic tier (Omar chose map difficulty only); heroes are not
  power-capped on campaign (`HeroLevelCap` still inert), so boards are not hero-normalised yet.
- **2026-11-02: W1 waves ACCEPTED and applied; boss co-op rule built — NOT yet published.** Omar confirmed he published
  BOTH places after 2026-10-18 (4.3 challenges, 4.4 heroes, E3 models, 4.5 score/codex/leaderboards are live).
  ChatGPT's W1 (ashridge v3, frostmere v2, blackfen v2) checked data-only with a PowerShell regex parser (no Python on
  this PC), HP from the live Config: all 26 per-night solo/4p counts + HP matched ChatGPT exactly (solo 353/418/458,
  4p peak 172). Omar approved as written → `Config.Maps.<map>.Nights` replaced via ScriptEditorService (46/53/77 entries).
  **Boss rule (Omar):** `Config.Match.CoopBossScalesHp = true`; `WaveService:ScaleEntry` returns (count, interval,
  hpScale): `Boss`-tagged entries keep the authored count + interval and scale HP by `1 + CoopEnemyScalePerPlayer ×
  (players − 1)`; `EnemyService:Spawn(defId, spawn, elite, hpScale?)`. Evidence (real module, server): Fen Wraith 1 ×
  50,000 / 67,500 / 85,000 / 102,500 at 1–4p; swordsman 10 → 14/17/21 unchanged. Match (Blackfen) 18/0 failed, 10 nights,
  night 1 `24 enemies across 2 entries`; Lobby 11/7/0 failed; codex Enemies 1/15 (was 10). Overrides cleared.
- **2026-11-02 (later): campaign hero power cap (spec §36.1) BUILT — NOT yet published.** Omar approved the spec rule with
  the existing caps (greenhollow 1, ashridge 3, frostmere 3, blackfen 5), rarity/roster uncapped, picker label + toast,
  and a board reset. `HeroRules.LevelCap(mapId)` (nil unless `MapAccess.IsCampaign`) + `HeroRules.EffectiveLevel(owned,
  mapId)`; HeroService deploys at the effective level, logs `L1 (owns L2)`, fires `Hero_Capped(cap, mapId)` (server→client
  only, no server listener) when any hero was lowered; HUDController toast `HEROES CAPPED AT LEVEL n ON <MAP>`;
  LobbyController picker `... - Heroes max Ln` (TextScaled, fits incl. Blackfen). `LeaderboardStore` → `KN_Best_v2_` /
  `KN_Week_v2_` (v1 untouched, unread). Evidence: Greenhollow `torchbearer L1 (owns L2)` + toast; Frostmere `torchbearer
  L2`, no toast; `[Leaderboard] ALTRA77 greenhollow 20 - all-time ok, weekly ok`; Lobby Leaderboard_Get → #1 ALTRA77 20;
  Match 18/0, Lobby 11/7/0 failed. Studio dev profile (`KN_PlayerData_Studio`, NOT live) now L4, 5059 Crowns.
- **2026-11-02 (later): pre-launch hardening AUDIT — report only, nothing changed.** `claude-out/AUDIT-2026-11-02-pre-launch.md`.
  29 handlers + 2 honeypots, all via `Net.onServer` (mandatory rate limit + pcall); ~380 hostile payloads on the 20 lobby
  remote/arg combos added since 2026-09 → 0 errors, 0 drift (roster restored after a legal test payload). Findings awaiting
  Omar: **B1** `EnablePerfTools` live (owner debug wins reach public boards) · **M1** `Leaderboard_Get` uncached MemoryStore
  `MyWeekly` read (quota shared with Quick Play) · **M2** profile `UpdateAsync` lacks userIds (RTBF) · **M3** no Ban ladder for
  honeypots · **L1** PLAY `ProximityPrompt.Triggered` not rate-limited (inFlight prevents harm) · **L2** `Guard.string` no
  UTF-8 check. QA gaps: 2-client co-op (heroes, 2p boss HP, cap toast), late-joiner hero deploy, mobile (deferred).
- **2026-11-02 (later): audit fixes applied — NOT yet published.** Omar: "all except bans". B1 `EnablePerfTools = false`;
  DebugService `isAuthorised` = Studio OR (flag AND owner), `toolsEnabled()` = flag OR Studio (also PerfController) →
  Studio keeps the tools. **On-device perf tests now need the flag set true for that publish, then back.** M1
  LeaderboardService per-(player,map) weekly cache, cleared on leave (433 ms → 49/50 ms). M2 DataService transforms
  return `saved, { userId }` (read-back userIds={104186776}). L1 PLAY prompt `RateLimit.check(player, "Lobby_Play", 1, 2)`.
  L2 `Guard.string` UTF-8 check. Match 18/0, Lobby 11/7/0 failed. **MCP note:** `require` of a game module from
  `execute_luau` (Server or Edit-clone) hung the bridge this session and jammed later calls until Play restarted —
  prefer real remotes / DataStore reads for verification.
- **2026-11-02: everything above PUBLISHED by Omar and verified live ("all works well").**
- **2026-11-02 (later): Phase 4.6 MOUNTS engine BUILT with placeholder models — NOT yet published.** Omar: 3 usable now
  (bay_horse default, warhorse 2500, dire_wolf 4500 = existing Config prices), all 6 modelled (Pass/Event hidden), rider
  seated + gallop bob, lobby AND match. **Design rule: the champion's height never changes** — the MOUNT is scaled so its
  saddle (reference 2.0, attr `SaddleHeight`) meets the hip (R15 `HipHeight`, R6 2), so every 3D distance check is untouched.
  New: `MountService` (both manifests; CharacterAdded → clone `Assets/Mounts/<id>`, massless/no collision, `PivotTo` then
  `Weld` "MountWeld" under HumanoidRootPart, char attr `KN_Mount`; `Refresh(player)` on equip; unowned/unknown equip →
  bay_horse), `MountController` (both; local rider plays the avatar's own `Animate.sit` anim at Action priority — waits for
  Animate + re-plays if stopped, max 3; every rider's MountWeld.C0 bobs ≤0.18 / pitches ≤3° by speed, client-only, no
  remote). ShopService kind `Mount` (only `Source="Crowns"` sold → `NotForSale`; equip → MountService:Refresh); Types +
  template `Equipped.Mount = "bay_horse"`; Lobby_State `OwnedMounts`, `Mount`; ShopController MOUNTS tab (Default + Crowns +
  owned). Placeholders in `Assets/Mounts` (KN_Placeholder; bay_horse re-imported by the importer test). Tools:
  `kn_validate.py` `check_mount` (UNTESTED here — no Python), `claude-tools/kn_import_mount.luau` + `.ps1` (tested: good file
  imported 10/10 parts 9/9 welds saddle 2.00; bad saddle refused). Evidence: Lobby 12/8/0 failed, Match 19/6/0 failed;
  saddle top = root bottom 3.23/3.23 (lobby) and 2.73/2.73 (match) on spawn, swap and swap-back; SitAnim playing; real W key
  → speed 20, bob 0.180, pitch 3.00°; buy warhorse 5059→2559, equip swaps live; refusals NotForSale / NotOwned / Owned /
  junk-id silent. **ChatGPT assigned M1 (all 6 mount models).** Studio test profile: owns warhorse, rides bay_horse, 2559 Crowns.
- **2026-11-02 (later): M1 mounts v1 ACCEPTED (ChatGPT, all 6, validator 6× exit 0).** Imported via the Luau importer
  logic (compact JSON, `notes` dropped): parts/welds exact, saddle 2.00 each; placeholders replaced. Ride test, all six via
  Loadout_Equip: scale ×1.12, `hip=3.23 saddle=3.23`, SitAnim playing; screenshots Sun Stag + Sand Lizard clean. ChatGPT
  caught a UTF-8 BOM in my example JSON (PS 5.1 `Set-Content -Encoding utf8`) → rewritten BOM-less; use
  `[IO.File]::WriteAllText` with `UTF8Encoding $false` for any JSON ChatGPT's Python reads. Studio test profile granted all
  6 mounts via an Edit-mode UpdateAsync on `KN_PlayerData_Studio` (studio store only). Not yet published.
- **Dev account note (2026-10-18):** ALTRA77 L4, 3927 Crowns (codex claimed 30; studio boards greenhollow 20); heroes stoneguard L1, torchbearer L2, golem L1,
  ashenqueen L1; roster torchbearer, golem, ashenqueen.
- **Older dev account note:** the test profile (ALTRA77) now has 3041 Crowns, L3; today's win_signature challenge claimed., Level 3, owns spear, Ranger + longbow equipped.
  `Debug_EndRun(true)` pays a full win (useful for tests; disabled with EnablePerfTools before launch).

---

## 5. Config drift from `Config_v2.luau` (all previously agreed with Omar)

- `Config.TagStackingIsMultiplicative = true` (replaced an invented `Config.TagPriority`)
- `Magic.Flying` lowered `1.2 → 0.8` — balance ruling made with Omar
- Added: `LobbyPlaceId` (now `109425409417963`), `MatchPlaceId` (now `137014900347575`), `Places`,
  `GetPlaceKind`, `WallBlockRadius = 26`, `Projectile`, `Unit`, `Data`, `Debug`, `Camera`,
  `Graybox`, `Maps.graybox`, `Matchmaking`
- `Config.Matchmaking`: `PollSeconds=3, WaitSeconds=15, SoloSeconds=30, QueueTtl=120,
  RejoinTtl=1200, RejoinWindowSeconds=300, MaxPartySize=4`
- **`Config.Graybox.Sizes`** gained Mill, Field, GoldMine, Harbour, Blacksmith, RoyalForge, Temple
  *(2026-10-13, approved by Omar)*. Presentation only.
- **`Config.GetPlaceKind`** gained the Studio-only `KN_PlaceKindOverride` branch *(2026-10-13)*.
- **`Config.Maps.ashridge`** *(2026-10-13, approved by Omar as written)*: ChatGPT's 8-night table,
  `Model="Map_Ashridge"`, StartGold 3, plus the inert UnlockLevel 3 / DifficultyMult 1.2 / HeroLevelCap 3
  / TargetSeconds 450.
- **`Config.Maps.frostmere`** *(2026-10-14, ChatGPT's table approved by Omar as written)*: 8 nights, StartGold 6,
  UnlockLevel 6, DifficultyMult 1.4, HeroLevelCap 3, TargetSeconds 500, Model="Map_Frostmere".
- **`Config.Maps.blackfen`** *(2026-10-15, ChatGPT's table approved by Omar as written)*: 10 nights, StartGold 8,
  UnlockLevel 10, DifficultyMult 1.6, HeroLevelCap 5, TargetSeconds 525, Model="Map_Blackfen".
- **W1 waves** *(2026-11-02, Omar approved ChatGPT's tables as written)*: `Config.Maps.ashridge/frostmere/blackfen.Nights`
  replaced (E3 enemies introduced; Fen Wraith = Blackfen night-10 boss). Headers unchanged.
- **`Config.Match.CoopBossScalesHp = true`** *(2026-11-02, Omar)*: bosses keep their count in co-op; HP scales instead.
- **`Config.Places`** *(2026-11-02, Phase 4.6)*: `MountService` + `MountController` in BOTH manifests. `Config.Mounts`
  unchanged (prices as in Config, approved). `Config.Debug.EnablePerfTools = false` (audit B1).
- **`Config.Enemies.catapult.AttackRange` 90 → 65** *(2026-10-15, Omar)* — at 90 nothing built could shoot back.
- **`Config.Challenges`** *(2026-10-15, Omar)*: rewards = spec; pool entries gained `Id`; win_trial commented out;
  CompleteMap uses `ParamPool={greenhollow, ashridge}`; UseWeapon = champion's own weapon. Places: Lobby + ProgressionService,
  ChallengeService, ChallengesController; Match + ChallengeTracker (before MatchService).
- **`Config.Matchmaking.CampaignMaps`** = greenhollow, ashridge, frostmere, blackfen (picker order; no numbers).
- **`Config.Graybox.EliteModelTint = 0.35`** *(2026-10-13, approved by Omar)*: how far an elite
  character model's part colours lerp toward `EnemyElite`. Scale reuses `EliteScale` 1.35.
- **`Config.Matchmaking.DefaultMapId = "greenhollow"`** *(2026-10-14, Omar approved moving live PLAY to
  Greenhollow)*. Not a balance number.
- **`Config.Progression`** *(2026-10-14, approved by Omar as the spec's numbers)*: BaseCrowns 100, CrownsPerNight 25,
  WinBonus 200, CrownsPerBuilding 3, CrownsPerTenKills 2, CoopCrownBonusPerPlayer 0.10, XpPerNight 12, XpWinBonus 100,
  MaxLevel 40, `XpForLevel(n) = floor(120·n^1.35)`.
- **`Config.Places.Match.Services`** gained `ProgressionService` (before MatchService). **`Config.Places.Lobby`** gained
  `ShopService` and the `ShopController` controller (Phase 4.2). Shop prices = the existing `UnlockCost`/`UnlockLevel`
  in Config.Weapons / Config.Champions, approved by Omar 2026-10-14 unchanged.
- **`Config.Match.ResultsSeconds = 8`** *(added 2026-09-14, **approved by Omar 2026-10-13**)* —
  how long Victory/Defeat sits on screen before the return teleport. §25 says a victory must never
  auto-dismiss, so this is deliberately generous; it becomes the fallback timeout once the Phase 4
  results screen owns its own dismissal.

---

## 6. Hard-won gotchas — do not relearn these

1. **`execute_luau` has its own ModuleScript require cache.** Requiring a service there returns a
   *second* instance with separate state, and a freshly edited Config reads **stale**. To verify
   live state: read replicated state, use real remotes, parse `.Source` as a string, or create a
   temporary server-side `Script` (which *does* share the bootstrap's cache).
2. **`ReserveServer` returns HTTP 403 in Studio** — a known Studio limitation. `TeleportAsync` is
   equally unusable there. Teleports only work live. MemoryStore *does* work in Studio, so
   queue/assignment/rejoin mechanics are all testable; only the hops are not.
3. **`script_grep` does not see server scripts while in Play mode**, and its reported line numbers
   do not always match `script_read`. Parse `.Source` when the exact line matters.
4. **`script_read` ignores line-range arguments on large files** and dumps the whole file. Parse
   `.Source` via `execute_luau` for targeted reads of big modules like Config.
5. **`screen_capture` does not composite BillboardGuis.** Verify by property inspection and
   `WorldToViewportPoint`.
6. **Studio throttles unfocused rendering to a fixed 15 fps.** Client FPS is unmeasurable via
   MCP — this is exactly why the on-device perf overlay exists. Do not report a perf emergency
   from a Studio fps reading.
7. **`character_navigation` returns Success but does not move the character.** Set the character
   CFrame client-side instead.
8. **`SetNetworkOwner(nil)` throws on anchored parts.** Spec §26.2 rule 2 and §11.1 rule 1
   contradict each other; §26.2 should read "every **unanchored** server-driven part". *Flagged,
   not yet corrected in the spec file.*
9. **Forward-reference bugs have bitten four times** (`retireCoin`, `buildUpgradeModal`, `recover`,
   and pre-empted again for `clearRejoinRecords`/`returnAllToLobby`). A `local function` declared
   lower in a chunk is not in scope above it and silently resolves to nil at runtime. Audit
   declaration line vs. use lines before testing.
10. **Test-methodology trap (the single biggest recurring mistake):** never use `GetActive()[1]` or
    index-based lookups into a live simulation while the spawner is running. Track by monotonic
    `Id` and verify `DefId`. For abilities, read the server's own reported `hits` count.
11. Long-string delimiter collision: `state.Slots[entry[1]]` contains `]]` and closes a `[[ ]]`
    probe string early. Use `[==[ ]==]`.
12. Temporary probe Scripts created at runtime vanish when Play stops — no cleanup needed, but
    confirm `ServerScriptService` is back to `Script:Server, Folder:Services` afterwards.
13. **A skipped service is never even `require`d.** The bootstrap skips non-manifest modules before
    the `require`, so a Lobby boot proves *nothing* about MatchService. To syntax-check a
    non-manifest module, require it by hand from a probe Script — `pcall(require, …)` returning a
    table is a genuine syntax + scope check, and it does not call `Init`, so no remotes are created.
14. **"Publish to Roblox As…" does not reliably re-associate the open document.** After publishing
    to the Battle place, `game.PlaceId` was still the Lobby. Never trust the menu — confirm with
    `game.PlaceId` / `Config.GetPlaceKind(game.PlaceId)` before assuming which manifest will boot.
15. **Night 1 cannot kill the castle.** Six weaklings against 2000 HP; an undefended graybox run
    takes until night 4 and ~8 minutes to lose. Use `Debug_EndRun` rather than waiting.
16. **The live F9 developer console has a Client/Server context toggle for the command bar.**
    `FireServer` is client-only and fails outright in server context. Firing the remote from the
    *client* context is the only way guaranteed to reach the bootstrap's real service instance —
    a server-context `require` may hand back a second copy whose `state.Running` is false, which
    silently does nothing and looks exactly like a broken command. *(Update: in the live console a
    server-context `require` DID reach the real instance — see the 2026-09-15 session.)*
17. **Anchored root + unanchored welded children, never all-anchored.** Enemies move by setting the
    root's CFrame; a `WeldConstraint` only carries **unanchored** parts. The character brief's Part 4
    says "every part Anchored" *and* "weld everything" — that produces models that don't move.
18. **`PrimaryPart` overrides `WorldPivot`.** With a PrimaryPart set, `GetPivot` is that part's
    centre, not the model's base, so a building sinks into the ground. Buildings: no PrimaryPart,
    `WorldPivot` at the base centre. Characters: set the root's `PivotOffset` so the pivot is at
    ground level.
19. **Studio plugin capability sandbox (since ~2026-09-15).** `execute_luau` can no longer `require`
    game modules or parent a Script anywhere (`"…has additional values for the Capabilities
    property"`). Probe scripts are dead. Edit-mode creation of Parts, Models, Folders, welds, tags
    and attributes still works, as does `HttpService:JSONDecode`. The compile check is now a real
    boot via `KN_PlaceKindOverride` (gotcha 20).
20. **To test the match side in Studio**, set `workspace:SetAttribute("KN_PlaceKindOverride",
    "Match")` in Edit, press Play, and clear it after. Supersedes gotcha 14's "Publish As"
    workaround.
21. **The enemy pool is one set of generic Parts reshaped per spawn** (`Size`/`Color`/`Shape`), and
    `Pool.park` hides by `Transparency = 1` and reparenting the part. Neither works for multi-part
    models; real enemy models need per-type pools that park whole models.
22. **The battlefield is flat at `Config.Graybox.GroundY = 0.5`.** Lanes and spawns are flattened
    to Y = 0 and enemies never raycast the floor. Any terrain height in the play area breaks them.
23. **A behaviour that looks right on the graybox proves nothing about lanes.** Its lanes are
    straight lines to the castle, which is why the lane bug survived months of testing. Test enemy
    movement on a map with a bent lane.
24. **`KN_MapOverride`** — workspace attribute (Studio only) naming a `Config.Maps` id. Use with
    `KN_PlaceKindOverride = "Match"` to play any map locally. Clear both afterwards.
25. **The device bridge times out at 60 s** (the Studio call keeps running). For long measurements,
    `task.spawn` a sampler in the Client/Server datamodel that writes to a `workspace` attribute,
    then read the attribute in a later call. Never re-run a timed-out call that fires remotes.
26. **`script_grep` uses Lua patterns** — `a|b` silently matches nothing. Scan `.Source` instead.
27. **A Ball renders as a sphere of its SMALLEST axis.** Flat round patches must be Cylinders
    `[thick, d, d]` with orientation `[0, 0, 90]`. The validator warns on unequal Balls.
28. **Ready and Build are ignored outside the Day phase, silently.** Right after `Match_Morning`
    the phase is Morning: wait for Day before firing `Match_SetReady`/`Build_Request` in tests.
29. **Model enemies/units: never touch Transparency or Size on `e.Part`/`u.Part` when a model pool
    exists** — `e.Part` is the invisible root. Go through `ModelPool` (`Hide`, `Return`, `SetElite`,
    `ClearElite`).
30. **Nothing expensive in `ModelPool:Return`** — it runs inside the enemy tick (deaths, ClearAll).
    `Model:ScaleTo` there cost a 24.8 ms spike. Undo per-life state at the next `Get`/spawn instead.
31. **`Reserve(id, n)` is absolute capacity; `ReserveExtra(id, n)` is on top of what exists.** Waves use
    Reserve (a night's enemies are all parked before the next night). Debug spawners must use
    ReserveExtra — the night's own spawn threads may still be running (two warnings found this way).
32. **`Admin_SetGold` and `Admin_GrantCrowns` are HONEYPOTS.** Firing them logs your account as an exploiter.
    For test gold, play night 1 (6 gold swept at night end + 3 start = 9, enough for a 4-gold Barracks).
33. **`Build_Request` needs the champion within `BuildRange`** of the slot (server-measured), else
    `OutOfRange` silently on the client. In tests set the character's `HumanoidRootPart.CFrame` beside the slot first.
34. **Debug "mix" stress kills the castle fast** on an undefended map (40 → night 2; even 9 → night 2/3,
    because rams/ogres siege the castle). Use small counts and build towers if a test needs to reach morning.
35. **Client-side `workspace.Units` sampling sees nothing** (models not streamed/replicated as expected); sample
    unit model positions from the **Server** datamodel instead.
36. **Luau ambiguous syntax:** a statement starting with `(` (e.g. `(x :: T).Prop = v`) right after a call line is
    parsed as a call. Use a local (`local c = x:FindFirstChildOfClass(...) if c then ... end`).
37. **`palette.PanelLight` text on `palette.Panel` is unreadable** — use `palette.Text` with TextTransparency 0.25
    for secondary text.
38. **Building pads:** slot `Position.Y` = 0.70 is the pad CENTRE (pad 0.4 thick, top 0.90); buildings pivot their
    base there, 0.2 into the pad. Correct — don't "fix" it.
39. **The Studio Command Bar runs silently** — Omar can't tell a command worked. Whenever he must run one, tell him
    what visible effect proves it (e.g. "Play now starts on the snow map") and always give the clear line as a
    separate, explicit step; prefer doing attribute changes yourself via MCP when possible.
40. **`execute_luau` on the Server datamodel does NOT share service module state** — `require(Services.X)` there
    returns a fresh copy (e.g. `DataService:GetProfile` → nil though the profile loaded). Test lobby services by
    firing their remotes from the **Client** datamodel and reading Lobby_State / Lobby_Result + the console.
41. **Re-requiring an edited module in Edit mode returns the cached old copy.** Clone it INTO THE SAME PARENT under a
    temp name, `require` the clone, then destroy it (a clone with a nil parent fails — Config requires siblings).
42. **Undefended Studio test runs die to night-1 infantry in ~45–60 s** on every map, which can hide what you're
    measuring (catapult range test #2). Measure early, or measure positions/stops rather than castle HP.
43. **To test a UI panel, click it — don't force `Visible`.** Forcing a frame visible skips the controller's render
    (empty grid). `getconnections` doesn't exist in Studio. Use `user_mouse_input` with an `instance_path` like
    `LocalPlayer.PlayerGui.HeroesUI.OpenHeroes`. Screen GUIs that must cover the side buttons need DisplayOrder ≥ 8.

44. **Lobby screen layering:** a screen's OPEN button goes in its own low ScreenGui (DisplayOrder 5) and its panel in
    DisplayOrder 10 — otherwise another screen's buttons draw over the open panel (CodexButtonUI/LeaderboardButtonUI).
    Heroes still uses one gui at 8 (works because the newer panels are 10).
45. **Leaderboard stores are suffixed "_studio" in Studio.** Live boards only ever get live runs; don't "fix" it.
46. **WeldConstraints record offsets when they become active.** Clone a welded model, PivotTo its final place, THEN
    parent it. Letting a Weld snap the root on parenting leaves the children behind at the template position.
47. **The default `Animate` script stops and destroys every playing track when it starts.** Anything played at spawn
    (mount sit pose) must wait for Animate and re-play on `Stopped`.
48. **`Humanoid:Move` from `execute_luau` is reset by the ControlModule next frame** — the character never moves. Use
    `user_keyboard_input` (keyDown W … keyUp W) with a `task.spawn` sampler writing to a workspace attribute.
49. **`python`/`python3` on PATH are Store stubs, but Python 3.12 is installed** at
    `%LOCALAPPDATA%\Programs\Python\Python312\python.exe` — call it by full path (`-I` for ChatGPT files). Mount import
    still works via `kn_import_mount.ps1` → `<id>_import.luau` (JSON decoded in Studio).
50. **Studio multi-client test** = play-mode dropdown "Server & Clients" + player count; each window is its own
    `list_roblox_studios` entry (identify by focused datamodel); end with **Test → End Session**, reset dropdown to "Test".

---

## 7. Immediate next steps

**A. Omar**
1. ~~Publish~~ **DONE 2026-11-02: Omar published both places and tested live — "all works well"** (W1 waves, boss rule,
   hero cap, boards v2, audit fixes B1/M1/M2/L1/L2). Nothing Studio-only remains.
2. Paste the 2026-11-02 ChatGPT prompt (W1 accepted + hero cap FYI; ChatGPT idle pending the next track).
3. Deferred to the end (his call): device tests, defended Blackfen playtest, live challenge/hero/leaderboard playtest.

**B. Claude — next, in order**
1. ~~W1 waves~~ DONE 2026-11-02 (applied + boss co-op rule; codex Enemies page now 15).
2. 4.6 mounts: DONE 2026-11-02 — engine + ChatGPT M1 v1 (all 6) ACCEPTED and imported (no placeholders left); every
   mount `hip=3.23 saddle=3.23` seated in Studio. **PUBLISHED + verified live by Omar 2026-11-02 ("all looks good").**
   Studio test profile owns all 6 mounts (Studio store only).
2b. **FINISH-LINE PLAN (Omar 2026-11-02; memory `finish-fast-plan`):** 1 polish → 2 Endless Siege → 3 monetization →
   4 codes/event flag → 5 QA + launch. Spec numbers pre-approved; invented numbers batched per slice; audio = licensed
   partners (DistrokidOfficial music, ProSoundEffects SFX). **Slice 1 DONE in Studio, NOT published:** SettingsService
   (both; `Settings_Set` Rate 4/Burst 8, mirrors KN_Music/Sfx/ReduceEffects/BuildHints/RunsPlayed attrs; template
   Settings.BuildHints), SettingsController (SETTINGS button right column 0.85/0.56 — the top-right corner is Roblox's
   overlay and swallows taps), AudioController (both; Config.Audio ids, 0 = silent), JuiceController (match: lighting,
   music, build pop, coin tick, death sounds, castle vignette, victory sting, cosmetic enemy shots via new unreliable
   `Fx_EnemyShot` fired from CombatService:EnemyAttack when AttackRange ≥ 20), BuildHintController (§36.3),
   Config.Audio + Config.Juice, MountController honours ReduceEffects. Evidence: Lobby 13/10, Match 20/10, 0 failed;
   hint hou_01→hou_02 after building; pop 1.00→1.20→1.00; night clock 0.50; enemy arrows drawn; all 8 sounds IsLoaded;
   hostile Settings_Set values rejected. Silent slots: Coin, Nightfall, Morning, Defeat, CastleLow, Click.
   **Python 3.12 IS installed** at `%LOCALAPPDATA%\Programs\Python\Python312\python.exe` (not on PATH) — use it for
   `claude-tools/*.py`. graphify installed there too; graph in `graphify-out/` (docs + disk code only; live Luau is in Studio).
   **Slice 2 Endless Siege engine DONE in Studio 2026-11-03, NOT published:** `ServerScriptService/Lib/EndlessWaves`
   (pure Build(night, seed); budget = BaseBudget×Growth^n in HP×`BudgetHpFactor`; Unlocks table; milestone elite ogres
   every 5, Fen Wraith from night 20), `Config.Endless` extended (BudgetHpFactor 1.0 — spec says 0.05 = ~197 weaklings on
   night 1, ruling pending; MaxNights 200, MaxEntries 12, Unlocks, Milestone/Boss ids), `Config.Maps.lastwatch` (Endless,
   StartGold 8, UnlockLevel 5, DifficultyMult 1.0, **Model = Map_Blackfen stand-in**), WaveService caches generated
   nights + `ResetForRun()` (new seed per run), MatchService (MaxNights 200, `endRun(not Endless)`, leaderboard accepts
   lastwatch, snapshot `Endless`), MapAccess.List/IsEndless/IsPlayable (Endless playable, not campaign → heroes uncapped),
   HUD "NIGHT n - ENDLESS", lobby row "Endless Siege - Heroes uncapped", RANKS 5th tab. Evidence: Match 20/10 0 failed;
   night-1 wave 5 enemies across 5 entries; torchbearer L2 uncapped; score 15; defeat → +128 crowns, `[Leaderboard]
   ALTRA77 lastwatch 15 - all-time ok, weekly ok`; lobby gate "Reach level 5"; RANKS screenshot shows LASTWATCH board.
   **ChatGPT assigned L1 `Map_Lastwatch`** (4 spawns, 16 slots + castle). On delivery: validate, import, set
   `Config.Maps.lastwatch.Model = "Map_Lastwatch"`. **Omar 2026-11-03: Endless numbers KEPT as built** (BudgetHpFactor
   1.0, UnlockLevel 5, StartGold 8, Unlocks, milestones). **Slice 3 scope (Omar): CORE SET** — passes Royal Treasury, VIP
   (Treasury + name tag), Coin Magnet, Hero Collector, Stable Pass, Champion Pack, 2x XP, Auto-Ready; products 5 Crown
   bundles, Starter Pack, 2 shard packs (odds shown). Skip perk slot, skins, reroll, gifting, Private Kingdom (use Roblox
   private servers). Prices/effects = existing `Config.Monetize` (Id 0 until Omar creates them in Creator Hub).
   **Slice 3 BUILT in Studio 2026-11-03, NOT published (ids still 0):** `MonetizationService` (both manifests;
   pass ownership via UserOwnsGamePassAsync on ProfileLoaded + PromptGamePassPurchaseFinished → `Data.Passes`; one-time
   pass grants (stable_pass mounts, champion_pack champions+weapons); ProcessReceipt records PurchaseId with the grant,
   saves, NotProcessedYet on no profile / failed save, duplicate PurchaseId absorbed; lobby refresh only in Lobby place,
   pcall'd; `CrownMult/XpMult/ShardMult(data)` helpers; `DebugGrant`/`DebugSetPass` seams). Effects: ProgressionService
   crowns ×CrownMult, xp ×XpMult, shards ×ShardMult; `HeroRules.SlotsFor(data)` (+1 slot hero_collector, capped 6);
   EconomyService coin magnet ×3 radius for the owner only; VIP tag via player attr KN_VIP + `NameTagController` (both).
   `StoreController` (Lobby; STORE button right column 0.85/0.65; PASSES + CROWNS & PACKS; Id 0 → COMING SOON; shard
   odds shown; Starter Pack listed after first win until bought, auto-opens once only when RunsWon == 1). Template:
   `Passes = {}`, `StarterPackBought = false`; Lobby_State `Passes`, `StarterPackBought`, `RunsWon`. DebugService:
   Studio-only `Debug_Purchase(key, purchaseId)`, `Debug_SetPass(key, bool)`. **Auto-Ready dropped** (no ready
   confirmation exists and days have no timer → it would sell nothing). Evidence: Lobby 14/12, Match 21/11, 0 failed;
   chest twice with same id → granted once; starter → 4000 crowns, 60 shards, ranger+warhorse; passes on + debug win
   → 642 crowns (428×1.5), 320 xp (160×2), 37 shards (30×1.25); bug found+fixed (PushState on match place). Test passes
   reverted; Studio profile now 11,829 Crowns, StarterPackBought true (Studio store only).
   **Slice 4 BUILT in Studio 2026-11-03, NOT published, Lobby-tested only:** `CodeService` (Lobby; `Code_Redeem`
   Rate 0.2/Burst 1 = 1 per 5 s, Guard.string 32, upper + strip non-alnum, `Config.Codes` Expires unix (0 = never),
   RedeemedCodes recorded with the grant, shards via `MonetizationService.GrantShards` (now public), reply on
   `Code_Result(ok, msg)`, PushState). Store gets a 3rd tab **CODES** (TextBox + REDEEM, 5 s client cooldown).
   `EventService` (both places): DataStore `KN_LiveConfig` key `"Event"` (Studio reads `"Event_Studio"`) =
   `{Id="BloodMoon", Starts=unix, Ends=unix}`, polled every `Config.Events.PollSeconds`, MessagingService topic
   `KN_Event` = poll-now hint, failed read keeps last value; mirrors workspace attrs `KN_Event`/`KN_EventEnds`;
   `CrownMult()/ShardMult()` applied in ProgressionService (run crowns + RollShards); `RecordRun(data, won)` counts
   wins per window into new template field `EventProgress {Id, Ends, Wins}` and sets `Banners[bloodmoon]` at 3.
   `EventController` (both): red banner "BLOOD MOON - 2x CROWNS & SHARDS - 2d 2h left". **Not built: ForcedMutator**
   (no mutator system exists; MutatorIds always {}) and banner *display* (no banner cosmetics) — flagged to Omar.
   Evidence (Lobby): 16/16 init 0 failed, client 13/13; `"  launch "` via UI → +1,000 Crowns +40 shards; repeat →
   "already redeemed"; FREEROBUX → "doesn't exist"; number / 5000-char → rejected; 20× NIGHTFALL spam → exactly 1
   grant. Studio profile ≈13,329 Crowns, LAUNCH + NIGHTFALL redeemed. **Studio MCP dropped before stop/save** —
   confirm the edits survived (script_grep `CodeService`), and Studio key `Event_Studio` is still SET (clear it).
   **Still to verify:** Match boot (`EventService` in manifest) + a debug win with Blood Moon on → crowns ×2, shards ×2,
   EventProgress.Wins 1. **Then: Omar's 15 ids → `Config.Monetize`, test purchase, publish both places.**
   **Slice 5 PREP (cloud session 2026-11-04, no Studio):** QA checklist written to `claude-out/QA-slice5.md`
   (§31.2 twelve cases with how-to, late-joiner hero plan, slices 1–4 smoke, §31.1 command-bar config check, publish gate).
   Pointer doc for cloud sessions committed as `HANDOFF-cloud-start.md`. **Repo gaps found:** `claude-tools/`, `claude-out/`
   (audit), `chatgpt-out/` and `graphify-out/` are NOT in GitHub — Omar must commit them from the local folder before a
   cloud session can validate Lastwatch or run graphify. Lastwatch not delivered yet (COLLAB-LOG 2026-11-04 is ChatGPT's
   source-migration note only). Blood Moon decision still open; default = ship as 2x rewards only.
   `claude-out/studio-patches/2026-11-04-qa-tools/ConfigIntegrityCheck.luau` = §31.1 config checks + manifest-vs-modules
   proof for the command bar (paste, expect only the Monetize Id-0 FAILs until ids are in).
   **2026-11-04 local session (Studio):** repo now has `claude-tools/`, `chatgpt-out/`, `graphify-out/` (no cache) on
   main. QA §0 all ✅ and §4.4 ✅: slice 4 survived; Lobby 16/16 + 13/13, **Match 22/22 + 12/12**, 0 failed; Blood Moon
   debug win `+1284 crowns` (428×1.5×2), `+75 shards` (30×1.25×2), saved `EventProgress wins=1`. Cleaned up: Studio key
   `Event_Studio` removed, `KN_PlaceKindOverride`/`KN_MapOverride` nil, leftover test passes reverted (profile
   `passes=[]`, 14,613 Crowns). Checker fixed: models are looked up at `Assets.<Folder>.<id>`. Next: QA §1–§3 + §4.1–4.3, §4.5,
   §5 extras (all Studio), then Omar's IDs → publish gate §6.
   **2026-11-04 cloud session 2:** main merged; `kn_validate.py` and `graphify query` both confirmed working from a cloud
   checkout (Greenhollow/Blackfen exit 0). Lastwatch still not delivered, no ChatGPT branch. QA §8 added = exact
   cloud-validate / local-import steps for the day it lands; §4.5 got its local step. Blood Moon decision still
   unanswered (placeholder left in two prompts) → treated as 2x only.
3. ~~Hero power cap~~ DONE 2026-11-02 (spec §36.1, boards v2).
3b. Hardening audit DONE 2026-11-02 + fixes B1/M1/M2/L1/L2 applied (M3 bans skipped by Omar). 2-client Studio test DONE
    (both players' heroes capped + toast each, 2p wave scaling 6→8, morning clean). Late joiner still untested.
    How: Claude drove it via computer use (Studio is on Omar's 2nd monitor "ASUS VG24VQE"): play-mode dropdown left of
    ▶ → "Server & Clients", player count box → 2, ▶. Each window appears in `list_roblox_studios` (no name; identify
    with get_studio_state: focused Server vs Client). End with menu **Test → End Session** (start_stop_play doesn't end
    it), then set the dropdown back to "Test". Studio test accounts Player1/Player2 = UserIds −1/−2 in the Studio store.
4. Remaining model gaps: buildings Blacksmith, Field, RoyalForge, Temple (not on any map slot yet); unit `golem`.
5. Juice: visible projectiles for enemy ranged hits. Exercise the morning return of a destroyed garrison.

---

## 8. Open items

**Waiting on Omar:** live F9 `models:` lines; Phase 4 slice choice; next ChatGPT content; publish of this
session's changes; hands-on playtest (mortal units + Ashridge). Device tests deferred to the end.
**Waiting on Omar:** publish of W1 + boss rule + hero cap + boards v2; 4.6 mounts decision; hardening-pass go-ahead.
ChatGPT is idle.
**Unmeasured:** Blackfen night-10 boss clear time (TargetSeconds 525 is metadata only).
**Untested code path:** morning return of a garrison destroyed with its building. Results screen on a LIVE return teleport (Studio can't teleport).
**Inert per-map field:** only `TargetSeconds` is read by no script. `HeroLevelCap` is LIVE since 2026-11-02 (campaign
hero cap); `StartGold`, `DifficultyMult` (rewards + score) and `UnlockLevel` (map picker) are live.

**Decisions Omar still owes:**
- Map performance budget — Claude proposed ≤ ~2,500 decor parts per map; not yet approved.
- Whether to keep the v2 profile fields in the DataService template.
- ~~`Config.Debug.EnablePerfTools` must be flipped to `false`~~ DONE 2026-11-02 (Studio keeps the debug tools).

**Gameplay gaps:** `Harbour` has no gameplay (excluded in the brief); `GoldMine` pays a flat income
instead of the designed decay (§9.2).

**Known cosmetic / low priority:**
- `Config.Matchmaking.RejoinTtl` (1200) outlives `RejoinWindowSeconds` (300). Harmless.
- The Lobby place's `game.Name` is still `Place2`.
- Streaming radius can't differ per place in one document; needs a runtime set if it matters.
- Knight `RoundedHelm` is a Ball [1.7,1.7,1.6] (renders 1.6); harmless, fix on any knight v2.

**Deferred by design:** 3 Hz champion position sanity check (§13.1) · shared-gold toasts (§17) ·
LobbyPresenceService reading `LastRunSummary` (sent by the return teleport; consumed in Phase 4).

---

## 9. Suggested skills (updated 2026-11-01: a new set of Roblox skills is installed)

Call the **Skill** tool for these. The seven new skills come from https://github.com/EL4CTEO/roblox-skills (MIT).
Their `references/` files are NOT bundled; only each SKILL.md is installed.

| Skill | When | What it gives this project |
|---|---|---|
| `anthropic-skills:roblox-game-dev` | **First, every session** | Umbrella standard (golden rules, monetization reference for Phase 6). |
| `anthropic-skills:roblox-data-stores` | Leaderboards, DataService, any save path, pre-launch | Budgets: ordered writes `30 + 5×players`/min per server; MemoryStore quota `1000 + 120×CCU` units/min; RTBF (link keys to UserIds); schema `version` + migrations; **Roblox-native leaderboards** (register one OrderedDataStore in Creator Hub → player-list Global/Friends tabs). |
| `anthropic-skills:roblox-security` | Any new remote or claim; **pre-launch audit** | Validation toolkit, token-bucket rate limits, prompt/click abuse table, economy rules, Ban API ladder, place access control. |
| `anthropic-skills:roblox-testing` | Verifying a feature; QA before publishing | Feature QA checklist (late joiners, 2+ clients, leave mid-action, spam/malformed remotes, rejoin save, mobile UI). Studio Device + Network Simulator steps for Omar's deferred device tests. Jest Lua / Lune need packages → **ask Omar first** (§2). |
| `anthropic-skills:roblox-networking` | 4.6 mounts, enemy-projectile VFX juice | Server decides, clients spawn VFX; UnreliableRemoteEvent ≤ 1000 B; `GetServerTimeNow` for timers. |
| `anthropic-skills:roblox-performance` | Device/perf pass at the end; any lag report | `debug.profilebegin` labels, Scene Analysis, mobile memory targets. |
| `anthropic-skills:roblox-luau` | Writing or reviewing modules | Modern strict-Luau idioms and cleanup patterns (the codebase is already `--!strict`). |
| `anthropic-skills:roblox-architecture` | Only if a structural question comes up | **Do not migrate** to its Rojo/ProfileStore layouts: our Studio-native two-entry bootstrap and custom session-locked DataService are verified (§4) and a migration needs Omar's approval (§2). |

Do **not** reach for document/spreadsheet/deck skills: the deliverable is code inside a live Studio session.

---

## 10. State of the machine at handoff (2026-11-02; older lines below still hold)

- 2026-11-02: Studio Edit, overrides CLEARED, SSS = Server, Services, Lib. Studio-only since the last publish: W1 waves,
  `CoopBossScalesHp`, WaveService/EnemyService boss HP scaling, campaign hero cap (HeroRules/HeroService/HUD/Lobby),
  leaderboards v2. **This PC has no Python** (`python3` is the Store stub),
  so `claude-tools/*.py` cannot run here: install Python 3 (ask Omar) or use a PowerShell data parser.

- 2026-10-18 (later): Studio Edit mode, workspace overrides CLEARED. Match boots 18 services / 0 failed; Lobby 11 / 7
  controllers 0 failed. Assets: Heroes 12, Enemies 15. New folder `ServerScriptService/Lib` (LeaderboardStore).
  Studio-only since last publish: daily challenges, heroes, E3 models, score/codex/leaderboards.

- Studio: Edit mode, Lobby-associated document. `ServerScriptService` = `Script:Server, Folder:Services`. All workspace
  attributes cleared; no preview folders. Match boots 15/0 failed (Greenhollow default); Lobby 5/0 failed.
- `ServerStorage/Maps` also has **Map_Frostmere v1** (253 parts) and **Map_Blackfen v1** (483 parts); `Config.Maps` = graybox,
  greenhollow, ashridge, frostmere, blackfen. `Assets/Enemies` now includes **catapult v1** (10 enemy models).
- `Assets/Buildings` = Castle v2, House v2, Tower v2, Wall v2, Barracks v1, ArcheryRange v1, Mill v1 (all levels,
  KN_Import). Enemies 9, Units 2.
- **Last confirmed publish: Batch 2 characters.** Studio-only since: DefaultMapId; unit targeting + death with
  building; ProgressionService + Config.Progression + manifest; MatchService rewards; LobbyService results;
  LobbyController results panel; HUD reward toast; TowerService muzzle; Types (UnitTarget, RunReward, LastRun);
  B1 building models; B1 v2 + B2 models; TowerService FiringDeck muzzle; ShopService, ShopController, LobbyService
  shop state + kiosk prompts, LobbyController teaser; **lobby parties** (PartyService party block, PartyController, Lobby manifest); **map picker** (Config.Matchmaking.CampaignMaps, MapAccess,
  LobbyService Lobby_SelectMap, MatchmakingService per-map queues, LobbyController picker row). All modules `--!strict` (checked).
- `claude-tools/`: kn_validate.py (+ building rules incl. B2 budgets), kn_import_building.py (new), README updated.
- `chatgpt-out/buildings/`: B1 v2 + B2 v1 processed (20 files). ChatGPT working on Map_Frostmere v1 + waves.

---

## 11. Working with Omar (carry these forward)

- He is not a programmer-by-default: whenever he must act (publish, Creator Hub, live tests), give
  exact numbered steps. Publish = `Alt+P` (Lobby), then **File → Publish to Roblox As… → Kingdom
  Nights — Battle**. Both places, every time.
- Map design and 3D modelling are **ChatGPT's** job; Claude imports and wires them. Both work through
  this folder. ChatGPT reliably logs honest validator output and flags tool bugs — check its claims
  and credit it when it is right.
- After every step: append a COLLAB-LOG entry for ChatGPT (what changed, how, mistakes it can fix —
  including Claude's own — what it did well, what to do next and to keep logging), then give Omar a
  ready-to-paste ChatGPT prompt.
- Ask before: any Config number, publishing, deleting things this session didn't create, Phase 4.
- When the chat gets long, write a full handoff (this file) + start prompt, and refresh the Project
  copy `claude/HANDOFF-kingdom-nights.md`.

## 12. Start prompt for the next chat

> /anthropic-skills:roblox-game-dev You are the lead engineer on Kingdom Nights (Roblox), continuing from a previous chat.
> Work through the Roblox Studio MCP (call list_roblox_studios for the studio_id; it changes every session) and the
> project folder `X:\Documents\Thronefall Roblox` (if it is your working directory, use it directly; otherwise use
> device_stage_files / device_commit_files with expectedMtimeMs). If Studio or the folder is not reachable, tell me
> exactly what to open or connect, then wait.
> 1. Read the handoff first. The Project copy `claude/HANDOFF-kingdom-nights.md` is the newest (2026-11-01: §9 skills,
>    §12). If the folder copy lacks the 2026-11-01 §9, write the Project copy to the folder. Read §2 rules, §3 place IDs,
>    §4 from "2026-10-17/18" on, §6 gotchas 1–45, §7–§11. Then COLLAB-LOG from Claude's "2026-10-18 — Claude: E3 ACCEPTED"
>    entry on, plus anything newer. Read spec sections only when a task needs them.
> 2. Ask me: did I publish both places after 2026-10-18 (challenges, heroes, E3 models, score/codex/leaderboards)? Has
>    ChatGPT delivered W1 (E3 enemies in the waves)? Device/live tests stay deferred to the end.
> 3. Then §7B in order: W1 waves (parse, never execute; validate with python3 -I; I approve before Config.Maps),
>    then ask me about 4.6 mounts and the campaign hero power cap. Also propose a pre-launch hardening pass using
>    roblox-security + roblox-data-stores + the roblox-testing QA checklist. Ask before starting it.
> 4. Load the §9 skills that fit each task (roblox-data-stores for leaderboard/save work, roblox-security for any new
>    remote, roblox-testing before calling a feature done, roblox-networking for mounts/VFX).
> 5. Follow §11: step-by-step guidance for me, a COLLAB-LOG entry plus a ready-to-paste ChatGPT prompt after every step,
>    ask before any Config number / publish / delete / package install / new Phase 4 slice, keep the handoff + Project
>    copy updated, clear KN_PlaceKindOverride / KN_MapOverride after every test.
> 6. Be efficient: console evidence for every claim, no repeated reads, compact batch imports, test UI by clicking
>    (user_mouse_input instance_path), long measurements via task.spawn + attributes (60 s bridge timeout).
