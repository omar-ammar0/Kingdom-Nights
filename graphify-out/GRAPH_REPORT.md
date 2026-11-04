# Graph Report - Thronefall Roblox  (2026-11-03)

## Corpus Check
- 84 files · ~219,466 words
- Verdict: corpus is large enough that graph structure adds value.
- Unclassified: 6 file(s) not represented in the graph (top: (none) 6)

## Summary
- 668 nodes · 1164 edges · 53 communities (49 shown, 4 thin omitted)
- Extraction: 90% EXTRACTED · 10% INFERRED · 0% AMBIGUOUS · INFERRED: 116 edges (avg confidence: 0.83)
- Token cost: 818,830 input · 0 output

## Community Hubs (Navigation)
- Data, Challenges & Audit
- Python Import Tools
- Recent Fixes & QA
- Build, Combat & Champion
- W1 Wave Proposals
- Spine: Data, Analytics, Guard
- Map Authoring Contract
- Config Tunables
- Spec v2 Core Concepts
- Run Loop Services (v1 spec)
- Monetization & Polish Design
- Modes, Shards & Endless Config
- Campaign Maps & Slots
- Enemy Bestiary
- Spec v1 Standards
- Hero Roster
- Run Rules & Payouts
- Server Spine Modules
- Character Art Rules
- Collab Workflow & Validator
- Codex & Run End
- Co-op & Teleport Flow
- Champions & Allied Units
- Lanes, Snapshots & HUD
- Enemy Sim Performance
- Ashridge Waves & Boss Scaling
- Blackfen/Frostmere Waves
- Handoff Rules & Gotchas
- Match Phase Machine
- Matchmaking & MemoryStore
- Mount Import & Contract
- Building Model Batches
- Character & Hero Batches
- Lobby, FTUE & Map Roles
- Endless, Liveops & Leaderboards
- Mount Roster
- Security Audit Findings
- Champion Combat & Tags
- Collaboration Roles
- Lobby & Hero Services
- Mount Tooling & BOM
- Early Character Batches
- Mount & Shop Code
- Places & Parties
- Debug & Perf Tools
- Leaderboards & Map Access
- Phase 4 Slices
- Hero Cap & Picker
- Config & Studio Overrides
- Honeypots
- script_grep Gotcha

## God Nodes (most connected - your core abstractions)
1. `Kingdom Nights Master Build Spec v2` - 24 edges
2. `Kingdom Nights engineering handoff` - 21 edges
3. `Config.luau (all tunables)` - 20 edges
4. `Enemies bestiary (14 + boss)` - 19 edges
5. `BuildService (slots, construction, upgrades)` - 15 edges
6. `W1 campaign wave proposal 2026-10-18` - 15 edges
7. `Heroes (12, collection)` - 15 edges
8. `Thronefall deconstruction and Roblox adaptation guide` - 14 edges
9. `What changed in v2` - 13 edges
10. `BuildService` - 13 edges

## Surprising Connections (you probably didn't know these)
- `Deliveries are untrusted data, never executed` --conceptually_related_to--> `Division of labour: ChatGPT models, Claude imports`  [INFERRED]
  claude-tools/README.md → HANDOFF-kingdom-nights.md
- `4p count max(1, floor(Count x 2.05 + 0.5))` --semantically_similar_to--> `waveBudget x (0.6 + 0.4 x playerCount)`  [INFERRED] [semantically similar]
  chatgpt-out/waves/W1-design-review.md → thronefall-research-and-roblox-plan.md
- `Kingdom Nights engineering handoff` --references--> `W1 campaign wave proposal 2026-10-18`  [INFERRED]
  HANDOFF-kingdom-nights.md → chatgpt-out/waves/W1-design-review.md
- `Guard validation module` --implements--> `Server authority, never trust client values`  [INFERRED]
  claude-out/AUDIT-2026-11-02-pre-launch.md → HANDOFF-kingdom-nights.md
- `L1 PLAY ProximityPrompt not rate-limited` --references--> `LobbyService`  [INFERRED]
  claude-out/AUDIT-2026-11-02-pre-launch.md → HANDOFF-kingdom-nights.md

## Import Cycles
- None detected.

## Hyperedges (group relationships)
- **Shared per-tick spatial grid consumers** — kingdom_nights_build_spec_v2_spatialgrid, kingdom_nights_build_spec_v2_enemyservice, kingdom_nights_build_spec_v2_towerservice, kingdom_nights_build_spec_v2_unitservice [EXTRACTED 1.00]
- **Morning sequence service flow** — kingdom_nights_build_spec_v2_morning_sequence, kingdom_nights_build_spec_v2_buildservice, kingdom_nights_build_spec_v2_economyservice, kingdom_nights_build_spec_v2_upgradeservice, kingdom_nights_build_spec_v2_championservice [EXTRACTED 1.00]
- **Two-track hero power (campaign capped, endless uncapped)** — kingdom_nights_build_spec_v2_power_normalization, kingdom_nights_build_spec_v2_campaign, kingdom_nights_build_spec_v2_endless_siege, kingdom_nights_build_spec_v2_heroservice, kingdom_nights_build_spec_v2_hero_collection [EXTRACTED 1.00]
- **Asset delivery pipeline: kn-asset/1 file -> validator -> importer -> Studio** — collab_log_kn_asset_1, collab_log_kn_validate, claude_tools_kn_import_map, claude_tools_kn_import_character, collab_log_kn_import_building, claude_tools_kn_import_mount_luau_claude_tools_kn_import_mount [EXTRACTED 1.00]
- **Four campaign maps** — collab_log_map_greenhollow, collab_log_map_ashridge, collab_log_map_frostmere, collab_log_map_blackfen [EXTRACTED 1.00]
- **RoadJoin Ball defect -> Cylinder rule -> validator rotation bug -> delta patch** — collab_log_roadjoin_ball_defect, collab_log_flat_cylinder_rule, collab_log_validator_rotation_bug, collab_log_kn_patch_map [EXTRACTED 1.00]
- **One SpatialGrid rebuild per tick shared by Enemy, Tower and Unit services** — kingdom_nights_build_spec_spatialgrid, kingdom_nights_build_spec_enemyservice, kingdom_nights_build_spec_towerservice, kingdom_nights_build_spec_unitservice [EXTRACTED 1.00]
- **Damage pipeline: matrix x upgrade x perk x mutator multipliers** — kingdom_nights_build_spec_apply_damage, kingdom_nights_build_spec_config_damage, kingdom_nights_build_spec_upgradeservice, kingdom_nights_build_spec_perkservice, kingdom_nights_build_spec_mutatorservice [EXTRACTED 1.00]
- **Phase 1 core loop graybox services** — kingdom_nights_build_spec_matchservice, kingdom_nights_build_spec_buildservice, kingdom_nights_build_spec_economyservice, kingdom_nights_build_spec_waveservice, kingdom_nights_build_spec_enemyservice, kingdom_nights_build_spec_championservice [EXTRACTED 1.00]
- **Phase 4.4 hero system** — handoff_kingdom_nights_herorules, handoff_kingdom_nights_herocollectionservice, handoff_kingdom_nights_heroservice, handoff_kingdom_nights_heroescontroller, handoff_kingdom_nights_progressionservice [EXTRACTED 1.00]
- **Audit fixes applied 2026-11-02** — claude_out_audit_2026_11_02_pre_launch_b1, claude_out_audit_2026_11_02_pre_launch_m1, claude_out_audit_2026_11_02_pre_launch_m2, claude_out_audit_2026_11_02_pre_launch_l1, claude_out_audit_2026_11_02_pre_launch_l2 [EXTRACTED 1.00]
- **Studio MCP tooling gotchas** — handoff_kingdom_nights_gotcha_require_cache, handoff_kingdom_nights_gotcha_plugin_sandbox, handoff_kingdom_nights_gotcha_bridge_timeout, handoff_kingdom_nights_gotcha_script_grep_patterns, handoff_kingdom_nights_gotcha_multiclient_test [INFERRED 0.85]
- **Tagged map elements validated by server** — map_and_asset_brief_for_chatgpt_buildslot, map_and_asset_brief_for_chatgpt_enemyspawn, map_and_asset_brief_for_chatgpt_lanenode, map_and_asset_brief_for_chatgpt_map_validation, map_and_asset_brief_for_chatgpt_wave_table [EXTRACTED 1.00]
- **Batch 1 Phase 1 Core Four** — character_roster_and_design_brief_warden, character_roster_and_design_brief_knight, character_roster_and_design_brief_weakling, character_roster_and_design_brief_swordsman [EXTRACTED 1.00]
- **Model rules enforced via kn-asset importer** — map_and_asset_brief_for_chatgpt_kn_asset_1, map_and_asset_brief_for_chatgpt_importer_checks, map_and_asset_brief_for_chatgpt_anchoring_rule, character_roster_and_design_brief_colour_limit, character_roster_and_design_brief_quality_gates [INFERRED 0.85]

## Communities (53 total, 4 thin omitted)

### Community 0 - "Data, Challenges & Audit"
Cohesion: 0.05
Nodes (51): Population finding (<=180 under 200 cap), M2 profile UpdateAsync lacks userIds (RTBF), BuildService, ChallengesController, ChallengeService, ChampionService (teammate revive), Shared/Util/DailyChallenges, DataService (session-locked profiles) (+43 more)

### Community 1 - "Python Import Tools"
Cohesion: 0.11
Nodes (29): bundle(), die(), one(), die(), main(), die(), main(), check_building() (+21 more)

### Community 2 - "Recent Fixes & QA"
Cohesion: 0.11
Nodes (25): Greenhollow tutorial waves unchanged, Late-joiner hero deploy untested, roblox-testing QA checklist status, 2-client Studio test on Greenhollow, kn_patch_map.py delta importer, Engine bug: ground enemies ignored lanes, Bug: ModelPool:Return ScaleTo 24.8 ms spike, CombatService (+17 more)

### Community 3 - "Build, Combat & Champion"
Cohesion: 0.16
Nodes (25): BuildController, BuildService, ChallengeTracker, Champion auras, ChampionService, Pooled physical coin drops, CombatService, Co-op wave and drop scaling (+17 more)

### Community 4 - "W1 Wave Proposals"
Cohesion: 0.14
Nodes (22): chatgpt-out folder layout (maps, buildings, enemies, units, waves, reference), Ashridge v3 waves, Blackfen v2 waves (night-10 boss finale), bloodwing enemy, W1-comparison-data.json, 4p count max(1, floor(Count x 2.05 + 0.5)), darkwarrior enemy, W1 campaign wave proposal 2026-10-18 (+14 more)

### Community 5 - "Spine: Data, Analytics, Guard"
Cohesion: 0.12
Nodes (21): AnalyticsService (FTUE funnel, economy events), Anti-speed Position Sanity Check (snap-back), ChallengeService (deterministic daily challenges), ChallengeTracker (in-run counters, commit at end), Codex (seen enemies/buildings), Config.Challenges, Config.Progression, DataService (session-locked profile pipeline) (+13 more)

### Community 6 - "Map Authoring Contract"
Cohesion: 0.14
Nodes (21): Anchoring rule: anchored root, unanchored welded children, Bounds (invisible 20-stud collision walls at map edge), Character model contract (Assets/Enemies, Assets/Units), Shared collab folder (chatgpt-out/, COLLAB-LOG.md), Decor & road surfaces (0.04 thick, top at Y=0.52, <20 studs tall), Kingdom Nights Map & Asset Brief (for ChatGPT), EnemySpawn (tag, contiguous SpawnIndex), Flat battlefield at Y = 0.5 (GroundY) (+13 more)

### Community 7 - "Config Tunables"
Cohesion: 0.13
Nodes (20): CombatService:ApplyDamage, Champion Auto-attack (combat floor), Config.Buildings, Config.Champions, Config.Damage (tag multiplier matrix), Config.Economy, Config.Enemies, Config.luau (all tunables) (+12 more)

### Community 8 - "Spec v2 Core Concepts"
Cohesion: 0.16
Nodes (16): Config.Maps, Ways this project dies, FTUE first 120 seconds, Hero collection (shards, rarity, roster), HeroService, Revised kickoff prompt, Lobby layout and kiosks, Map authoring pipeline (+8 more)

### Community 9 - "Run Loop Services (v1 spec)"
Cohesion: 0.21
Nodes (16): Active Abilities (Combat_Ability), BuildController (client build affordance), BuildService (slots, construction, upgrades), ChampionService (player character), Pooled Coin Drops (ride-over collection, magnet), CombatService (damage resolution), Destroyed Flag (free rebuild, no income), EconomyService (shared gold) (+8 more)

### Community 10 - "Monetization & Polish Design"
Cohesion: 0.18
Nodes (14): Build hints (nights 1-3), Clip moments (boss finisher, LAST STAND, victory pose), Difficulty tiers (Casual/Normal/Heroic), Monetization (four axes), MonetizationService, Mounts (cosmetic collection), Phase 6 - Monetization, Phase 7 - Juice and mobile pass (+6 more)

### Community 11 - "Modes, Shards & Endless Config"
Cohesion: 0.15
Nodes (14): Campaign mode, Codes system, Codex, Config.Difficulty, Config.Endless, Config.luau, Config.Perf hard caps, Config.Shards (+6 more)

### Community 12 - "Campaign Maps & Slots"
Cohesion: 0.17
Nodes (16): Map Ashridge (balanced, 8-10 nights), Map Blackfen (fortress, siege-heavy), Building model contract (Assets/Buildings/<SlotType>/L1-L3, pivot base centre, front -Z), Building SlotTypes (Castle, House, Tower, Wall, Barracks, ...), BuildSlot (tag, SlotId/SlotType/MaxLevel/StartLevel), Known engine gaps (enemy pool multi-part rebuild, GoldMine flat income), Map Frostmere (kill zones, 22 towers), Map Greenhollow (tutorial, 5 nights, 2 spawns) (+8 more)

### Community 13 - "Enemy Bestiary"
Cohesion: 0.15
Nodes (15): Battering Ram (E13, siege), Catapult (E14, siege), Dark Warrior (E6), Elite variants (same mesh, 25% white tint, aura, 1.15x), Enemies bestiary (14 + boss), Archer enemy (E3), Exploder (E12), The Fen Wraith (B1 boss) (+7 more)

### Community 14 - "Spec v1 Standards"
Cohesion: 0.13
Nodes (15): Init/Start Bootstrap Pattern, Build Standards (server authority, --!strict, two entry scripts), CameraController (angled top-down, limited zoom), Config.Monetize, Kingdom Nights Master Build Specification (v1), Full Instance Tree, Juice and Audio Spec (sound + motion + number), Launch Scope v1.0 (4 maps, 4 champions, 14 enemies) (+7 more)

### Community 15 - "Hero Roster"
Cohesion: 0.14
Nodes (14): The Ashen Queen (H12, Legendary nuke), Bloodwing (E11, flying), Bowman Captain (H2, Common ranged), Field Medic (H7, Rare support), Firewing (H10, Epic flying DPS), Frost Warden (H9, Epic control), Golem (H8, Epic tank/AoE), Heroes (12, collection) (+6 more)

### Community 16 - "Run Rules & Payouts"
Cohesion: 0.16
Nodes (14): Config.Match, Crown Payout Formula (paid win or lose), Non-negotiable Design Rules, Legal Notes (avoid Thronefall name/assets/map names), Day Has No Timer, Single In-run Resource: Gold, Rally Flags (day-phase unit positioning), Ready System and AFK Failsafe (+6 more)

### Community 17 - "Server Spine Modules"
Cohesion: 0.22
Nodes (13): AnalyticsService, DataService, Guard, Admin_GrantCrowns honeypot remote, LoadoutService, Profile migration table, Net, Phase 2 - Spine (+5 more)

### Community 18 - "Character Art Rules"
Cohesion: 0.23
Nodes (13): Prompt for Claude Design (reference sheets, batch of 4-6), Colour rule: max 4 colours per model, flat, emissive only for rarity/magic, Construction rules (primitives only, visible seams, floating limbs), Face rule (two dark rectangle eyes only), Faction palettes (Player/Human/Monster/Siege/Boss), Knight vs Swordsman highest-risk confusion pair, Proportion rules & scale reference (5-stud champion), Model quality gates checklist (+5 more)

### Community 19 - "Collab Workflow & Validator"
Cohesion: 0.24
Nodes (12): Bounds folder (invisible map-edge walls), ChatGPT (maps, models), Claude (engineering, Studio), Config.Matchmaking.DefaultMapId = greenhollow, Defect: difficulty resolved before profiles loaded, Kingdom Nights Collaboration Log, 18-stud horde corridor clearance, kn-asset/1 format (+4 more)

### Community 20 - "Codex & Run End"
Cohesion: 0.18
Nodes (12): ChallengeTracker, Shared/Util/Codex, CodexController, CodexService, CodexTracker, Gap: no match-to-lobby return teleport, Gap: rejoin offered an unresumable run, Gotcha 9: forward-reference local function bugs (+4 more)

### Community 21 - "Co-op & Teleport Flow"
Cohesion: 0.23
Nodes (12): Co-op Drop Gold Scaling, Co-op Rules (sharing, scaling, disconnects, friend bonus), Co-op Wave Scaling (1 + 0.35 x (n-1), snapshotted), Champion Downed / Co-op Revive, PartyService (party formation + reserved-server teleport), Phase 3 - Co-op and Depth, Place Settings (streaming, CharacterAutoLoads), DataService:Release / ReleaseMany (+4 more)

### Community 22 - "Champions & Allied Units"
Cohesion: 0.22
Nodes (11): Alchemist (C4, support, vials), Allied units (mass troops, 6-8 parts), Archer (U2 allied ranged unit), Character build order (5 batches), Champions (4 player characters), Kingdom Nights Character Roster & Design Brief, Knight (U1 allied melee unit), Marshal (C3, anti-fast, spear) (+3 more)

### Community 23 - "Lanes, Snapshots & HUD"
Cohesion: 0.18
Nodes (11): Authored Build Slots (no free placement), Config.Maps (night-by-night wave tables), Elite Variants (Hp x4, Damage x3), Full-Snapshot State Replication (Match_State / Match_Tick), HUDController (match HUD), Authored Lane Following, Map Authoring Pipeline (BuildSlot/EnemySpawn/LaneNode tags), Phase 8 - Liveops (+3 more)

### Community 24 - "Enemy Sim Performance"
Cohesion: 0.27
Nodes (11): Config.Perf (hard caps), Config.Units, Enemy Five Rules (no Humanoid, no pathfinding, one loop, pool, no per-frame remotes), EnemyService (pooled simulation), Performance Budgets and Rules, Pool (instance pooling), Shared Modules (Net, Guard, RateLimit, Trove, Signal, Cooldown, Pool), SpatialGrid (uniform target grid) (+3 more)

### Community 25 - "Ashridge Waves & Boss Scaling"
Cohesion: 0.24
Nodes (9): Defect: validator rejected kind 'character', Decision: CoopBossScalesHp (bosses never multiply), Co-op count scaling round(Count*(1+0.35*(players-1))), Enemy batch E3 (bloodwing, darkwarrior, exploder, fenwraith, spiderling), fenwraith (Blackfen night-10 boss), Map_Ashridge (v1-v3), W1-design-review.md / W1-comparison-data.json, WaveService:ScaleEntry (+1 more)

### Community 26 - "Blackfen/Frostmere Waves"
Cohesion: 0.22
Nodes (8): catapult enemy v1, Decision: catapult AttackRange 90 -> 65, Defect: CHAR_BUDGET missing entries, Config.Maps (wired wave tables), Decision: heroes deploy from the castle, Omar (project owner, approver), Allied units can die (target selection fix), Decision: units die with their building

### Community 27 - "Handoff Rules & Gotchas"
Cohesion: 0.20
Nodes (10): kingdom-nights-build-spec-v2.md (the contract), character-roster-and-design-brief.md, Kingdom Nights engineering handoff, Gotcha 17: anchored root + unanchored welded children, Gotcha 8: SetNetworkOwner(nil) throws on anchored parts, Cross-service requires inside Init only, Remaining model gaps (Blacksmith, Field, RoyalForge, Temple, golem), Phase 1 graybox loop (complete) (+2 more)

### Community 28 - "Match Phase Machine"
Cohesion: 0.22
Nodes (7): Bootstrap Init/Start pattern, CameraController, Day / Night / Morning phase machine, LobbyPresenceService, MatchService, Lobby-to-match teleport flow, Two-place universe (Lobby + Battle)

### Community 29 - "Matchmaking & MemoryStore"
Cohesion: 0.22
Nodes (7): Config.Damage tag multiplier matrix, Config.Matchmaking, Co-op rules, MatchmakingService, MemoryStore (queues, hashmaps, sorted maps), Ready system and AFK failsafe, Rejoin support

### Community 30 - "Mount Import & Contract"
Cohesion: 0.33
Nodes (8): cf(), rot(), topY(), check_mount validator rule, Mount models M1 (6 mounts), Mount rider zone (empty seated volume), Mount saddle top at Y=2.0, Defect: UTF-8 BOM in mount example file

### Community 31 - "Building Model Batches"
Cohesion: 0.25
Nodes (9): B1 v2 colour pass (darker stone, Castle keep caps), Building Batch B1 (House, Tower, Castle, Wall), Building Batch B2 (Barracks, ArcheryRange, Mill), Building loader (Assets/Buildings/<SlotType>/L<n>), Building contract: no root/PrimaryPart, WorldPivot at base centre, FiringDeck part-name contract, kn_import_building.py (--bundle), Finding: Studio lighting washes out pale palettes (+1 more)

### Community 32 - "Character & Hero Batches"
Cohesion: 0.25
Nodes (9): Character Batch 2 (slime, racer, archer_e, pikeman, wasp, ram, ogre, archer unit), Character root contract (one invisible HumanoidRootPart at base), character-roster-and-design-brief.md, Defect: elite ScaleTo inside enemy tick (24.8 ms spike), No baked hover; engine applies FlightHeight, Hero batch H1 (3 Commons, 4 Rares), Hero batch H2 (golem, frostwarden, firewing, lizardrider, ashenqueen), Hero rarity visual language (Common/Rare/Epic/Legendary) (+1 more)

### Community 33 - "Lobby, FTUE & Map Roles"
Cohesion: 0.22
Nodes (9): FTUE First 120 Seconds, KioskController (tagged Kiosk proximity prompts), Lobby Layout and Kiosks, LobbyPresenceService (returning-run results), Map: Ashridge (balanced), Map: Blackfen (fortress, siege-heavy), Map: Frostmere (kill zones), Map: Greenhollow (tutorial) (+1 more)

### Community 34 - "Endless, Liveops & Leaderboards"
Cohesion: 0.31
Nodes (9): Blood Moon server-wide event, ChallengeService, Endless Siege mode, LeaderboardService, Phase 4 - Meta, collection, lobby, Phase 5 - Endless Siege and virality, Phase 9 - Liveops, ProgressionService (+1 more)

### Community 35 - "Mount Roster"
Cohesion: 0.25
Nodes (8): Bay Horse (M1, default), Dire Wolf (M3, Crowns), Lizard Rider (H11, Legendary hybrid), Mounts (6 cosmetic, zero stats), Sand Lizard (M4, Stable Pass), Skeletal Steed (M5, Stable Pass), Sun Stag (M6, event only), Warhorse (M2, Crowns)

### Community 36 - "Security Audit Findings"
Cohesion: 0.32
Nodes (8): Pre-launch hardening audit 2026-11-02, Lobby fuzz: 20 combos x 19 hostile payloads, 0 errors, Guard validation module, L2 Guard.string lacks UTF-8 check, M3 no Ban ladder for honeypots, Net.onServer (mandatory rate limit + pcall), Gotcha 32: Admin_SetGold / Admin_GrantCrowns are honeypots, Suggested Roblox skills

### Community 37 - "Champion Combat & Tags"
Cohesion: 0.36
Nodes (8): Alchemist (champion), Champion Auras, Damage Multiplier Matrix (counters, not stats), DamageTag (Normal/Flying/Fast/Siege/Monster/Armored/Boss), Marshal (champion), Ranger (champion), Types.luau Shared Type Contract, Warden (champion)

### Community 38 - "Collaboration Roles"
Cohesion: 0.38
Nodes (7): chatgpt-out README, kn-asset/1 JSON format, Ask-Omar-before gate (Config numbers, publish, deletes, Phase 4), COLLAB-LOG.md Claude-ChatGPT channel, Division of labour: ChatGPT models, Claude imports, map-and-asset-brief-for-chatgpt.md, Omar (project owner)

### Community 39 - "Lobby & Hero Services"
Cohesion: 0.33
Nodes (7): L1 PLAY ProximityPrompt not rate-limited, HeroCollectionService, HeroesController, LobbyController, LobbyService, Lobby map picker (UnlockLevel gate), ProgressionService (crowns, XP, shards)

### Community 40 - "Mount Tooling & BOM"
Cohesion: 0.29
Nodes (7): Deliveries are untrusted data, never executed, claude-tools README (import pipeline), kn_import_mount.luau template, kn_import_mount.ps1, Gotcha 25: device bridge times out at 60 s, Gotcha 49: this PC has no Python, UTF-8 BOM from PS 5.1 Set-Content in JSON

### Community 41 - "Early Character Batches"
Cohesion: 0.29
Nodes (7): Character Batch 1 (weakling, swordsman, knight), Equal-axis Ball rule, Flat round patch rule (Cylinder [thick,d,d], orientation [0,0,90]), kn_patch_map.py (delta map import), Shared/Util/ModelPool (per-type pools), Defect: RoadJoin flat Balls invisible, Defect: validator ignored rotation for height

### Community 42 - "Mount & Shop Code"
Cohesion: 0.29
Nodes (7): Gotcha 47: default Animate stops playing tracks, Gotcha 46: WeldConstraints record offsets on activation, Mount scaled so saddle meets hip, MountController, MountService, ShopController, ShopService (Crown shop + loadout)

### Community 43 - "Places & Parties"
Cohesion: 0.29
Nodes (7): Gotcha 2: ReserveServer 403 in Studio, Lobby parties, Lobby place 109425409417963, Match place Kingdom Nights - Battle 137014900347575, One Studio document published to two place IDs, PartyController, PartyService

### Community 44 - "Debug & Perf Tools"
Cohesion: 0.33
Nodes (6): B1 EnablePerfTools live (launch blocker), Config.Debug.EnablePerfTools flag, Config drift from Config_v2, DebugService (Debug_EndRun, Debug_Stress), Gotcha 31: Reserve vs ReserveExtra, PerfController (on-device perf overlay)

### Community 45 - "Leaderboards & Map Access"
Cohesion: 0.40
Nodes (6): M1 Leaderboard_Get uncached MemoryStore MyWeekly read, LeaderboardController, LeaderboardService, LeaderboardStore (ServerScriptService/Lib), Shared/Util/MapAccess, MatchmakingService (per-map MemoryStore queues)

### Community 46 - "Phase 4 Slices"
Cohesion: 0.33
Nodes (6): Phase 4.2 lobby Crown shop, Phase 4.3 Daily Challenges, DifficultyMult (live crown reward multiplier), GoldMine/L1, Map_Frostmere v1, Phase 4.1 run rewards (Crowns + XP)

### Community 47 - "Hero Cap & Picker"
Cohesion: 0.33
Nodes (6): Campaign hero power cap (HeroLevelCap, spec §36.1), Shared/Util/HeroRules, Leaderboards restarted as v2, Lobby map picker (Shared/Util/MapAccess), Map_Blackfen v1, PartyService / PartyController (lobby parties)

### Community 48 - "Config & Studio Overrides"
Cohesion: 0.33
Nodes (6): Config_v2.luau balance source of truth, Config.GetPlaceKind / Config.Places manifests, Gotcha 19: Studio plugin capability sandbox, Gotcha 1: execute_luau has its own require cache, KN_PlaceKindOverride / KN_MapOverride Studio attributes, ReplicatedStorage/Shared/Config.luau (deployed Config)

## Knowledge Gaps
- **141 isolated node(s):** `Bootstrap Init/Start pattern`, `Profile migration table`, `BuildController`, `Pooled physical coin drops`, `Elite enemy variants` (+136 more)
  These have ≤1 connection - possible missing edges or undocumented components. (Counts symbols only; 154 node(s) total have ≤1 connection when file, concept and rationale nodes are included.)
- **4 thin communities (<3 nodes) omitted from report** — run `graphify query` to explore isolated nodes.

## Suggested Questions
_Questions this graph is uniquely positioned to answer:_

- **Why does `Kingdom Nights engineering handoff` connect `Handoff Rules & Gotchas` to `Data, Challenges & Audit`, `W1 Wave Proposals`, `Security Audit Findings`, `Collaboration Roles`, `Mount Tooling & BOM`, `Debug & Perf Tools`, `Config & Studio Overrides`?**
  _High betweenness centrality (0.068) - this node is a cross-community bridge._
- **Are the 2 inferred relationships involving `BuildService (slots, construction, upgrades)` (e.g. with `BuildController (client build affordance)` and `MatchService (phase state machine spine)`) actually correct?**
  _`BuildService (slots, construction, upgrades)` has 2 INFERRED edges - model-reasoned connections that need verification._
- **What connects `Bootstrap Init/Start pattern`, `Profile migration table`, `BuildController` to the rest of the system?**
  _141 weakly-connected nodes found - possible documentation gaps or missing edges._
- **Should `Data, Challenges & Audit` be split into smaller, more focused modules?**
  _Cohesion score 0.05176470588235294 - nodes in this community are weakly interconnected._
- **Why does `claude-tools README (import pipeline)` connect `Mount Tooling & BOM` to `Config & Studio Overrides`, `Python Import Tools`, `Recent Fixes & QA`, `Handoff Rules & Gotchas`?**
  _High betweenness centrality (0.063) - this node is a cross-community bridge._
- **Should `Python Import Tools` be split into smaller, more focused modules?**
  _Cohesion score 0.10730804810360776 - nodes in this community are weakly interconnected._
- **Why does `Map_Greenhollow (tutorial map, v1-v4)` connect `Collab Workflow & Validator` to `Python Import Tools`, `Early Character Batches`?**
  _High betweenness centrality (0.032) - this node is a cross-community bridge._