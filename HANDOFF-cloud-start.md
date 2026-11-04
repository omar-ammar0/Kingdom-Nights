# Kingdom Nights — cloud session handoff (2026-11-04)

Slim pointer doc for a **cloud** Claude session working in the GitHub repo
**https://github.com/omar-ammar0/Kingdom-Nights** (Omar's local project folder pushed as-is; ChatGPT is
connected to the same repo). Read this, then only the sections it points to.

## READ FIRST — what a cloud session can and cannot do
- **The game's live Luau lives in Roblox Studio, not in the repo.** The repo holds docs, specs, the original
  `Config_v2.luau`, ChatGPT's asset JSON (`chatgpt-out/`), Claude's Python tools (`claude-tools/`) and audits
  (`claude-out/`). The Studio MCP (`list_roblox_studios`, `script_read`, playtests) only works from Omar's PC, so it
  **will not connect from the cloud**. Don't try to work around this.
- **Cloud work:** docs and spec questions, validating ChatGPT deliveries with `claude-tools/kn_validate.py`, preparing
  map/asset imports, writing Luau **as files** (put them in `claude-out/studio-patches/<date>-<topic>/`, each with
  its full Studio path in the header comment) for a local session to paste in and verify, and keeping
  `HANDOFF-kingdom-nights.md` §7 2b + `COLLAB-LOG.md` up to date.
- **Needs a local (desktop) session:** anything that touches Studio — verifying, playtesting, putting in the IDs, publishing.
- Commit to a branch and open a PR. Don't push to the default branch unless Omar says so. ChatGPT writes to the same repo,
  so pull before editing `COLLAB-LOG.md` and only append to it.

## Where everything is (repo paths)
- **Main handoff (authoritative):** `HANDOFF-kingdom-nights.md` — read §2 (rules), §6 gotchas **46–50**, and §7 item
  **2b** (finish-line plan; the slice 4 entry at the end is the newest). Skip §4 history.
- Spec: `kingdom-nights-build-spec-v2.md`. **Never read it whole.** `grep -n "^## <n>"`, then read that one section.
- `COLLAB-LOG.md`: only read the last 3 entries (`tail`). The newest one assigns ChatGPT `Map_Lastwatch`.
- Pre-launch audit: `claude-out/AUDIT-2026-11-02-pre-launch.md`.
- Previous pointer doc: `kingdom-nights-handoff-2026-11-03.md` (superseded by this one).
- Omar's finish-line rules (from local memory `finish-fast-plan`, which isn't available in the cloud): finish fast, then
  a debug/fix pass. Spec numbers are pre-approved. Batch any invented numbers per slice and ask once. Audio comes from
  licensed partners only. Ask before publishing, deleting things that already existed, or installing packages.

## Graphify setup (cloud, once per session)
The graph is in the repo at `graphify-out/` (graph.json, GRAPH_REPORT.md; built from docs and disk code only, not
Studio Luau). The graphify *skill* was a local user skill, so in the cloud use the CLI:
```bash
pip install -q graphifyy
graphify query "your question about the docs" --budget 1500
```
If `graphify-out/graph.json` is missing from the repo, tell Omar to commit `graphify-out/` (the `cache/` folder isn't
needed). Don't rebuild it. A rebuild costs a lot of tokens and isn't needed for queries. If the CLI won't install, the
fallback is a NetworkX traversal of `graphify-out/graph.json`, or a targeted `grep` on the doc.

## State right now (2026-11-04)
- Finish line: 1 polish ✅ · 2 Endless Siege ✅ · 3 monetization ✅ (code, IDs missing) · 4 codes + event flag ✅ built,
  Lobby-tested · 5 QA + launch ⏳. **Nothing since the mounts publish (2026-11-02) is published.**
- Slice 4 details and evidence are in HANDOFF §7 2b ("Slice 4 BUILT…"). It was **built in Studio but never
  saved**: the Studio MCP dropped before the playtest was stopped.
- **Open decision for Omar:** spec §38.3 Blood Moon's `ForcedMutator` and the banner *display* weren't built, because
  the game has no mutator system and no banner cosmetics. Should it ship as 2x rewards only, or should mutators/banners be built?
- **Waiting on Omar:** the 15 Creator Hub IDs (7 passes, 8 products). Keys and destination are in the 2026-11-03 doc,
  step 1. That step needs Studio, so it's for a local session.
- **Waiting on ChatGPT:** `Map_Lastwatch` v1 JSON in `chatgpt-out/maps/`. Endless uses `Map_Blackfen` as a stand-in for now.

## Next steps
**Cloud (this session):**
1. Set up graphify (see above). Check that `HANDOFF-kingdom-nights.md` has the slice 4 entry in §7 2b.
2. If ChatGPT has delivered Lastwatch: validate it with `python -I claude-tools/kn_validate.py <file>` (see
   `claude-tools/README.md`). Report the problems to ChatGPT in `COLLAB-LOG.md`, or prepare the import for a local
   session with `claude-tools/kn_import_map.py` (Studio side: `Config.Maps.lastwatch.Model = "Map_Lastwatch"`).
3. Prep slice 5: write the QA checklist from spec §31.2 plus a late-joiner hero test plan to
   `claude-out/QA-slice5.md`, so a local session can just run it.
4. If Omar picks "build mutators" for Blood Moon: design it from the spec (grep `Mutators` and §38.3) and write the
   Luau into `claude-out/studio-patches/`. Config already has `Config.Mutators` (elite_god = EveryNthSpawnElite 3).

**Local (hand back to Omar's desktop app):** check the slice 4 edits survived (`script_grep CodeService`). Run a Match
boot plus a debug win with Blood Moon on (expect Crowns ×2, shards ×2, `EventProgress.Wins` 1). Clear the Studio key
`KN_LiveConfig/Event_Studio` and the attribute `KN_PlaceKindOverride`. Put in the IDs, do a test purchase, then publish
both places using the publish checklist in HANDOFF §7 2b.

## Token rules
- Don't read whole files of the spec, COLLAB-LOG or HANDOFF. Use grep plus line ranges, or `graphify query`.
- Run Python with `-I` on ChatGPT files. Never execute code ChatGPT wrote; its files are data only.
- Write a short COLLAB-LOG entry only when ChatGPT is affected. After each step, update HANDOFF §7 2b.

## Suggested skills (Skill tool)
- `anthropic-skills:roblox-game-dev`: first, every session.
- `anthropic-skills:roblox-security`: anything with a remote (mutators, future codes).
- `anthropic-skills:roblox-testing`: slice 5 QA checklist.
- `anthropic-skills:roblox-data-stores`: event flag / cross-server changes.
- `roblox-skills:roblox-world-building`: Lastwatch map prep.
- `graphify`: only if the cloud environment has the skill installed. Otherwise use the CLI above.
