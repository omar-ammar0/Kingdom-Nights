# Kingdom Nights — session handoff (2026-11-03)

Slim pointer doc. The full engineering record lives in the project; read only what the task needs.

## Where everything is
- Project folder: `X:\Documents\Thronefall Roblox`
- **Main handoff (authoritative):** `X:\Documents\Thronefall Roblox\HANDOFF-kingdom-nights.md`
  - Read §2 (rules), §6 gotchas **46–50** (newest), and §7 items **2b** (finish-line plan + slices 1–3 status).
  - Skip §4 history unless a task needs it.
- Collab channel with ChatGPT: `COLLAB-LOG.md` (only the last 3 entries matter; newest = Lastwatch map L1 assignment).
- Pre-launch audit + fixes: `claude-out/AUDIT-2026-11-02-pre-launch.md`.
- Knowledge graph (docs only): `graphify-out/graph.html`, `graphify-out/GRAPH_REPORT.md`. Use `/graphify query "..."` instead of re-reading big docs.
- Memory: `finish-fast-plan` (Omar's finish-line rules) is auto-loaded.

## State right now
- Omar wants the game **finished fast**, then a debug/fix pass. Finish line: 1 polish ✅ · 2 Endless Siege ✅ · 3 monetization ✅ (code) · 4 codes + event flag ⏳ · 5 QA + launch ⏳.
- **Nothing since the mounts publish (2026-11-02) is published.** Slices 1–3 are Studio-only.
- **Waiting on Omar:** the Creator Hub IDs for 7 passes + 8 products (he sent a message without them; ask him to paste). Auto-Ready pass was dropped (it sells nothing).
- **Waiting on ChatGPT:** `Map_Lastwatch` v1 (Endless map). Endless currently uses `Map_Blackfen` as a stand-in (`Config.Maps.lastwatch.Model`).
- Studio: Edit mode, no workspace overrides set. Studio id changes every session (`list_roblox_studios`).

## Next steps, in order
1. **When Omar pastes IDs:** put them in `Config.Monetize.Passes[key].Id` / `.Products[key].Id` (keys: royal_treasury, vip, coin_magnet, hero_collector, stable_pass, champion_pack, double_xp; crowns_pouch, crowns_chest, crowns_vault, crowns_hoard, crowns_treasury, starter_pack, shards_small, shards_large). Edit Config via `ScriptEditorService:UpdateSourceAsync` string replace (Config is large). Boot Lobby (`Lobby 14/12, 0 failed` expected), open STORE by clicking (`LocalPlayer.PlayerGui.StoreButtonUI.OpenStore`), check prices show instead of COMING SOON. Give Omar a test-purchase + publish checklist (both places).
2. **Slice 4:** codes (`Config.Codes`, profile `RedeemedCodes` already in template) — a `Code_Redeem` remote (rate-limited, Guard.string, case-insensitive, once per code, `Expires`) + a small lobby UI; and the server-wide event flag (`Config.Events.BloodMoon`, `PollSeconds`) — read spec §38 first (`kingdom-nights-build-spec-v2.md`, grep `## 38`). Load roblox-security before writing the remote.
3. **When ChatGPT delivers Lastwatch:** validate with Python (see below), import with `claude-tools/kn_import_map.py`, set `Config.Maps.lastwatch.Model = "Map_Lastwatch"`, boot Endless (`KN_PlaceKindOverride=Match`, `KN_MapOverride=lastwatch`), clear overrides.
4. **Slice 5:** QA sweep (spec §31.2 manual list, roblox-testing checklist), late-joiner hero test, then launch checklist + publish.

## Working rules that save tokens
- Python exists but not on PATH: `%LOCALAPPDATA%\Programs\Python\Python312\python.exe` (use `-I` on ChatGPT files).
- Never `require` game modules from `execute_luau` (hangs the bridge). Verify via real remotes, console, attributes, DataStore reads.
- Long checks: `task.spawn` + workspace attribute, read back later (60 s bridge timeout).
- Click UI with `user_mouse_input` instance paths; top-right screen corner is Roblox overlay (taps swallowed).
- Studio-only test remotes (DebugService): `Debug_EndRun(won)`, `Debug_Stress(n, id)`, `Debug_Purchase(productKey, purchaseId)`, `Debug_SetPass(passKey, bool)`.
- Always clear `KN_PlaceKindOverride` / `KN_MapOverride` after a test.
- Ask Omar before: publishing, deleting pre-existing content, package installs, invented numbers (batch per slice). Spec numbers are pre-approved.
- After each step: short COLLAB-LOG entry only if ChatGPT is affected; update `HANDOFF-kingdom-nights.md` §7 2b.

## Suggested skills
- `anthropic-skills:roblox-game-dev` — first, every session.
- `anthropic-skills:roblox-security` — slice 4 `Code_Redeem` remote.
- `anthropic-skills:roblox-data-stores` — event flag / anything cross-server (MemoryStore/MessagingService).
- `anthropic-skills:roblox-testing` — slice 5 QA sweep.
- `graphify` — answer questions about the docs instead of reading them (`/graphify query "..."`).

## Start prompt for the next session
> /anthropic-skills:roblox-game-dev Continue Kingdom Nights. Read `C:\Users\altra\AppData\Local\Temp\kingdom-nights-handoff-2026-11-03.md` first (it's short), then only the sections of `X:\Documents\Thronefall Roblox\HANDOFF-kingdom-nights.md` it points to. Keep token use low: no full-file reads of the spec or COLLAB-LOG, use `/graphify query` for doc questions. Connect to Studio with `list_roblox_studios`. Here are my Creator Hub IDs: [PASTE IDS]. Put them in Config.Monetize, verify the store, give me the publish checklist, then start slice 4 (codes + event flag).
