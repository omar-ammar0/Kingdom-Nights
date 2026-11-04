# Kingdom Nights — Slice 5 QA checklist (pre-launch)

Written 2026-11-04 by a cloud Claude session from spec §31 and HANDOFF §4/§7. **Everything here runs in Roblox Studio
on Omar's PC** (local session or Omar by hand). Tick boxes in place and paste evidence lines under each block; this file
is the launch record. Rule from HANDOFF §2: never report a case done without console-clean evidence.

Places (HANDOFF §3): Lobby `109425409417963`, Match `137014900347575`, one Studio document, `Config.GetPlaceKind`
picks the manifest. Boot baselines to expect (0 failed every time): **Lobby 16/16 init, client 13/13**;
**Match 21/11** (+ `EventService` once slice 4 is confirmed in the Match manifest).

Test hooks that already exist (Studio-only, DebugService): `Debug_EndRun`, `Debug_Purchase(key, purchaseId)`,
`Debug_SetPass(key, bool)`, `Debug_GrantShards`, `Debug_Stress`. Multi-client = gotcha 50 (play-mode dropdown
"Server & Clients", player count, end with **Test → End Session**, dropdown back to "Test"). Studio test accounts
Player1/Player2 are UserIds −1/−2 in the Studio store.

Legend: ☐ not run · ✅ pass · ❌ fail (open a numbered bug under §7) · ⏭ skipped (say why).

---

## 0. Pre-flight (do first, in this order)

| # | Check | Expect | Status |
|---|---|---|---|
| 0.1 | `script_grep CodeService` and `script_grep EventService` | Both found: CodeService in Lobby manifest, EventService in **both** manifests (slice 4 was built but Studio MCP dropped before save) | ✅ 2026-11-04 local: Config L1010 Lobby `CodeService, EventService`, L1029 Match `EventService`; ProgressionService hooks present |
| 0.2 | Boot Lobby, boot Match | Baselines above, 0 failed, no red in Output | ✅ Lobby 16/16 init (14 started), client 13/13, 0 failed. **Match 22/22 init (17 started), client 12/12, 0 failed** — new Match baseline (EventService + EventController added) |
| 0.3 | Studio `KN_LiveConfig` key `Event_Studio` | Still set from 2026-11-03. Leave it set for §4.4, **clear it at the end** (see §6) | ✅ was set (`[Event] flag now BloodMoon …` on both boots); **cleared** after §4.4 (RemoveAsync → GetAsync nil) |
| 0.4 | Workspace attribute `KN_PlaceKindOverride` | Note current value; must be cleared before publish (§6) | ✅ was `Lobby`; **cleared** (and `KN_MapOverride` nil) |
| 0.5 | `Config.Monetize` ids | Record how many are still `0`. Store shows COMING SOON for each 0 | ✅ recorded: **21 at 0** = the 15 launch items + 6 not sold at launch (checker counts every entry) |
| 0.6 | `EnablePerfTools` | `false` (audit fix B1). Only flip true for the device pass build, then back | ✅ checker `flags` section clean |

---

## 1. Spec §31.2 manual pass list (12 cases)

Run in the Match place unless the Case says Lobby. One client unless "2p".

| # | Case (spec) | How to run it here | Expect | Status |
|---|---|---|---|---|
| 1.1 | Build with insufficient gold | Day 1, pick a Tower slot costing more than the StartGold | Server silently rejects; client toast "not enough"; gold unchanged | ☐ |
| 1.2 | Build from 200 studs away (exploit) | From the client command bar fire the build remote for a slot >200 studs from the champion | Server rejects (distance guard); no building; no gold charged; no error in server Output | ☐ |
| 1.3 | Two players build the same slot simultaneously (2p) | Both clients fire build on one slot in the same frame (command bar on both, or `task.defer` both) | Exactly one building; other client gets "AlreadyBuilt"; gold charged once in total | ☐ |
| 1.4 | Castle destroyed | Let a night overrun the castle (or `Debug_EndRun` as defeat) | Defeat state → results screen; Crowns still awarded (log `+N crowns`); profile saved | ☐ |
| 1.5 | All players downed | Stand in the lane at night until HP ≤ 0 (solo counts as "all") | Night continues; towers/units keep fighting; DOWNED ghost + ring; auto-revive at castle after `DownedSeconds` (12); **not** a loss | ☐ |
| 1.6 | Host leaves in lobby party (Lobby, 2p) | Player1 hosts party, Player2 joins, Player1 leaves | Player2 becomes host; party UI updates; no orphaned party; no error | ☐ |
| 1.7 | Player leaves mid-run (2p) | Player2 leaves during night 2 | Run continues; Player2's units/buildings remain; Player2 gets no rewards; wave scaling adjusts next night; no leaked state in server Output | ☐ |
| 1.8 | Claim the same challenge twice rapidly (Lobby) | Fire the claim remote twice back-to-back for one completed challenge | Granted once; second returns already-claimed; balance +reward exactly once | ☐ |
| 1.9 | Buy a weapon with exactly enough Crowns (Lobby) | Set Studio profile Crowns to the weapon's price (DebugService or data edit), buy | Succeeds; balance exactly 0; weapon in roster; `Lobby_State` pushed | ☐ |
| 1.10 | Rejoin immediately after a run | Finish a run, return to Lobby, stop, start play again within seconds | Profile loads at once (no session-lock stall, no `NotProcessedYet`-style wait); Crowns from the run present | ☐ |
| 1.11 | Day AFK | Do nothing during a day | Auto-ready after `Config.Match.AfkSeconds` (180 in Config_v2; confirm live value); night starts; **flag if live value differs from spec's 300** | ☐ |
| 1.12 | Flying enemy vs Warden | Frostmere/Blackfen night with flyers near a Warden | Warden deals 0 to flyers; visible "can't hit" feedback; flyers still die to archers | ☐ |

Evidence to paste per case: server Output lines (wrap in a code block), screenshot name if UI, profile numbers before/after.

---

## 2. Late-joiner hero test plan (open gap since 2026-11-02; HANDOFF §7 3b)

Heroes deploy at `HeroRules.EffectiveLevel(owned, mapId)`: capped on campaign maps (greenhollow 1, ashridge 3,
frostmere 3, blackfen 5), uncapped on Endless (lastwatch). `Hero_Capped(cap, mapId)` fires server→client once per
player when any hero was lowered; HUD toast `HEROES CAPPED AT LEVEL n ON <MAP>`. Setup: Studio profile owns at least
one hero above L1 (dev profile is L4 with torchbearer L2).

| # | Scenario (2p, "Server & Clients") | Expect | Status |
|---|---|---|---|
| 2.1 | Player2 joins the Match server during **Day 1** after Player1 is already playing (start with 1 player, add the 2nd via the test dropdown or a second window) | Player2's champion spawns at the castle; their heroes deploy at the effective level (`L1 (owns L2)` style log); Player2 gets its own cap toast; Player1 does **not** get a second toast | ☐ |
| 2.2 | Player2 joins during a **Night** | Joins as living champion at castle; wave scaling for the **next** night goes 6→8 style (2p); current night unchanged; no double spawn | ☐ |
| 2.3 | Late joiner on **Endless (lastwatch)** | Heroes uncapped (owned level), no toast; HUD "NIGHT n - ENDLESS"; score shared | ☐ |
| 2.4 | Late joiner while Player1 is **DOWNED** | Player2 can revive in place (within 10 studs, 3 s hold, 50% HP) per §12.5; HUD "HOLD TO REVIVE" | ☐ |
| 2.5 | Late joiner with **no heroes owned** | No deploy, no toast, no nil error in HeroService | ☐ |
| 2.6 | Player2 leaves then **rejoins** the same run | Heroes not duplicated; prior units still theirs or correctly orphaned; rewards counted once at run end | ☐ |
| 2.7 | Blood Moon on (Event_Studio set) + late joiner | Late joiner sees the red banner immediately (attrs `KN_Event`/`KN_EventEnds` mirrored), and gets ×2 at run end | ☐ |

Pass bar for this section: every row green with server + both client Outputs clean. Record the exact deploy log lines.

---

## 3. Multi-client and co-op regression (from the roblox-testing QA list)

| # | Check | Status |
|---|---|---|
| 3.1 | 2p boss night: boss HP scaled (`CoopBossScalesHp`), both clients show the same HP bar | ☐ |
| 3.2 | Morning after a destroyed garrison: it returns correctly, no ghost units (HANDOFF §7 item 5) | ☐ |
| 3.3 | Player leaving mid-purchase prompt (Lobby): no stuck prompt state, `ProcessReceipt` not called, no leaked table | ☐ |
| 3.4 | Teleport Lobby → Match → Lobby with 2 players: profile intact both ways, `RunsPlayed` +1, leaderboard writes once | ☐ |
| 3.5 | Spam/malformed remotes (sample 5 per place from the 2026-11-02 audit list): all rejected, 0 errors | ☐ |

---

## 4. Finish-line slices 1–4 (built in Studio, never published) — smoke each once

| # | Slice | Do | Expect | Status |
|---|---|---|---|---|
| 4.1 | 1 Settings/Audio/Juice | Toggle Music/Sfx/ReduceEffects in SETTINGS, replay a night | Attributes mirror; sounds stop/start; effects reduced; hostile `Settings_Set` values rejected | ☐ |
| 4.2 | 2 Endless | Lobby level ≥5 → Lastwatch → play 6 nights | Milestone elite pack night 5; defeat → crowns + `[Leaderboard] ... lastwatch` ok; RANKS 5th tab shows it. Map is still the **Blackfen stand-in** until ChatGPT's `Map_Lastwatch` lands | ☐ |
| 4.3 | 3 Monetization | `Debug_SetPass` royal_treasury+double_xp true, debug win | Crowns ×1.5, XP ×2, shards ×1.25 (e.g. 642/320/37 pattern); `Debug_Purchase` same id twice → granted once; revert passes after | ☐ |
| 4.4 | 4 Codes + Blood Moon | Lobby: redeem a fresh test code via CODES tab, repeat, spam 20× | Granted once; "already redeemed"; rate-limited to 1 per 5 s. Match: with `Event_Studio` set, debug win → **Crowns ×2, shards ×2, `EventProgress.Wins` 1**; banner shows "BLOOD MOON - 2x ... left" | ✅ Lobby half 2026-11-03 (LAUNCH via UI +1,000/+40; repeat "already redeemed"; unknown/number/5000-char rejected; 20× NIGHTFALL → 1 grant). Match 2026-11-04: `+1284 crowns` (428 × 1.5 treasury × **2**), `+75 hero shards` (30 × 1.25 × **2**); saved profile `EventProgress = BloodMoon/1793896044/wins=1`, Crowns 13,329 → 14,613 |
| 4.5 | 4 Event poll | Clear `Event_Studio`, publish `KN_Event` message (or wait `PollSeconds`) | Banner disappears; multipliers back to ×1; failed DataStore read keeps last value (simulate by renaming key, watch no error) | ☐ key cleared, but the banner-disappears / ×1 boot not yet observed |

Blood Moon decision still open with Omar: ships as **2x rewards only** (no `ForcedMutator`, no banner cosmetic) unless
he says "build mutators". If he does, that is new slice work, not QA.

---

## 5. Automated (spec §31.1) — command bar, server context

Paste **`claude-out/studio-patches/2026-11-04-qa-tools/ConfigIntegrityCheck.luau`** into the Studio command bar with the
game **not** running. It prints one `FAIL`/`WARN` line per problem and ends with `ConfigIntegrityCheck done: N FAIL, M WARN`.
It checks every §31.1 config bullet (wave EnemyIds, Endless ids, UpgradeChoices, Damage profile × tag coverage, shop
numbers), map models and numbers, character/building model names, the **`Config.Places` manifests against real
ModuleScripts** (this is the "did slice 4 survive" proof: CodeService in Lobby, EventService + EventController in both),
Monetize ids ≠ 0, Codes/Events/Mutators shape, `EnablePerfTools == false`.

Expected before ids are in: the `Monetize ... Id is 0` FAILs (21 entries, 15 sold at launch) plus WARNs for the `lastwatch`
stand-in model, `BloodMoon.ForcedMutator` unused, and 7 known missing models (golem + 6 unslotted buildings, §7 B1). Anything else is a real finding → §7.

Also run (already exist from earlier sessions, rerun once): the map validator on every map (§23.2), the 200-enemy
`Debug_Stress` with tick time + memory flat over 60 s, and a profile round-trip (save → clear → load → equal; add a
dummy template field → reconcile fills it, nothing else changes). Paste the printed lines.

---

## 6. Publish gate (all must be ✅ before either place is published)

1. Sections 0–5 green, or every ❌ listed under §7 with Omar's "ship anyway" next to it.
2. Studio key `KN_LiveConfig/Event_Studio` **cleared**; attribute `KN_PlaceKindOverride` **cleared**.
3. `EnablePerfTools = false`. Test passes reverted (`Debug_SetPass ... false`). Studio profile is not the live profile
   (`KN_PlayerData_Studio`), so no cleanup needed there.
4. Omar's 15 Creator Hub ids in `Config.Monetize` (keys in `kingdom-nights-handoff-2026-11-03.md` step 1); STORE shows
   prices, no COMING SOON; one real test purchase of the cheapest product, then confirm the Crowns landed and the
   `PurchaseId` is in the profile.
5. Publish **both** place ids (HANDOFF §3; one document, two places). Then live smoke: join Lobby from the Roblox app,
   play one Greenhollow run to morning 2, check Output via Developer Console (F9) for red lines, confirm Crowns saved
   on rejoin.
6. Device pass (§31.3) on a mid-range Android, quality 1–3: peak-night FPS, UI readable, taps hit, join-to-playable
   time, 15 min thermal. Needs `EnablePerfTools` true for that build only, then back and republish.
7. Update HANDOFF §7 2b: "Slice 5 DONE, published <date>, both places", and write the ChatGPT-facing line in
   COLLAB-LOG only if a map or asset problem surfaced.

---

## 7. Bugs found during this pass

| # | Case | What happened | Severity | Fix / status |
|---|---|---|---|---|
| B1 | §5 checker | 36 `Model "X" not found` WARNs: the checker looked up Config `Model` names, but models live at `ReplicatedStorage.Assets.<Enemies/Units/Heroes/Buildings>.<id>` | Tooling | Fixed in ConfigIntegrityCheck.luau (looks up by id). Real gaps by id: unit `golem`; buildings Temple, RoyalForge, Blacksmith, HeroQuarters, Harbour, Field (known, HANDOFF §7 item 4; not on any map slot) |
| B2 | §4.3 / §6.3 | HANDOFF said test passes were reverted, but the Studio profile still owned royal_treasury, double_xp, hero_collector. A `Debug_SetPass false` fired during Results didn't stick | Low (Studio store only) | Reverted on a fresh boot 2026-11-04: profile `passes=[]`. Fire Debug_SetPass mid-run, not after the run ends |
| — | §5 checker 2026-11-04 | `1 FAIL, 38 WARN` before the B1 fix: FAIL = Monetize ids 0 (expected); WARN = lastwatch stand-in, ForcedMutator unused, 36 B1 false positives | — | — |
