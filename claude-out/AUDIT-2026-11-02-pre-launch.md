# Kingdom Nights — pre-launch hardening audit (2026-11-02)

Scope: every client→server remote, the data layer (profiles, leaderboards, MemoryStore), and the roblox-testing QA
checklist. Skills used: roblox-security, roblox-data-stores, roblox-testing. **Audit only — nothing was changed.**

## Inventory

- **29 client→server handlers + 2 honeypots**, no RemoteFunctions. Every handler is registered through
  `Net.onServer`, which makes a rate limit mandatory and wraps the body in `pcall` (a malformed payload degrades to one
  warning). Server→client events (incl. the new `Hero_Capped`) have no server listener.
- Match-side handlers (Build, Combat_Ability, Upgrade, Unit rally, Ready, Heartbeat) were fuzzed in the 2026-09 audit
  (306 payloads, zero drift). This pass reviewed and fuzzed everything added since: map picker, party, shop, loadout,
  daily challenges, heroes, codex, leaderboards, debug.

## Fuzz evidence (Studio, Lobby, 2026-11-02)

20 remote/argument combinations × 19 hostile payloads (nil, NaN, ±inf, 1e308, -1, 0.5, "", a 50,000-char string,
invalid UTF-8, "__index", {}, {1,2,3}, a 60-deep nested table, NaN Vector3, an Instance, true, an EnumItem, an
8-long repeated roster), each paced at its own rate limit. Valid first argument + hostile second argument was also
tested for Shop_Buy, Loadout_Equip, Leaderboard_Get, Party_Respond.

Result: **0 handler errors, 0 warnings. Crowns, level, selected map, tier, owned heroes, shard counts unchanged.**
The only change was the roster, from a payload that was itself a *legal* roster (`golem` ×8 → cleaned to `golem`);
restored afterwards to torchbearer, golem, ashenqueen.

## What is already right (verified by reading the code)

| Area | Evidence |
|---|---|
| Validation | `Guard` rejects NaN/±inf, non-integers, wrong types; ids checked with `Guard.keyOf` against SERVER Config tables or the player's own owned map. |
| Economy | Shop: price/level from Config, pay-before-grant, repeat buy = "Owned". Challenges + Codex: mark-then-pay, idempotent, saved immediately. Heroes: shards spent before unlock/level; roster rebuilt by `CleanRoster` (only owned, no repeats, ≤ slots); client list capped at `MaxHeroRosterSlots`. |
| Teleport/party | Party remotes carry a UserId only, resolved to a Player on this server; kick requires leader; `inFlight` guard stops double teleports. Battle place = "Limited to same Universe". |
| Rally | Position clamped server-side to `RallyRadius` and flattened to ground. |
| Profiles | Session lock via `UpdateAsync` only; retries; a failed load KICKS rather than handing out a template; lock theft detected on save; schema migrations; 60 s staggered autosave; `BindToClose`; Studio uses `KN_PlayerData_Studio`, so tests never touch live profiles. |
| Leaderboards | All-time `UpdateAsync` only writes a new best; weekly sorted map with TTL; shared 90 s cache with a single in-flight fetch; `_studio` suffix in Studio; v2 restart for the hero cap. |
| Debug tools | Three gates (EnablePerfTools, owner-or-Studio, rate limit); a client can't smuggle a truthy "win"; GrantShards is Studio-only. |

## Findings

| # | Severity | Finding | Proposed fix |
|---|---|---|---|
| B1 | **Launch blocker** | `Config.Debug.EnablePerfTools = true` is live. The place owner (you) can end any run as a win — paying Crowns/XP/shards and submitting a leaderboard score — and stress-spawn enemies. Not exploitable by others, but it puts unearned scores on public boards. | Flip to `false` before soft launch (Config change — your approval). Keeps working in Studio only if we also make the Studio gate independent; I'd propose `isAuthorised` = Studio OR (flag AND owner). |
| M1 | Medium | `Leaderboard_Get` → `LeaderboardStore.MyWeekly` does an **uncached MemoryStore read on every request**. 12 lobby players at the allowed rate ≈ up to ~1,400 reads/min from one server. MemoryStore quota is experience-wide (`1000 + 120 × CCU`/min) and also carries Quick Play queues and rejoin records, so at low CCU one hostile lobby could throttle matchmaking for everyone. | Cache "my weekly score" per (player, map) for `CacheSeconds`, and refresh it on that player's own submit. No Config change. |
| M2 | Medium (compliance) | Profiles use a static key `Player_{UserId}`, but `UpdateAsync` never attaches the **userIds** metadata, so Roblox's automated right-to-erasure cannot link the keys to the user. | Return `saved, { userId }` from the load and save transforms (and the all-time leaderboard write). Data format unchanged. |
| M3 | Medium | No enforcement ladder: honeypot trips are only logged to analytics; nothing uses the Ban API. | Optional: after ≥ 3 honeypot trips, a **delayed, time-limited** ban (`Players:BanAsync`, 1 day, then 7 days via `GetBanHistoryAsync`). Needs `BanningEnabled` and your approval (it acts on players). |
| L1 | Low | The PLAY portal's `ProximityPrompt.Triggered` bypasses the rate limiter. `inFlight` prevents double teleports, but a prompt-spammer inflates the "PressedPlay" funnel step and burns analytics quota. | `RateLimit.check(player, "PlayPrompt", 1, 2)` at the top of the handler. |
| L2 | Low | `Guard.string` doesn't reject invalid UTF-8. No current handler saves a client string, so no impact today — but a future one could make a profile save fail (DataStores refuse invalid UTF-8). | Add `utf8.len(value) ~= nil` to `Guard.string`. |

## QA checklist (roblox-testing) — status

| Item | Status |
|---|---|
| Spammed / malformed remotes rejected | ✅ this audit (lobby) + 2026-09 (match) |
| Output clean (server + client) | ✅ every boot today |
| Data saves and reloads, incl. teleports | ✅ verified live 2026-09/10 (lock round trip, return teleport) |
| Leaving mid-action leaves no broken state | ✅ rejoin records, party leave, `inFlight` cleared on leave (code + live) |
| Works with 2+ clients | ⚠️ parties live-verified; **co-op heroes, 2p boss HP scaling, hero cap toast per player untested with 2 clients** |
| Late joiners | ⚠️ hero deploy for a late joiner (next night start) is code-read only |
| Mobile / gamepad / keyboard; UI readable on a phone | ⏳ deferred to the end by Omar (Device Simulator steps ready) |

The two ⚠️ items can be done in Studio without devices: **Test → Clients and Servers → 2 players** (you click, I watch the
console).

## Fixes applied (2026-11-02, Omar: "all except bans")

| # | Change | Evidence |
|---|---|---|
| B1 | `Config.Debug.EnablePerfTools = false`. `DebugService.isAuthorised` = Studio, or (flag AND owner); `toolsEnabled()` = flag OR Studio in DebugService and PerfController. | Match boot 18/0 failed; in Studio with the flag off, `Debug_Stats` still streams and `PerfOverlay` builds. Live (not testable in Studio): flag off → every debug remote refuses, no overlay. |
| M1 | `LeaderboardService` caches "my weekly score" per (player, map) for `CacheSeconds`; cleared on PlayerRemoving. | Weekly request 1: 433 ms (store reads); requests 2–3: 49 / 50 ms (no store read), mine = 20 each time. |
| M2 | `DataService` load + save `UpdateAsync` transforms return `saved, { userId }`. | Studio store read-back: `userIds={104186776}`, lock released, Crowns 5059 intact. |
| L1 | PLAY `ProximityPrompt.Triggered` → `RateLimit.check(player, "Lobby_Play", 1, 2)` (shares Lobby_Play's budget). | Lobby boot 11/7/0 failed. Code-read (prompts can't be fired through MCP). |
| L2 | `Guard.string` rejects `utf8.len(value) == nil`. | Every service requires Guard; both places boot 0 failed. Unit check not run (requiring a module from the MCP plugin hung the bridge). |
| M3 | Not applied (Omar). Honeypots still log only. | — |

**On-device perf tests (deferred):** the overlay now needs `EnablePerfTools = true` live. Flip it on for that one
publish, test, flip it back and publish again.

## 2-client Studio test (2026-11-02, Server & Clients, 2 players, Greenhollow)

Test profiles seeded in the **Studio** store only (`Player_-1`: torchbearer L2 + golem L1; `Player_-2`: ashenqueen L3;
both were empty, the seed refuses to overwrite). Server log:
`Run started - map 'greenhollow', 5 nights, 2 player(s)` → `[Hero] Player1 deployed 2: torchbearer L1 (owns L2), golem L1`
· `[Hero] Player2 deployed 1: ashenqueen L1 (owns L3)` · `[Wave] night 1: 8 enemies across 1 entries (2p scaling)` (6 → 8)
· `Morning - night 1/5` · `[Score] night 1: 1 standing x10 + 8 kills x1, x1 = 18`. Both clients showed
`HEROES CAPPED AT LEVEL 1 ON GREENHOLLOW`. Server 18/0 failed, no errors or warnings.
New-player difficulty default (Casual for RunsPlayed < 3) applied correctly to the fresh test accounts.

QA checklist update: **2+ clients ✅**. Still open: late joiner (Studio can't add a player mid-session here), mobile (deferred).
