# KINGDOM NIGHTS — Master Build Specification

**Version 2.0 — a Thronefall-inspired co-op kingdom defense game for Roblox.**
This document is the single source of truth for development. It is written to be executed phase by phase. Every system below is specified to the level where implementation is transcription, not invention.

Standards this build holds to: server authority on every state change, one session-locked data pipeline, `--!strict` on every module, mobile-first UI, all tunables in `Config.luau`, exactly two entry-point scripts per place.

### What changed in v2, and why

v1 was a faithful, well-engineered port of a premium single-player strategy game. That is exactly its problem: Thronefall's meta loop is "replay the same map for a higher score," which retains strategy fans who already paid, not a free-to-play mobile-majority audience the discovery algorithm has to be convinced to feed. v2 keeps every strategic system intact and adds the three things Roblox actually rewards — **collection, accessible co-op, and an endless mode**.

| # | Change | Section | Rationale |
|---|---|---|---|
| 1 | **Hero collection with shards and rarity** | §33 (new) | The single biggest gap in v1. Roblox tower-defense games retain on *collecting*, not on tactics. This is the retention engine, the flex, and the monetization surface in one system. |
| 2 | **Two difficulty tracks (power-normalized vs open)** | §36 (new) | Resolves the tension between collection power and puzzle integrity. Campaign caps hero power so scores stay comparable; Endless and Trials scale freely. |
| 3 | **Public Quick Play matchmaking** | §34 (new) | **Overrides v1 §17.1.** Party-only was wrong: a player with no friends online is the majority case, and co-op is the headline feature. Without this, most players never experience it. |
| 4 | **Rejoin support** | §34.3 | **Overrides v1 §17.** Mobile players get calls, app-switch, and drop connection constantly. Losing a co-op run to a Wi-Fi hiccup is a rage-quit generator. |
| 5 | **Run length cut to 6–9 minutes** | §1.2, §5.2 | 12–20 minutes is a premium-PC number. Roblox players decide in one session whether you deserve a second. |
| 6 | **Endless Siege mode + weekly leaderboard** | §35 (new) | The real long-tail retention engine, and nearly free: waves, scaling and scoring already exist. |
| 7 | **Difficulty selection (Casual / Normal / Heroic)** | §36 | The source game is genuinely hard and this audience skews younger. Let people opt into pain rather than defaulting them into it. |
| 8 | **Mounts as a cosmetic collection** | §37 (new) | The source's king rides a horse; v1 dropped it. Best cosmetic axis available — visible, flexable, zero balance cost. |
| 9 | **Build hints for the first three nights** | §36.3 | Strategy games have a comprehension wall, and comprehension walls are bounce. |
| 10 | **Clip-able moments designed in** | §38 (new) | v1 had none. Shorts/TikTok is the cheapest top-of-funnel that exists. |
| 11 | **Monetization rebuilt** | §29 (replaced) | Ten passes across four axes instead of five, priced to how players actually hold Robux. |
| 12 | **Search-optimized title** | §38.4 | "Kingdom Nights" tells the algorithm nothing. Players type genre nouns. |

Everything not listed above is unchanged from v1 and still authoritative.

---

## 0. TABLE OF CONTENTS

| § | Section |
|---|---|
| 1 | Game identity, scope, and the three loops |
| 2 | Universe & place architecture |
| 3 | Full instance tree (both places) |
| 4 | `Types.luau` — the shared type contract |
| 5 | `Config.luau` — schema and all balance tables |
| 6 | Data model — profile template and rules |
| 7 | The match state machine (day / night / morning) |
| 8 | BuildService — slots, construction, upgrades |
| 9 | EconomyService — shared gold, income, drops |
| 10 | WaveService — spawn tables, preview, co-op scaling |
| 11 | EnemyService — the pooled simulation (hardest system) |
| 12 | CombatService — damage, tags, multipliers |
| 13 | ChampionService — the player character |
| 14 | UnitService — allied troops and rally points |
| 15 | TowerService — building weapons |
| 16 | UpgradeService — branching upgrade choices |
| 17 | Co-op rules — sharing, scaling, disconnects, revives |
| 18 | Lobby — layout, kiosks, party & matchmaking |
| 19 | LoadoutService & ShopService |
| 20 | ChallengeService — daily challenges |
| 21 | Meta progression — Crowns, XP, unlocks, codex |
| 22 | Complete remote contract |
| 23 | Map authoring pipeline (Studio workflow) |
| 24 | UI screen inventory |
| 25 | Juice & audio spec |
| 26 | Performance budgets and rules |
| 27 | Security checklist |
| 28 | Analytics events |
| 29 | Monetization |
| 30 | Phased build order with acceptance criteria |
| 31 | Test plan |
| 32 | Kickoff prompt for the next session |
| **33** | **Hero collection — shards, rarity, roster (NEW)** |
| **34** | **Matchmaking, Quick Play, and rejoin (NEW — overrides §17.1)** |
| **35** | **Endless Siege mode (NEW)** |
| **36** | **Difficulty tracks and power normalization (NEW)** |
| **37** | **Mounts and cosmetic collections (NEW)** |
| **38** | **Virality — clip moments, codes, events, title (NEW)** |
| **39** | **Revised kickoff prompt** |

---

## 1. GAME IDENTITY, SCOPE, AND THE THREE LOOPS

### 1.1 Hook
> **"Build your kingdom by day. Ride out and fight the horde yourself at night. With three friends."**

Core verb: **ride → build → fight.**

### 1.2 Scope at launch (v2.0)
- 4 maps (1 tutorial + 3 campaign), **6–9 minutes per run**
- **Endless Siege** mode with a weekly leaderboard
- 4 champions, 6 weapons
- **12 collectible heroes** across 4 rarities (§33)
- 14 enemy types + 1 boss
- 8 build-slot types with branching upgrades
- 20 perks
- 8 mutators + **3 difficulty tiers** (§36)
- 1–4 player co-op with **public Quick Play matchmaking** (§34)
- Lobby with shop, loadout, hero roster, stable, challenges, party system
- 3 daily challenges, rotating
- 6 mounts (§37)

**Run length is a hard constraint, not a target.** Campaign maps are 8–10 nights with 45–75 second nights. If a map plays longer than 9 minutes in testing, cut nights — do not shorten the day phase, which is the part players enjoy.

### 1.3 The three loops

**Moment loop (seconds)** — swing → enemy staggers and dies → coin bursts out → coin flies to the shared counter with a tick sound. Build → mesh scale-punches in with dust particles and a satisfying thunk. If these two moments are not fun in graybox, stop and fix them before anything else.

**Session loop (6–9 min)** — day (spend gold, no timer) → night (fixed previewed wave) → morning (free rebuild, income paid, score). Target 3–6 "I got visibly stronger" beats per run.

**Meta loop (days) — rebuilt in v2.** Crowns *and hero shards* earned every run, win or lose → shards level and unlock heroes from a 12-strong roster with rarities → heroes are visible on the battlefield to your three teammates → the codex tracks what you're missing → daily challenges give a reason to log in → Endless Siege and the weekly leaderboard give a reason to stay.

The distinction matters: v1's meta was *mastery* (replay for a better score), which retains a narrow, dedicated audience. v2's meta is **collection**, which is what Roblox tower-defense games actually run on. Mastery is still there for the players who want it — it just isn't load-bearing any more.

### 1.4 Non-negotiable design rules (inherited from the source design; do not "improve" these)
1. **The day has no timer.** Players end it when ready. Only an AFK failsafe exists (§7.4).
2. **Players cannot choose what to build or where.** Every map ships with authored slots that accept one building type each. The only decision is order and timing. This is the highest-leverage constraint in the design — it is what makes new maps content work instead of code work.
3. **The night is previewed.** Players see which spawn points activate and roughly what is coming, during the day.
4. **Every destroyed building is rebuilt free each morning** — but a building that respawned pays no income that morning, and the score drops. Forgiveness with a soft cost.
5. **One in-run resource: gold.** No wood, no food, no population cap.
6. **Auto-attack floor, active-ability ceiling.** A player who never presses the ability button can still win map 1.
7. **Enemies are countered, not out-statted.** Tags (Flying / Fast / Siege / Monster / Armored) drive a multiplier table; that table is the whole combat design.
8. **(v2) Campaign is power-normalized.** Hero collection must never turn a campaign map into a walkover, or the puzzle — the actual game — evaporates. Campaign caps hero contribution to the map's tier; Endless and Trials scale freely. See §36.

### 1.5 FTUE — the first 120 seconds (this decides whether the game grows)

| Time | What happens |
|---|---|
| 0–8s | Player spawns in the lobby facing the **PLAY** portal. One arrow, no text wall. First-time players auto-route into the tutorial map solo. |
| 8–20s | Spawn on the tutorial map next to a glowing House slot. Arrow points at it. Prompt: "Build House — 2 gold". They have 3 starting gold. |
| 20–30s | House plops in with full juice. Gold counter ticks. Second arrow points to a Tower slot. |
| 30–50s | Tower built. "START NIGHT" button pulses. |
| 50–90s | Night 1: 6 weaklings from one spawn point. Auto-attack does the work. Coins burst and fly in. |
| 90–120s | Morning: income pays, score pops, day 2 begins with a visible new slot type unlocked. |
| ~5 min | Tutorial map complete (5 nights), Crowns awarded, results screen shows **"Ranger — 820/1000 Crowns"** — the almost-affordable hook. |

Instrument every one of these as a funnel step (§28). Any step losing >15% is a fire.

---

## 2. UNIVERSE & PLACE ARCHITECTURE

**Two places in one universe.** This is the correct structure and should not be collapsed into one place.

| Place | Role | Max players | Access |
|---|---|---|---|
| **Kingdom Nights** (start place) | Lobby: social hub, shop, loadout, challenges, party formation, leaderboards | 12 | Public |
| **Kingdom Nights — Battle** | The actual run. One map instance per server. | 4 | **Reserved servers only** |

### 2.1 Why two places
- The match server runs a heavy enemy simulation. It must not also be paying for 12 idle lobby players.
- Reserved servers give a private 4-player instance without matchmaking complexity.
- The lobby stays visually rich and social; the map stays performance-tight.
- Streaming settings differ radically between the two.

### 2.2 Teleport flow

```
LOBBY SERVER                                   MATCH SERVER
────────────                                   ────────────
Player forms party (1-4) in PartyService
Host picks map + mutators, presses START
  │
  ├─ PartyService validates:
  │    • host has mapId unlocked
  │    • each member's profile loaded & active
  │    • each member not already in a teleport
  │
  ├─ DataService:Release(player) for each member   ← CRITICAL: release the
  │    (explicit save + session-lock release)         session lock BEFORE
  │                                                    teleporting
  ├─ code = TeleportService:ReserveServer(MATCH_PLACE_ID)
  │
  └─ TeleportService:TeleportToPrivateServer(
        MATCH_PLACE_ID, code, members,
        nil, { MapId = mapId, MutatorIds = {...}, PartyId = guid }
     )
                                          ──────►  MatchService:Init reads
                                                   TeleportData via
                                                   player:GetJoinData().TeleportData

                                                   Validates: MapId exists in Config,
                                                   MutatorIds all exist.
                                                   ✗ NEVER trusts it for entitlements.

                                                   Reads each player's OWN profile for
                                                   equipped weapon + perks. If a player
                                                   somehow has an unowned item equipped,
                                                   silently substitute the default.

                                                   Run executes.
                                                   On end: award Crowns/XP, commit
                                                   challenge progress, SAVE, RELEASE.
                                          ◄──────  TeleportService:Teleport back to
                                                   LOBBY_PLACE_ID with
                                                   { LastRunSummary = {...} }
```

**Teleport data is a hint, never an authority.** Map and mutator ids get existence-validated against Config. Everything about what a player owns is re-read from their profile on the match server.

**Failure handling:** wrap `TeleportAsync` in `pcall` with 3 retries and exponential backoff. On total failure, show a lobby toast and do not consume anything. `TeleportInitFailed` on the client shows a retry button.

### 2.3 Place settings

| Setting | Lobby | Match |
|---|---|---|
| `StreamingEnabled` | true | true |
| `StreamingTargetRadius` | 512 | 1024 (maps are small; keep the whole battlefield loaded) |
| Map models | — | `ModelStreamingMode = Persistent` on castle + all build slots |
| Max players | 12 | 4 |
| Respawn | Custom (no auto-respawn; ChampionService owns it) | Custom |
| `Players.CharacterAutoLoads` | true | **false** — ChampionService spawns champions |

---

## 3. FULL INSTANCE TREE

### 3.1 Shared (identical in both places — keep them in sync via Rojo or a copy script)

```
ReplicatedStorage/
  Shared/
    Config.luau            -- ALL tunable numbers (§5)
    Types.luau             -- shared type exports (§4)
    Net.luau               -- remote creation/lookup wrapper
    Signal.luau            -- pure-Luau signal
    Trove.luau             -- lifetime cleanup
    Guard.luau             -- argument validation
    RateLimit.luau         -- token bucket per player per remote
    Cooldown.luau          -- server-side cooldown map
    Util/
      TableUtil.luau       -- deepCopy, reconcile
      NumberUtil.luau      -- abbreviate, lerp, round
      SpatialGrid.luau     -- uniform grid for target queries (§11.5)
      Pool.luau            -- instance pool
      Buttonify.luau       -- button hover/press micro-tweens
  Assets/
    Buildings/             -- one model per building type per level
    Enemies/               -- one MeshPart/model per enemy type (NO Humanoid)
    Units/                 -- allied unit models
    VFX/                   -- pooled effect templates
    UI/                    -- ScreenGui templates
  Remotes/                 -- Folder, populated at runtime by Net
```

### 3.2 Lobby place

```
ServerScriptService/
  Server                          -- Script (the ONLY server entry point)
  Services/
    DataService.luau              -- session-locked profile pipeline
    LoadoutService.luau           -- equip weapon/perks, validate ownership
    ShopService.luau              -- Crown purchases
    ChallengeService.luau         -- daily challenge issue + claim
    PartyService.luau             -- party formation + reserved-server teleport
    ProgressionService.luau       -- XP, levels, unlock gating
    LeaderboardService.luau       -- OrderedDataStore top-100, cached
    MonetizationService.luau      -- ProcessReceipt, game passes
    AnalyticsService.luau         -- funnels + economy events
    LobbyPresenceService.luau     -- returning-run summary, toasts
StarterPlayer/StarterPlayerScripts/
  Client                          -- LocalScript (the ONLY client entry point)
  Controllers/
    UIController.luau             -- screen registry, layer management
    LoadoutController.luau
    ShopController.luau
    ChallengeController.luau
    PartyController.luau
    KioskController.luau          -- proximity prompts on lobby kiosks
    CameraController.luau         -- lobby camera (standard, unmodified)
    AudioController.luau
StarterGui/
  HUD, LoadoutScreen, ShopScreen, ChallengeScreen, PartyScreen,
  MapSelectScreen, ResultsScreen, SettingsScreen
Workspace/
  Lobby/                          -- the hub model
    Kiosks/                       -- tagged Parts: Weapons, Perks, Champions, Challenges, Codex
    PlayPortal/
    Leaderboards/
```

### 3.3 Match place

```
ServerScriptService/
  Server                          -- Script (the ONLY server entry point)
  Services/
    DataService.luau              -- SAME module as lobby
    MatchService.luau             -- the phase state machine (§7) — the spine
    BuildService.luau             -- §8
    EconomyService.luau           -- §9
    WaveService.luau              -- §10
    EnemyService.luau             -- §11  (--!native)
    CombatService.luau            -- §12
    ChampionService.luau          -- §13
    UnitService.luau              -- §14
    TowerService.luau             -- §15
    UpgradeService.luau           -- §16
    MutatorService.luau           -- applies global modifiers
    ChallengeTracker.luau         -- in-run counters, committed at end
    RewardService.luau            -- Crowns/XP payout, results payload
    AnalyticsService.luau
StarterPlayer/StarterPlayerScripts/
  Client                          -- LocalScript
  Controllers/
    UIController.luau
    BuildController.luau          -- slot ghosts, prompts, build UI
    CombatController.luau         -- ability input, hit VFX, damage numbers
    CameraController.luau         -- scriptable top-down (§13.5)
    UnitController.luau           -- rally flag dragging
    HUDController.luau            -- gold, night counter, wave preview, castle HP
    VFXController.luau            -- pooled client-side effects
    AudioController.luau          -- day/night music crossfade
ServerStorage/
  Maps/
    Map_Greenhollow/              -- Model; tagged slots, lanes, spawns (§23)
    Map_Ashridge/
    Map_Frostmere/
    Map_Blackfen/
```

### 3.4 Bootstrap (both places, identical pattern)

```lua
-- ServerScriptService/Server (Script)
--!strict
local ServerScriptService = game:GetService("ServerScriptService")

local servicesFolder = ServerScriptService:WaitForChild("Services")
local services: { [string]: any } = {}

for _, child in servicesFolder:GetDescendants() do
	if child:IsA("ModuleScript") then
		local ok, result = pcall(require, child)
		if ok then services[child.Name] = result
		else warn(`[Bootstrap] require failed {child:GetFullName()}: {result}`) end
	end
end

for name, service in services do
	if type(service) == "table" and type(service.Init) == "function" then
		local ok, err = pcall(service.Init, service)
		if not ok then warn(`[Bootstrap] {name}.Init failed: {err}`) end
	end
end

for name, service in services do
	if type(service) == "table" and type(service.Start) == "function" then
		task.spawn(function()
			local ok, err = pcall(service.Start, service)
			if not ok then warn(`[Bootstrap] {name}.Start failed: {err}`) end
		end)
	end
end
```

Rules: `Init` never yields and never starts behavior — it caches references, creates remotes, and registers listeners. `Start` begins runtime behavior in its own thread. Because all `Init`s complete before any `Start`, load order bugs are impossible.

**Dependency direction:** Services → Services and Shared. Controllers → Controllers and Shared. Nothing in `Shared` ever requires a Service or Controller.

---

## 4. `Types.luau` — THE SHARED TYPE CONTRACT

```lua
-- ReplicatedStorage/Shared/Types.luau (ModuleScript)
--!strict

-- ─── Enemy / combat tags ───────────────────────────────────────────
export type DamageTag = "Normal" | "Flying" | "Fast" | "Siege" | "Monster" | "Armored" | "Boss"

export type EnemyDef = {
	Id: string,
	Display: string,
	Family: "Human" | "Monster" | "Siege" | "Boss",
	Tags: { DamageTag },
	Hp: number,
	Damage: number,          -- per attack
	AttackInterval: number,  -- seconds
	AttackRange: number,     -- studs
	Speed: number,           -- studs/sec
	GoldDrop: number,
	Model: string,           -- key into Assets/Enemies
	TargetPriority: "Nearest" | "Buildings" | "Castle" | "Players",
	Flying: boolean,         -- flying units ignore walls and lane ground offsets
}

-- ─── Buildings ─────────────────────────────────────────────────────
export type SlotType =
	"Castle" | "House" | "Mill" | "Field" | "GoldMine" | "Harbour"
	| "Tower" | "Wall" | "Barracks" | "ArcheryRange" | "HeroQuarters"
	| "Blacksmith" | "RoyalForge" | "Temple"

export type BuildingLevelDef = {
	Cost: number,
	Hp: number,
	Income: number?,          -- gold paid each morning
	AttackDamage: number?,    -- towers/castle
	AttackInterval: number?,
	AttackRange: number?,
	ProjectileSpeed: number?,
	UnitCount: number?,       -- barracks / archery range
	UnitId: string?,
	UpgradeChoices: { string }?, -- ids into Config.Upgrades, presented as a choice
}

export type BuildingDef = {
	Id: SlotType,
	Display: string,
	Category: "Economy" | "Defense" | "Military" | "Special",
	Levels: { BuildingLevelDef },
	Model: string,
}

-- ─── Runtime slot state (server memory only, never saved) ──────────
export type SlotState = {
	SlotId: string,
	SlotType: SlotType,
	Level: number,             -- 0 = unbuilt
	Hp: number,
	MaxHp: number,
	Destroyed: boolean,        -- destroyed last night → no income this morning
	ChosenUpgrades: { string },
	Position: Vector3,
	Model: Model?,
	Anchor: BasePart,          -- the authored slot part
}

-- ─── Champions & weapons ───────────────────────────────────────────
export type WeaponDef = {
	Id: string,
	Display: string,
	Range: number,
	Damage: number,
	Cooldown: number,
	Aoe: number?,              -- radius; nil = single target
	Multipliers: { [DamageTag]: number },
	Ability: {
		Id: string,
		Cooldown: number,
		Display: string,
		Description: string,
	},
	UnlockCost: number,        -- Crowns
	UnlockLevel: number,
}

export type ChampionDef = {
	Id: string,
	Display: string,
	Hp: number,
	WalkSpeed: number,
	SprintSpeed: number,
	DefaultWeapon: string,
	AuraType: "WallHp" | "TowerRange" | "UnitDamage" | "UnitRegen",
	AuraRadius: number,
	AuraValue: number,
	UnlockCost: number,
}

-- ─── Waves & maps ──────────────────────────────────────────────────
export type WaveEntry = {
	EnemyId: string,
	Count: number,
	SpawnIndex: number,    -- which authored spawn point
	StartDelay: number,    -- seconds after night start
	Interval: number,      -- seconds between individuals
	Elite: boolean?,
}

export type NightDef = {
	Night: number,
	Entries: { WaveEntry },
	IsBoss: boolean?,
}

export type MapDef = {
	Id: string,
	Display: string,
	Theme: string,
	Difficulty: "Easy" | "Medium" | "Hard" | "VeryHard",
	StartGold: number,
	Nights: { NightDef },
	UnlockLevel: number,
	NoWaveGoldUntilNight: number?,  -- some maps pay no enemy gold early
}

-- ─── Meta ──────────────────────────────────────────────────────────
export type ChallengeKind =
	"CompleteMap" | "UseWeapon" | "KillEnemies" | "SurviveNights"
	| "NoBuildingLost" | "PlayCoop" | "BuildCount" | "CompleteWithMutator"

export type ChallengeDef = {
	Id: string,
	Kind: ChallengeKind,
	Display: string,
	Target: number,
	Param: string?,          -- mapId / weaponId / mutatorId / enemyFamily
	CrownReward: number,
	XpReward: number,
}

export type PlayerData = {
	Crowns: number,
	Xp: number,
	Level: number,
	UnlockedWeapons: { [string]: boolean },
	UnlockedPerks: { [string]: boolean },
	UnlockedChampions: { [string]: boolean },
	UnlockedMaps: { [string]: boolean },
	Equipped: {
		Champion: string,
		Weapon: string,
		Perks: { string },
		CastleSkin: string,
	},
	Challenges: {
		Day: number,                       -- UTC day index the set was issued for
		Progress: { [string]: number },
		Claimed: { [string]: boolean },
		Streak: number,
		LastCompleteDay: number,
	},
	Codex: { [string]: boolean },          -- enemy/building ids seen
	Stats: {
		RunsPlayed: number,
		RunsWon: number,
		BestScore: { [string]: number },   -- per map
		TotalKills: number,
		NightsSurvived: number,
	},
	Settings: { Music: number, Sfx: number, ReduceEffects: boolean },
	PurchaseIds: { string },
	Meta: { Version: number, FirstJoin: number, Playtime: number },
}

return nil
```

---

## 5. `Config.luau` — SCHEMA AND BALANCE

The full starter file is delivered alongside this document as `Config.luau`. Its top-level shape:

```
Config.Version
Config.Match      -- phase timings, AFK failsafe, co-op scaling formulas
Config.Economy    -- starting gold, drop values, income rules
Config.Buildings  -- every SlotType → BuildingDef with per-level tables
Config.Upgrades   -- the 30+ branching upgrade choices
Config.Enemies    -- every EnemyDef
Config.Damage     -- the tag multiplier matrix (the heart of combat design)
Config.Weapons    -- 6 weapons with abilities
Config.Champions  -- 4 champions
Config.Units      -- allied unit defs
Config.Perks      -- 20 perks
Config.Mutators   -- 8 mutators
Config.Maps       -- 4 maps with complete night-by-night wave tables
Config.Challenges -- challenge pool + reward curve
Config.Progression-- XP curve, Crown payout formula, unlock costs
Config.Monetize   -- pass/product ids and effects
Config.UI         -- palette, corner radius, rarity colors
Config.Perf       -- caps: max enemies, pool sizes, tick rates
```

### 5.1 The damage multiplier matrix (design core)

Every weapon, unit, and tower attack resolves as:
`finalDamage = baseDamage × Config.Damage[attackerProfile][defenderTag] × upgradeMults × perkMults × mutatorMults`

| Attacker profile | Normal | Flying | Fast | Siege | Monster | Armored | Boss |
|---|---|---|---|---|---|---|---|
| `HeavyMelee` (Warden greatsword) | 1.0 | 0.0 | 0.7 | 1.4 | 1.0 | 1.2 | **3.0** |
| `LightMelee` (Marshal spear) | 1.0 | 0.5 | **2.0** | 0.8 | 1.0 | 0.7 | 2.0 |
| `Bow` (Ranger) | 1.0 | **2.2** | 1.2 | 0.5 | 1.0 | 0.6 | 2.0 |
| `Crossbow` | 1.0 | 1.0 | 0.7 | 1.0 | 1.0 | **1.8** | 1.5 |
| `Magic` (Alchemist) | 1.0 | 1.2 | 1.0 | 0.6 | **1.8** | 1.0 | 1.0 |
| `TowerArrow` | 1.0 | 1.3 | 0.8 | 1.0 | 1.0 | 0.8 | 1.0 |
| `TowerBallista` | 1.0 | 0.6 | 0.5 | **2.5** | 1.0 | **2.0** | 1.5 |
| `TowerFire` | 1.0 | 1.0 | 1.4 | 1.0 | 1.4 | 0.7 | 1.0 |

**Zeros and 2x+ values are the design.** The Warden literally cannot hit flying enemies — that forces the party to bring or build anti-air, which is what makes composition a real decision. Do not soften these into a flat 0.9–1.1 band; that would delete the game's strategy.

### 5.2 Global scale conventions

| Quantity | Convention |
|---|---|
| HP | Thronefall value × 5 (champion 500, wall 1200, castle 2000) |
| Damage | Thronefall value × 5 (ratios preserved exactly) |
| Gold costs | **1:1, unchanged.** Small readable numbers (1–25) are a feature. Never inflate in-run gold. |
| Movement | studs/sec. Champion 18 walk / 28 sprint. Allied units 9. Enemies = TF speed × 1.8, capped at 30. |
| Ranges | studs. Melee 12, spear 18, bow 55, tower 60–90. |
| Crowns | The big number. 200–900 per run. Unlocks cost 1,000–8,000. |

---

## 6. DATA MODEL

### 6.1 Rules
1. **Run state is never saved.** Gold, built slots, night number, enemy state, wave progress — server memory only, discarded when the run ends. A run is 12 minutes; persisting it invites the entire class of rollback bugs for no benefit.
2. **Profile is the only saved thing**, and it moves through one session-locked pipeline: `UpdateAsync` only (never `SetAsync`), reconcile-with-template on load, autosave, save on leave, `BindToClose`.
3. **A DataStore error is never treated as "new player."** The template is used only when a *successful* read returns `nil`. On error: kick with a reassuring message. This single rule prevents the wipe bug class.
4. **Explicit release before teleport.** `DataService:Release(player)` saves and clears the session lock before any teleport between lobby and match. Without this, players wait ~7s on the far side while the lock expires.

### 6.2 DataService additions beyond the standard pipeline

```lua
-- Release for teleport: save, drop the lock, mark inactive.
function DataService:Release(player: Player): boolean
	local profile = profiles[player]
	if not profile or not profile._active then return false end
	profile._active = false
	profiles[player] = nil
	save(profile, true)   -- releasing = true clears SessionLock
	return true
end

-- Batch release for a party teleport; returns only when all are released.
function DataService:ReleaseMany(players: { Player }): ()
	local pending = #players
	for _, player in players do
		task.spawn(function()
			self:Release(player)
			pending -= 1
		end)
	end
	local timeout = os.clock() + 8
	while pending > 0 and os.clock() < timeout do task.wait(0.1) end
end
```

### 6.3 Store naming
```lua
local STORE_NAME = if RunService:IsStudio() then "KN_PlayerData_Studio" else "KN_PlayerData_v1"
```
Never rename this to "fix" something. Renaming is a wipe from the players' perspective. Structural changes go through the migration table.

### 6.4 Migration table
```lua
local MIGRATIONS: { [number]: (data: any) -> () } = {
	-- [1] = function(data) ... data.Meta.Version becomes 2 ... end,
}
```
Forward-only, runs once per player at load, after reconcile. Never ship old code after new-format data exists.

---

## 7. THE MATCH STATE MACHINE

`MatchService` is the spine of the match place. Every other match service is driven by it.

### 7.1 States

```
                  ┌──────────┐
                  │ LOADING  │  map cloned in, slots registered, champions spawned,
                  └────┬─────┘  players' loadouts read from profiles
                       ▼
              ┌────────────────┐
   ┌─────────►│      DAY       │  no timer. Build/upgrade. Rally flags movable.
   │          │   (night N)    │  Wave preview visible at each spawn point.
   │          └────────┬───────┘  Ends when: all alive players Ready
   │                   │           OR AFK failsafe (§7.4)
   │                   ▼
   │          ┌────────────────┐
   │          │     NIGHT      │  wave spawns, combat, coin drops.
   │          │   (night N)    │  Ends when: last enemy dead
   │          └────────┬───────┘  OR castle destroyed → DEFEAT
   │                   │
   │                   ▼
   │          ┌────────────────┐
   │          │    MORNING     │  6s scripted beat:
   │          │   (night N)    │  1. rebuild destroyed slots (free)
   │          └────────┬───────┘  2. pay income (skip slots destroyed last night)
   │                   │           3. research ticks
   │            ┌──────┴──────┐    4. score popup
   │            │             │    5. revive dead champions
   │       N < last       N == last
   │            │             │
   └────────────┘             ▼
                       ┌────────────┐
                       │  VICTORY   │
                       └─────┬──────┘
                             ▼
                     ┌───────────────┐
   DEFEAT ──────────►│    RESULTS    │ Crowns + XP awarded, challenges committed,
                     └───────┬───────┘ profiles saved, then released
                             ▼
                     teleport back to lobby
```

### 7.2 Public API

```lua
-- ServerScriptService/Services/MatchService.luau
--!strict
export type Phase = "Loading" | "Day" | "Night" | "Morning" | "Victory" | "Defeat" | "Results"

MatchService.PhaseChanged   -- Signal(phase: Phase, night: number)
MatchService.NightStarted   -- Signal(night: number)
MatchService.NightCleared   -- Signal(night: number, stats: NightStats)
MatchService.RunEnded       -- Signal(won: boolean, summary: RunSummary)

MatchService:GetPhase(): Phase
MatchService:GetNight(): number
MatchService:GetRunState(): RunState     -- server-only accessor
MatchService:IsAcceptingBuilds(): boolean -- true only during Day
```

### 7.3 Run state (one table, server memory, never saved)

```lua
type RunState = {
	MapId: string,
	MutatorIds: { string },
	Phase: Phase,
	Night: number,
	MaxNights: number,
	Gold: number,                          -- SHARED across all players
	Slots: { [string]: Types.SlotState },
	PlayerCount: number,                   -- snapshot at run start, for wave scaling
	Players: { [Player]: PlayerRunState },
	Score: number,
	StartClock: number,
	Research: { [string]: { NightsRemaining: number } },
}

type PlayerRunState = {
	ChampionId: string,
	WeaponId: string,
	Perks: { string },
	Hp: number,
	MaxHp: number,
	Alive: boolean,
	Ready: boolean,                        -- day-phase ready flag
	Kills: number,
	GoldCollected: number,
	BuildsMade: number,
	Trove: any,
}
```

### 7.4 Day phase — ready system and AFK failsafe

Thronefall's day has no timer. In co-op you must preserve that while preventing one AFK player from freezing three others.

```
• Each alive player has a Ready toggle. The HUD shows "2/4 ready".
• Night starts when ALL connected players are Ready.
• AFK failsafe: a player with no input for Config.Match.AfkSeconds (180)
  is auto-marked Ready and flagged AFK. The flag clears on any input.
• Absolute ceiling: Config.Match.MaxDaySeconds (300). At 240s a countdown
  banner appears; at 300s the night starts regardless.
```

Input tracking for AFK: client fires `Match_Heartbeat` at most once every 5 seconds while the player has provided input; server stamps `lastInput`. Rate-limited at 0.5/s. This remote carries no payload — it cannot be abused for anything.

### 7.5 Morning sequence (exact order — order matters)

```lua
local function runMorning(night: number)
	setPhase("Morning", night)

	-- 1. Rebuild everything destroyed last night, free, at its prior level.
	for _, slot in state.Slots do
		if slot.Level > 0 and slot.Hp <= 0 then
			BuildService:Restore(slot)      -- restores at same level, full HP
			slot.Destroyed = true           -- flag consumed in step 2
		else
			slot.Hp = slot.MaxHp            -- surviving buildings heal to full
			slot.Destroyed = false
		end
	end

	-- 2. Pay income — SKIPPING buildings that were destroyed last night.
	local income = 0
	for _, slot in state.Slots do
		if slot.Level > 0 and not slot.Destroyed then
			income += EconomyService:GetIncome(slot)
		end
	end
	EconomyService:AddGold(income, "MorningIncome")

	-- 3. Advance research (Blacksmith / Royal Forge / Temple)
	UpgradeService:TickResearch()

	-- 4. Score for the night: surviving buildings + kill bonus, × mutator mult
	local nightScore = ScoreService:ScoreNight(night)
	state.Score += nightScore

	-- 5. Revive all dead champions at the castle, full HP
	ChampionService:ReviveAll()

	-- 6. Broadcast a full state sync and a morning summary for the UI
	Net.event("Match_Morning"):FireAllClients({
		Night = night, Income = income, Score = nightScore, Total = state.Score,
	})

	task.wait(Config.Match.MorningSeconds)  -- 6
	if night >= state.MaxNights then
		endRun(true)
	else
		state.Night = night + 1
		setPhase("Day", state.Night)
	end
end
```

**The `Destroyed` flag is the single most important line in this function.** It is the entire "forgiveness with a cost" mechanic: nothing is permanently lost, but a bad night hurts your economy the next morning.

### 7.6 State replication

One `Match_State` remote fires a **full state snapshot** (not deltas) to all clients on every phase change, and a light `Match_Tick` at 10 Hz during Night carrying only gold, castle HP, and remaining enemy count.

Full snapshots over deltas is deliberate: idempotent application means a dropped packet or a late joiner never desyncs. The payload is small (slot states are ~30 entries of 5 numbers).

```lua
-- Snapshot shape
{
	Phase = "Day", Night = 3, MaxNights = 13, Gold = 14, Score = 4200,
	Slots = { ["twr_01"] = { L = 2, Hp = 640, MaxHp = 800, Up = {"sniper"} }, ... },
	Players = { [userId] = { Hp = 500, Ready = false, Champ = "warden" }, ... },
	Preview = { { SpawnIndex = 1, Icons = {{Id="swordsman", Count=8}, ...} }, ... },
}
```

---

## 8. BUILDSERVICE — SLOTS, CONSTRUCTION, UPGRADES

### 8.1 Slot registration (map load)

Every build slot is an anchored, invisible `Part` inside the map model, tagged `BuildSlot` via `CollectionService`, carrying attributes:

| Attribute | Type | Example |
|---|---|---|
| `SlotType` | string | `"Tower"` |
| `SlotId` | string | `"twr_04"` (stable, unique within the map) |
| `MaxLevel` | number | `3` |
| `StartLevel` | number | `0` (castle uses `1`) |

```lua
function BuildService:LoadMap(mapModel: Model)
	for _, part in CollectionService:GetTagged("BuildSlot") do
		if not part:IsDescendantOf(mapModel) then continue end
		local slotId = part:GetAttribute("SlotId") :: string
		local slotType = part:GetAttribute("SlotType") :: Types.SlotType
		assert(Config.Buildings[slotType], `Unknown SlotType {slotType} on {part:GetFullName()}`)
		state.Slots[slotId] = {
			SlotId = slotId, SlotType = slotType,
			Level = part:GetAttribute("StartLevel") or 0,
			Hp = 0, MaxHp = 0, Destroyed = false, ChosenUpgrades = {},
			Position = part.Position, Model = nil, Anchor = part,
		}
	end
end
```

That is the whole system. **A new map is a model file plus one Config entry — zero new code.** This is why the "you can't choose where to build" constraint is worth keeping: it converts level design into content work and makes weekly liveops maps realistic.

### 8.2 Build / upgrade request — the hardened handler

Follows the mandatory shape: **rate → shape → possibility → mutate → respond.**

```lua
Net.event("Build_Request").OnServerEvent:Connect(function(player, rawSlotId)
	-- 1. Rate
	if not RateLimit.check(player, "Build", 4, 6) then return end

	-- 2. Shape
	local slotId = Guard.string(rawSlotId, 32)
	if not slotId then return end
	local slot = state.Slots[slotId]
	if not slot then return end

	-- 3. Possibility — every check server-side, from server-known state
	if state.Phase ~= "Day" then return end
	local prs = state.Players[player]
	if not prs or not prs.Alive then return end

	local root = ChampionService:GetRoot(player)
	if not root then return end
	if (root.Position - slot.Position).Magnitude > Config.Match.BuildRange + 8 then return end

	local def = Config.Buildings[slot.SlotType]
	local nextLevel = slot.Level + 1
	local levelDef = def.Levels[nextLevel]
	if not levelDef then return end                       -- already max
	if nextLevel > 1 and not UpgradeService:IsUnlocked(slot, nextLevel) then return end

	local cost = EconomyService:GetBuildCost(slot, nextLevel)  -- server computes; client never sends price

	-- 4. Mutate — take payment first, then grant
	if not EconomyService:TrySpend(cost, `Build:{slot.SlotType}:{nextLevel}`) then
		Net.event("Build_Result"):FireClient(player, slotId, false, "NotEnoughGold")
		return
	end
	BuildService:Construct(slot, nextLevel, player)
	prs.BuildsMade += 1
	ChallengeTracker:Increment(player, "BuildCount", 1)

	-- 5. Respond
	Net.event("Build_Result"):FireClient(player, slotId, true)
	Net.event("Build_Placed"):FireAllClients(slotId, nextLevel, player.UserId)  -- VFX for everyone
end)
```

Note the two things the client never sends: **the price** and **the resulting state**. It sends a slot id; the server looks everything else up in Config.

### 8.3 Construct

```lua
function BuildService:Construct(slot: Types.SlotState, level: number, builder: Player?)
	local def = Config.Buildings[slot.SlotType]
	local levelDef = def.Levels[level]

	if slot.Model then slot.Model:Destroy() end
	local model = Assets.Buildings[def.Model][`L{level}`]:Clone()
	model:PivotTo(CFrame.new(slot.Position) * CFrame.Angles(0, slot.Anchor.Orientation.Y, 0))
	model.Parent = workspace.Buildings
	for _, part in model:GetDescendants() do
		if part:IsA("BasePart") then
			part.Anchored = true
			part.CanQuery = false          -- buildings are never raycast targets
			part.CanTouch = false
		end
	end

	slot.Model = model
	slot.Level = level
	slot.MaxHp = levelDef.Hp * UpgradeService:GetHpMultiplier(slot)
	slot.Hp = slot.MaxHp

	if levelDef.AttackDamage then TowerService:Register(slot) end
	if levelDef.UnitId then UnitService:SetGarrison(slot, levelDef.UnitId, levelDef.UnitCount) end
	if levelDef.UpgradeChoices then UpgradeService:OfferChoice(slot, levelDef.UpgradeChoices) end
end
```

### 8.4 Client-side build affordance

`BuildController` runs a 10 Hz proximity check (never `Touched`, never per-frame):
- For each unbuilt/upgradable slot within `Config.Match.BuildRange` (24 studs) of the local champion, show a `BillboardGui` with icon, name, cost, and an affordability tint.
- The **nearest** eligible slot gets a highlighted ghost preview (semi-transparent model of what would be built) and is the active target.
- PC: `Space` builds it. Mobile: a large bottom-center **BUILD** button (thumb zone, ≥50px) appears.
- Greyed out with a red price if the shared gold can't cover it.

The ghost is purely cosmetic and client-side. The server re-checks range on the remote with an 8-stud latency grace.

---

## 9. ECONOMYSERVICE — SHARED GOLD

### 9.1 Rules
- **One shared gold pool per run.** All four players spend from it. This is the core co-op social tension and it is intentional — it generates conversation, which generates session length.
- Gold lives in `state.Gold`, a plain server number. Clients receive it in the 10 Hz `Match_Tick`. The client's displayed value is **display only** and is never used in any decision.
- Every mutation goes through `AddGold` / `TrySpend`. Nothing else touches `state.Gold`. This gives one grep-able audit trail and one place to hook analytics.

```lua
function EconomyService:AddGold(amount: number, reason: string)
	if amount ~= amount or amount == math.huge then return end   -- NaN/inf guard
	state.Gold += amount
	AnalyticsService:LogEconomy("Source", "Gold", amount, state.Gold, reason)
end

function EconomyService:TrySpend(amount: number, reason: string): boolean
	if amount <= 0 or amount ~= amount then return false end
	if state.Gold < amount then return false end
	state.Gold -= amount
	AnalyticsService:LogEconomy("Sink", "Gold", amount, state.Gold, reason)
	return true
end
```

### 9.2 Income sources

| Source | When | Amount |
|---|---|---|
| Starting gold | Run start | `Config.Maps[mapId].StartGold` |
| Building income | Every morning | Sum of `Income` for slots not destroyed last night |
| Enemy drops | On enemy death | `EnemyDef.GoldDrop × coopDropScale`, spawned as a physical coin |
| Gold mine | Every morning | 6, decrementing by 1 per night, floor 1 |
| Harbour boats | Every morning | 1 boat spawns (max 5), each pays 1 |

### 9.3 Coin drops — pooled, collected by riding over

Preserve the source design's tension: gold must be physically collected, pulling champions out of position.

```lua
-- One loop for ALL coins. Never Touched, never one script per coin.
local COIN_RADIUS = 8
local MAGNET_RADIUS = 20     -- coins drift toward a nearby champion
local overlapParams = OverlapParams.new()

RunService.Heartbeat:Connect(function(dt)
	for i = #activeCoins, 1, -1 do
		local coin = activeCoins[i]
		local nearest, dist = ChampionService:NearestChampion(coin.Position, MAGNET_RADIUS)
		if nearest then
			coin.Position = coin.Position:Lerp(nearest.Position, dt * 6)
			coin.Part.CFrame = CFrame.new(coin.Position)
			if dist < COIN_RADIUS then
				EconomyService:AddGold(coin.Value, "EnemyDrop")
				state.Players[nearest.Player].GoldCollected += coin.Value
				Net.unreliable("Fx_CoinCollected"):FireAllClients(coin.Position)
				coinPool:Return(coin.Part)
				table.remove(activeCoins, i)
			end
		elseif os.clock() - coin.SpawnedAt > Config.Economy.CoinLifetime then
			-- Coins auto-collect at night's end so players are never punished for
			-- coins that fell somewhere unreachable.
			EconomyService:AddGold(coin.Value, "EnemyDropExpired")
			coinPool:Return(coin.Part); table.remove(activeCoins, i)
		end
	end
end)
```

### 9.4 Co-op gold scaling

More players means more enemies (§10.3) means more drop gold, but build slots do **not** increase. Without correction, 4-player runs would be trivially rich. Correct at the drop:

```
enemyScale  = 1 + 0.35 × (playerCount - 1)      -- 1p 1.00, 4p 2.05
dropScale   = (0.70 × enemyScale + 0.30) / enemyScale
              -- 1p 1.000, 2p 0.922, 3p 0.876, 4p 0.846
```

Total wave gold therefore grows about 0.7× as fast as wave size. Four players get a bigger economy — but proportionally less than the threat scales, so co-op stays a real challenge.

Starting gold does **not** scale with player count.

---

## 10. WAVESERVICE — SPAWNS, PREVIEW, SCALING

### 10.1 Wave data lives in Config, per map, per night

```lua
Nights = {
	{ Night = 1, Entries = {
		{ EnemyId = "weakling", Count = 6, SpawnIndex = 1, StartDelay = 0, Interval = 0.8 },
	}},
	{ Night = 2, Entries = {
		{ EnemyId = "weakling", Count = 8, SpawnIndex = 1, StartDelay = 0,  Interval = 0.7 },
		{ EnemyId = "swordsman",Count = 3, SpawnIndex = 2, StartDelay = 6,  Interval = 1.2 },
	}},
	-- ...
}
```

Hand-authored waves, not procedural. This is the source design's approach and it is correct: a known wave is a puzzle the player solves, a random wave is a dice roll. Procedural generation belongs only in a future endless mode.

### 10.2 The preview (do not skip this)

During the day, each active spawn point displays a `BillboardGui` listing the enemy types and counts arriving that night, plus a directional marker on the HUD edge. Built directly from the same `Entries` table the spawner uses, so it can never disagree with reality.

This is what makes the game strategic rather than reactive. Players build *against known information*.

### 10.3 Co-op scaling

```lua
function WaveService:ScaleEntry(entry: Types.WaveEntry, playerCount: number): Types.WaveEntry
	local scale = 1 + Config.Match.CoopEnemyScalePerPlayer * (playerCount - 1)  -- 0.35
	return {
		EnemyId = entry.EnemyId,
		Count = math.max(1, math.round(entry.Count * scale)),
		SpawnIndex = entry.SpawnIndex,
		StartDelay = entry.StartDelay,
		Interval = entry.Interval / math.sqrt(scale),   -- bigger waves also arrive denser
		Elite = entry.Elite,
	}
end
```

`playerCount` is snapshotted at run start and **never recalculated mid-run**. If someone leaves on night 7, the remaining players get an easier ride — that is a feature, not a bug, and it avoids the exploit of stacking a party then dropping to farm.

### 10.4 Spawning

```lua
function WaveService:RunNight(night: number)
	local nightDef = Config.Maps[state.MapId].Nights[night]
	local pending = 0

	for _, rawEntry in nightDef.Entries do
		local entry = self:ScaleEntry(rawEntry, state.PlayerCount)
		entry = MutatorService:TransformEntry(entry)     -- elite god, wasp god, etc.
		pending += entry.Count
		task.spawn(function()
			task.wait(entry.StartDelay)
			for i = 1, entry.Count do
				if state.Phase ~= "Night" then return end
				EnemyService:Spawn(entry.EnemyId, entry.SpawnIndex, entry.Elite)
				task.wait(entry.Interval)
			end
		end)
	end

	state.PendingSpawns = pending
end
```

The night ends when `EnemyService:GetActiveCount() == 0` **and** all spawn threads have finished. Track both; ending on active-count alone races the spawner and ends night 1 instantly.

### 10.5 Elite variants
Elites are the same enemy with `Hp × 4`, `Damage × 3`, a colour tint, and a subtle particle aura. One flag on the spawn call, no separate defs. Cheapest difficulty content in the game.

---

## 11. ENEMYSERVICE — THE POOLED SIMULATION

**This is the system that decides whether the project ships.** A late wave is 120–180 concurrent enemies. Built naively — one `Model` with a `Humanoid` per enemy, driven by `PathfindingService` — the server dies at around 30.

### 11.1 The five rules

1. **No `Humanoid`.** Ever. An enemy is a single `MeshPart` (or a tiny welded model with one root) that is `Anchored = true`, `CanCollide = false`, `CanQuery = false`, `CanTouch = false`. You move it by assigning `CFrame`. This alone is the difference between 30 enemies and 300.
2. **No `PathfindingService` at runtime.** Each spawn point has authored waypoint lanes (§23.3). Enemies follow their lane with a small per-enemy lateral offset so they read as a horde, not a queue.
3. **One flat `Heartbeat` loop for all enemies**, not one script or coroutine per enemy.
4. **Pool everything** — enemy parts, projectiles, coins, hit VFX. Nothing is created or destroyed in steady state.
5. **Never fire a remote per enemy per frame.** Anchored part `CFrame` replicates natively. Remotes carry *events* only (spawned, damaged, died), and the client does the juice.

### 11.2 Entity representation

```lua
type Enemy = {
	Id: number,                -- dense index
	DefId: string,
	Def: Types.EnemyDef,
	Hp: number, MaxHp: number,
	Position: Vector3,
	Lane: { Vector3 },         -- shared reference, not a copy
	LaneIndex: number,
	LaneOffset: Vector3,       -- per-enemy lateral jitter
	Speed: number,
	Target: TargetRef?,        -- building slot / champion / unit
	AttackClock: number,
	Elite: boolean,
	Part: BasePart,            -- from the pool
	Flying: boolean,
}
```

Enemies live in one dense array `active`. Removal is swap-remove (`t[i] = t[#t]; t[#t] = nil`), never `table.remove` while iterating forward.

### 11.3 The tick

```lua
-- ServerScriptService/Services/EnemyService.luau
--!strict
--!native

local ATTACK_SEARCH_INTERVAL = 0.4   -- seconds between target re-acquisitions

local function stepAll(dt: number)
	local grid = SpatialGrid.rebuild(active)          -- one rebuild per tick, reused by TowerService
	targetGrid = grid

	for i = #active, 1, -1 do
		local e = active[i]

		if e.Hp <= 0 then
			onDeath(e)
			active[i] = active[#active]; active[#active] = nil
			continue
		end

		-- Re-acquire target periodically, not every frame
		e.SearchClock -= dt
		if e.SearchClock <= 0 then
			e.SearchClock = ATTACK_SEARCH_INTERVAL
			e.Target = acquireTarget(e)
		end

		local target = e.Target
		if target and isValid(target) then
			local delta = target.Position - e.Position
			local dist = delta.Magnitude
			if dist <= e.Def.AttackRange then
				e.AttackClock -= dt
				if e.AttackClock <= 0 then
					e.AttackClock = e.Def.AttackInterval
					CombatService:EnemyAttack(e, target)
				end
			else
				advance(e, delta.Unit, dt)
			end
		else
			advanceAlongLane(e, dt)
		end
	end
end

RunService.Heartbeat:Connect(function(dt)
	if state.Phase ~= "Night" then return end
	stepAll(dt)
end)
```

**No allocation inside this loop.** No table literals, no closures, no string concatenation. The grid is rebuilt into a reused buffer with `table.clear`. Any allocation here shows up as periodic frame spikes on mobile.

### 11.4 Lane following

```lua
local function advanceAlongLane(e: Enemy, dt: number)
	local lane = e.Lane
	local waypoint = lane[e.LaneIndex]
	if not waypoint then
		-- Lane exhausted → head for the castle directly
		e.Target = castleRef
		return
	end
	local goal = waypoint + e.LaneOffset
	local delta = goal - e.Position
	if delta.Magnitude < 4 then
		e.LaneIndex += 1
		return
	end
	advance(e, delta.Unit, dt)
end

local function advance(e: Enemy, dir: Vector3, dt: number)
	local step = dir * (e.Speed * dt)
	e.Position += Vector3.new(step.X, 0, step.Z)     -- ground enemies stay on the lane plane
	if e.Flying then
		e.Position = Vector3.new(e.Position.X, e.FlightHeight, e.Position.Z)
	end
	e.Part.CFrame = CFrame.lookAt(e.Position, e.Position + dir)
end
```

Flying enemies use a straight line from spawn to their target and ignore lanes and walls entirely. That is the whole reason anti-air matters.

### 11.5 Targeting and the spatial grid

Naive targeting is `O(enemies × targets)` per tick and will not hold. Use a uniform grid keyed by rounded X/Z, rebuilt once per tick:

```lua
-- ReplicatedStorage/Shared/Util/SpatialGrid.luau
local CELL = 32

function SpatialGrid.key(pos: Vector3): number
	return math.floor(pos.X / CELL) * 100000 + math.floor(pos.Z / CELL)
end

function SpatialGrid.query(grid, pos: Vector3, radius: number, out: { any }): { any }
	table.clear(out)
	local cells = math.ceil(radius / CELL)
	local cx, cz = math.floor(pos.X / CELL), math.floor(pos.Z / CELL)
	for dx = -cells, cells do
		for dz = -cells, cells do
			local bucket = grid[(cx + dx) * 100000 + (cz + dz)]
			if bucket then
				for _, item in bucket do table.insert(out, item) end
			end
		end
	end
	return out
end
```

A tower asking "who is in range?" checks ~9 buckets instead of 180 enemies. `TowerService` and `UnitService` both consume the same grid built by `EnemyService`, so it is built **once per tick, not three times**.

### 11.6 Target priority

```
Siege enemies      → nearest Building, ignore champions entirely
Standard enemies   → nearest of { Building, Unit, Champion } within aggro radius,
                     preferring whatever is blocking their lane
Flying enemies     → nearest Building, ignoring walls
Boss               → scripted per-phase targeting
"Chase" behaviour  → an enemy that has taken damage from a champion within the last
                     3s prefers that champion (makes kiting feel responsive)
```

### 11.7 Death

```lua
local function onDeath(e: Enemy)
	EconomyService:SpawnCoin(e.Position, math.round(e.Def.GoldDrop * dropScale))
	Net.unreliable("Fx_EnemyDied"):FireAllClients(e.Def.Id, e.Position)   -- client plays the pop
	CodexService:MarkSeen(e.DefId)
	if e.LastHitBy then
		state.Players[e.LastHitBy].Kills += 1
		ChallengeTracker:Increment(e.LastHitBy, "KillEnemies", 1, e.Def.Family)
	end
	enemyPool:Return(e.Part)
end
```

### 11.8 Hard caps (`Config.Perf`)

| Cap | Value | Behaviour on hit |
|---|---|---|
| `MaxActiveEnemies` | 200 | Spawner waits rather than exceeding |
| `EnemyPoolSize` | 220 | Pre-instanced at map load |
| `CoinPoolSize` | 150 | Oldest coin auto-collects |
| `ProjectilePoolSize` | 120 | Oldest despawns |
| Target design peak | **120–180** | Author waves to this, not to the cap |

Verify on a real mid-range Android device during Phase 2, not Phase 6. If the tick exceeds 4 ms at 180 enemies, the fix is fewer allocations and a coarser search interval — not fewer enemies.

---

## 12. COMBATSERVICE — DAMAGE RESOLUTION

**All damage is computed on the server. The client never reports a hit, a number, or a kill.**

### 12.1 The single damage function

Every source of damage in the game funnels through one function. This makes balance, analytics, and mutators trivially insertable.

```lua
function CombatService:ApplyDamage(source: DamageSource, target: TargetRef, baseDamage: number)
	local profile = source.DamageProfile              -- "HeavyMelee", "Bow", "TowerBallista", ...
	local tag = resolvePrimaryTag(target)             -- "Flying" | "Fast" | ... | "Normal"

	local mult = Config.Damage[profile][tag] or 1
	mult *= UpgradeService:GetDamageMultiplier(source)   -- blacksmith / forge research
	mult *= PerkService:GetDamageMultiplier(source)      -- equipped perks
	mult *= MutatorService:GetDamageMultiplier(source)   -- mutators

	local final = baseDamage * mult
	if final <= 0 then return 0 end                    -- e.g. HeavyMelee vs Flying = 0

	target.Hp -= final
	if source.Player then target.LastHitBy = source.Player end

	Net.unreliable("Fx_Hit"):FireAllClients(target.Position, final, tag, mult >= 2)
	return final
end
```

The `mult >= 2` flag drives a crit-style yellow damage number on the client — free feedback that teaches the counter system without a tutorial.

### 12.2 Champion auto-attack

The floor of the combat design: the player does not have to aim or click.

```lua
-- Inside ChampionService, one loop for all champions
RunService.Heartbeat:Connect(function(dt)
	if state.Phase ~= "Night" then return end
	for player, prs in state.Players do
		if not prs.Alive then continue end
		prs.AttackClock -= dt
		if prs.AttackClock > 0 then continue end

		local weapon = Config.Weapons[prs.WeaponId]
		local root = ChampionService:GetRoot(player)
		if not root then continue end

		local candidates = SpatialGrid.query(targetGrid, root.Position, weapon.Range, scratch)
		local best = nearestValid(candidates, root.Position, weapon)
		if not best then continue end

		prs.AttackClock = weapon.Cooldown * UpgradeService:GetCooldownMultiplier(player)
		if weapon.Aoe then
			for _, e in SpatialGrid.query(targetGrid, best.Position, weapon.Aoe, scratch2) do
				CombatService:ApplyDamage(sourceOf(player), e, weapon.Damage)
			end
		else
			CombatService:ApplyDamage(sourceOf(player), best, weapon.Damage)
		end
		Net.unreliable("Fx_Swing"):FireAllClients(player.UserId, best.Position)
	end
end)
```

### 12.3 Active abilities

Client sends intent only. Server owns cooldown, range, and effect.

```lua
Net.event("Combat_Ability").OnServerEvent:Connect(function(player, rawDir)
	if not RateLimit.check(player, "Ability", 2, 3) then return end
	local prs = state.Players[player]
	if not prs or not prs.Alive or state.Phase ~= "Night" then return end

	local weapon = Config.Weapons[prs.WeaponId]
	local cd = weapon.Ability.Cooldown * UpgradeService:GetAbilityCdMultiplier(player)
	if not Cooldown.try(player, "Ability", cd * 0.92) then return end   -- 8% latency grace

	local dir = Guard.vector3Unit(rawDir) or ChampionService:GetLookVector(player)
	AbilityHandlers[weapon.Ability.Id](player, dir)
	Net.event("Combat_AbilityUsed"):FireAllClients(player.UserId, weapon.Ability.Id, dir)
end)
```

`Guard.vector3Unit` rejects NaN, infinity, and non-unit vectors — a client sending `Vector3.new(math.huge, 0, 0)` must never reach an ability handler.

### 12.4 Champion damage and death

```lua
function CombatService:EnemyAttack(e: Enemy, target: TargetRef)
	local damage = e.Def.Damage * (if e.Elite then 3 else 1) * MutatorService:GetEnemyDamageMult()
	if target.Kind == "Champion" then
		local prs = state.Players[target.Player]
		prs.Hp -= damage * PerkService:GetResistanceMultiplier(target.Player)
		if prs.Hp <= 0 then ChampionService:Down(target.Player) end
	elseif target.Kind == "Building" then
		target.Slot.Hp -= damage
		if target.Slot.Hp <= 0 then BuildService:OnDestroyed(target.Slot) end
	elseif target.Kind == "Unit" then
		UnitService:Damage(target.Unit, damage)
	end
end
```

### 12.5 Champion down/revive (co-op)

Preserve the source design's "you can still move while dead" mechanic — and make it a co-op moment.

```
On HP ≤ 0:
  • Champion enters DOWNED: WalkSpeed drops to 8, cannot attack, cannot build,
    a ghost visual + a progress ring appear above them.
  • Auto-revive at the castle after Config.Match.DownedSeconds (12).
  • OR: another living champion standing within 10 studs for 3 continuous
    seconds revives them in place at 50% HP. HUD shows "HOLD TO REVIVE".
  • If ALL champions are downed, the night continues — towers and units keep
    fighting. It is not a loss. Only the castle falling is a loss.
```

The co-op revive is the single best social moment available in this design. Build it in Phase 3, not later.

---

## 13. CHAMPIONSERVICE — THE PLAYER CHARACTER

### 13.1 Spawn
`Players.CharacterAutoLoads = false`. `ChampionService` spawns each player's character at the castle when the run enters `Loading`, applies their champion's stats, and parents a weapon model.

```lua
function ChampionService:SpawnChampion(player: Player, championId: string)
	local def = Config.Champions[championId]
	player:LoadCharacter()
	local character = player.Character or player.CharacterAdded:Wait()
	local humanoid = character:WaitForChild("Humanoid") :: Humanoid

	humanoid.MaxHealth = def.Hp            -- Humanoid.Health is DISPLAY ONLY here;
	humanoid.Health = def.Hp               -- the authority is state.Players[p].Hp
	humanoid.WalkSpeed = def.WalkSpeed
	humanoid:SetStateEnabled(Enum.HumanoidStateType.Climbing, false)
	humanoid:SetStateEnabled(Enum.HumanoidStateType.Swimming, false)

	local root = character:WaitForChild("HumanoidRootPart") :: BasePart
	root:SetNetworkOwner(player)           -- champions are player-owned (Roblox latency model)
end
```

**Important:** champions keep normal player network ownership so movement feels right. Every *enemy* and *unit* uses `SetNetworkOwner(nil)` so the server owns them — that is both authority and smoothness.

Anti-speed-exploit: a 3 Hz position sanity check comparing distance moved against `sprintSpeed × elapsed × 1.5`. On violation, **snap back to the last valid position** rather than kicking — lag spikes cause false positives and rubber-banding is self-correcting.

### 13.2 Sprint
Hold `Shift` (PC) or a HUD button (mobile). `WalkSpeed` goes to `def.SprintSpeed`. Default restriction (from the source design): sprint only at full HP, unless the `AgileHorse` perk is equipped. Server sets `WalkSpeed`; the client never does.

### 13.3 Champion auras
Each champion projects a passive aura affecting nearby friendly things (§1.3 table). Evaluated in the same 10 Hz loop as other periodic work, never per-frame:

| Champion | Aura | Radius | Value |
|---|---|---|---|
| Warden | Nearby walls/towers gain HP | 60 | +15% max HP |
| Ranger | Nearby towers gain range | 60 | +20% range |
| Marshal | Nearby allied units deal more damage | 45 | +25% damage |
| Alchemist | Nearby allied units regenerate | 45 | 2% max HP/sec |

Auras give co-op parties a reason to position deliberately and make champion choice matter beyond the weapon.

### 13.4 Input map

| Action | PC | Mobile |
|---|---|---|
| Move | WASD | Default thumbstick |
| Sprint | Shift | HUD button (bottom-left) |
| Build / Upgrade (Day) | Space | Large **BUILD** button, bottom-center |
| Ability (Night) | Space | Large **ABILITY** button, bottom-right, with radial cooldown |
| Rally units to me | R | **RALLY** button, bottom-right stack |
| Ready up (Day) | Enter | **READY** button in the day panel |
| Unit group filter | 1 / 2 / 3 | Three tabs above the rally button |

Bind everything through `ContextActionService:BindAction` with `createTouchButton = true` so the mobile buttons come free and sit in the thumb zone. Minimum 50px tap targets, spaced so a fat finger can't hit Ability instead of Rally.

### 13.5 Camera

```lua
-- Controllers/CameraController.luau
local ANGLE = CFrame.Angles(math.rad(-55), 0, 0)   -- angled top-down
local DEFAULT_DISTANCE = 80
local MIN_DISTANCE, MAX_DISTANCE = 55, 115

camera.CameraType = Enum.CameraType.Scriptable
RunService:BindToRenderStep("KN_Camera", Enum.RenderPriority.Camera.Value, function(dt)
	local root = getLocalRoot(); if not root then return end
	local goal = CFrame.new(root.Position) * CFrame.Angles(0, yaw, 0) * ANGLE
	             * CFrame.new(0, 0, distance)
	camera.CFrame = camera.CFrame:Lerp(goal, 1 - math.exp(-dt * 12))
end)
```

Deviations from the source (which has a fixed no-zoom camera) — both are necessary for Roblox players:
- **Limited zoom** between 55 and 115 studs (scroll / pinch).
- **90° yaw snaps** (Q/E, or two-finger twist) so players can look behind terrain.
- **Auto-pull-back to 95** at nightfall, auto-return to 80 at morning. Free readability win and a great phase-change cue.

---

## 14. UNITSERVICE — ALLIED TROOPS AND RALLY POINTS

### 14.1 Why the source's control scheme is replaced

Thronefall ties all troop control to the hero's physical position (hold `R` to gather, `R` to release, hold `R` to set hold-position). It is the game's most criticised mechanic on PC and would be unusable on a phone, which is the majority of Roblox sessions.

**Replacement: rally flags, set during the day.**

### 14.2 Design

```
• Each Barracks / Archery Range / Hero's Quarters owns a RALLY FLAG.
• During the DAY, a player can drag that flag anywhere within
  Config.Match.RallyRadius (120 studs) of its building.
• Units walk to their flag and hold there, engaging anything in range
  (a "guard post" behaviour, not a chase-forever behaviour).
• A unit that chases an enemy more than 25 studs from its flag disengages
  and walks back. This prevents the classic tower-defense failure where
  your whole army gets pulled off-position by one fast enemy.
• HUD button RALLY TO ME: all units of the active group filter converge on
  the calling champion. Press again (or at morning) to send them back.
• Group filter: All / Melee / Ranged, as three tabs.
```

This keeps the tactical decision — *where do my troops stand?* — but moves it into the day phase, where there is no time pressure. That is more consistent with the design's own anti-stress philosophy than the original's control scheme.

### 14.3 Flag placement remote

```lua
Net.event("Unit_SetRally").OnServerEvent:Connect(function(player, rawSlotId, rawPos)
	if not RateLimit.check(player, "Rally", 4, 8) then return end
	if state.Phase ~= "Day" then return end
	local slotId = Guard.string(rawSlotId, 32); if not slotId then return end
	local slot = state.Slots[slotId]; if not slot then return end
	if not Config.Buildings[slot.SlotType].Levels[1].UnitId then return end

	local pos = Guard.vector3(rawPos); if not pos then return end
	-- Clamp into the legal radius rather than rejecting — better UX, same security
	local delta = pos - slot.Position
	if delta.Magnitude > Config.Match.RallyRadius then
		pos = slot.Position + delta.Unit * Config.Match.RallyRadius
	end
	pos = TerrainUtil.snapToGround(pos)          -- server-side raycast; no floating flags

	UnitService:SetRallyPoint(slot, pos)
	Net.event("Unit_RallyMoved"):FireAllClients(slotId, pos)
end)
```

Clamping rather than rejecting is deliberate: an honest client dragging slightly too far gets a sensible result, and an exploiter gains nothing.

### 14.4 Unit simulation

Units use the same architecture as enemies: **no `Humanoid`**, anchored parts, one flat `Heartbeat` loop, pooled models, `SetNetworkOwner(nil)`. Unit counts are far smaller (≤ 40) but sharing the architecture means one set of bugs, one profiler line, one mental model.

Units respawn at their building `Config.Units.RespawnSeconds` (14) after dying, and all units fully restore at morning.

---

## 15. TOWERSERVICE — BUILDING WEAPONS

Towers, upgraded houses, and the castle all shoot. One registry, one loop, consuming the grid `EnemyService` already built.

```lua
RunService.Heartbeat:Connect(function(dt)
	if state.Phase ~= "Night" then return end
	for i = 1, #armed do
		local t = armed[i]
		t.Clock -= dt
		if t.Clock > 0 then continue end

		local candidates = SpatialGrid.query(targetGrid, t.Position, t.Range, scratch)
		local target = pickTarget(candidates, t)     -- first-in-lane, or nearest for AoE towers
		if not target then continue end

		t.Clock = t.Interval
		ProjectileService:Fire(t, target)            -- pooled, server-authoritative travel
	end
end)
```

Projectiles are **pooled server-side parts with a travel time**, not instant hitscan. Travel time is what makes ballista towers feel heavy and lets fast enemies actually dodge into a wall of arrows — it is a meaningful part of the feel. Impact resolution calls `CombatService:ApplyDamage` with the tower's damage profile.

Client-side, `VFXController` draws its own tracer from the same event so the visual is instant while the server's authoritative projectile resolves.

---

## 16. UPGRADESERVICE — BRANCHING CHOICES

This is what gives each run its identity, and it is the most-skipped system in clones. Do not skip it.

### 16.1 Structure
- Certain buildings offer a **choice of upgrades** at a given level. The choice is **permanent for that run**.
- The choice UI appears at the moment of upgrade: a modal with 2–4 cards, each showing icon, name, and effect.
- **In co-op, only the player who paid for the upgrade chooses**, with a 12-second timer and an auto-pick default. Others see a spectator view of the cards. This prevents deadlock and keeps momentum.

### 16.2 Buildings that branch

| Building | Level | Choices |
|---|---|---|
| Castle | 2 | Royal Training (+75% champ HP & damage) / Builder's Guild (free house upgrade each morning, +50% HP) / Magic Armor (reflect damage, +150% HP) |
| Castle | 3 | Royal Mastery (+75% HP & damage) / Commander (units fight while rallied, +60% unit speed, healing aura) / Castle-Up (wall & tower upgrade costs −1 per night, min 1) |
| Tower | 2 | Castle Tower (+150 HP, faster) / Sniper (more damage, longer range, slower) / Armored (+350 HP, shield on hit) |
| Tower | 3 | Archer's Spire (extra arrow) / Ballistic Spire (huge damage, slows) / Fire Spire (splash + burn) / Healing Spire (heals allies, does not attack) |
| Mill | 1 | Improved Plow (+1 income per future upgrade) / Explosive Trap (explodes on destruction) / Scarecrows (free anti-air on its fields) |

### 16.3 Research buildings (Blacksmith / Royal Forge / Temple)

Research **takes nights to complete**. This is an excellent pacing mechanic — investing is a bet on surviving long enough to cash in.

```lua
function UpgradeService:TickResearch()
	for id, entry in state.Research do
		entry.NightsRemaining -= 1
		if entry.NightsRemaining <= 0 then
			applyResearch(id)
			state.Research[id] = nil
			Net.event("Research_Complete"):FireAllClients(id)
		end
	end
end
```

| Building | Options | Nights |
|---|---|---|
| Blacksmith (army-wide) | +20% melee dmg / +20% ranged dmg / +30% melee resist / +30% ranged resist | 3/3/2/2 |
| Royal Forge (champions) | −40% attack cooldown / +50% HP & regen / −40% ability cooldown / +40% weapon damage | 2/2/3/3 |
| Temple (high risk) | Overload (towers buffed but bleed HP) / Ice Rain (damages everything, including allies) / Wisdom (destroyed buildings drop gold, all buildings slowly lose HP) | 2/3/3 |

---

## 17. CO-OP RULES

The three things co-op changes, and the exact rule for each:

| Concern | Rule |
|---|---|
| **Gold** | One shared pool. Anyone can spend. Everyone sees every transaction as a floating toast ("Ali built a Tower — 3g"). Transparency prevents resentment. |
| **Wave size** | `1 + 0.35 × (players − 1)`, snapshotted at run start, never recalculated. |
| **Drop gold** | Scaled down by `(0.70 × enemyScale + 0.30) / enemyScale` so economy grows slower than threat. |
| **Upgrade choices** | Chosen by whoever paid. 12s timer, auto-pick default. |
| **Ready** | Night starts when all connected players are ready; AFK auto-ready at 180s; hard start at 300s. |
| **Downed champions** | Auto-revive at castle after 12s, or teammate revive in 3s of proximity. All-downed is not a loss. |
| **Disconnect mid-run** | Champion despawns; a ghost marker holds their slot for `RejoinWindowSeconds` (300). Their units stay under their rally flags. Wave scale does **not** drop. Remaining players continue. |
| **Rejoin (v2)** | **Supported.** The reserved-server code is written to MemoryStore keyed by UserId with a 20-minute TTL; the lobby shows a **REJOIN RUN** button. Rejoining restores the champion at the castle at full HP on the next morning. See §34.3. |
| **Leaver rewards** | Forfeit only if the player never rejoins *and* the run finishes without them (prevents "join party, leave, farm"). A disconnect that rejoins is paid normally. |
| **Friend bonus** | +10% Crowns at run end if 2+ players were present for the whole run. Cheap, and it makes people invite friends. |

### 17.1 Party formation (lobby)

> **v2 note:** private parties remain exactly as described below, but they are no longer the only path into a match. Public **Quick Play** matchmaking is specified in §34 and is the *default* entry point for a solo player. Read §34 before implementing PartyService.

```
• A player opens the PARTY kiosk → creates a party (they become host).
• A 6-character invite code is generated and shown; friends in the same lobby
  server can also see a "Join" button on a nearby party board.
• Party is server-side state in PartyService, keyed by a GUID. Max 4.
• Host picks map + mutators. Non-hosts see the selection live and can toggle Ready.
• START is enabled only when all members are Ready.
• Solo players press PLAY at the portal → instant single-member party, straight in.
```

Party state never lives on the client. The client sends `Party_Create`, `Party_Join(code)`, `Party_Leave`, `Party_SetReady`, `Party_SelectMap` — every one validated against server-side party state and host ownership.

---

## 18. LOBBY

### 18.1 Layout

A single small courtyard — a walk of no more than ~15 seconds end to end. Every kiosk is visible from spawn.

```
                    ┌─────────────────┐
                    │  PLAY PORTAL    │  ← large, glowing, dead-center-north
                    │  (map select)   │
                    └─────────────────┘
      ┌──────────┐   ┌──────────┐   ┌──────────┐   ┌──────────┐
      │ WEAPONS  │   │  PERKS   │   │CHAMPIONS │   │ CHALLENGES│
      └──────────┘   └──────────┘   └──────────┘   └──────────┘
                         ◇ SPAWN ◇
      ┌──────────┐                                 ┌──────────┐
      │  CODEX   │                                 │  PARTY   │
      └──────────┘                                 └──────────┘
                    ┌─────────────────┐
                    │  LEADERBOARDS   │
                    └─────────────────┘
```

Each kiosk is a `Part` tagged `Kiosk` with a `KioskType` attribute, using a `ProximityPrompt`. `KioskController` opens the matching screen. New kiosk = tagged part + one line in a map.

**FTUE routing:** a first-time player (`Stats.RunsPlayed == 0`) gets an arrow beam from spawn straight to the Play portal, and pressing it skips map select entirely — straight into the tutorial map, solo. Do not make a new player read a shop before they have played.

### 18.2 Returning from a run
`LobbyPresenceService` reads `player:GetJoinData().TeleportData.LastRunSummary` and immediately shows the **Results screen** with Crowns earned, XP bar filling, challenge progress ticking, and any newly-affordable unlock highlighted. That last element is the come-back hook made visible.

---

## 19. LOADOUTSERVICE & SHOPSERVICE

### 19.1 Loadout rules
- 1 champion, 1 weapon, up to N perks.
- Perk slots: **3 at level 1, 4 at level 8, 5 at level 20**, plus 1 from the Extra Perk Slot game pass (max 6).
- Equipping validates ownership every time. If a profile somehow contains an unowned equipped item (rollback, exploit attempt, config change), the match server silently substitutes the default rather than erroring.

```lua
Net.event("Loadout_Equip").OnServerEvent:Connect(function(player, rawKind, rawId)
	if not RateLimit.check(player, "Equip", 5, 10) then return end
	local kind = Guard.keyOf(rawKind, { Champion = true, Weapon = true, CastleSkin = true })
	if not kind then return end
	local profile = DataService:GetProfile(player); if not profile then return end

	local ownedMap = ({
		Champion = profile.Data.UnlockedChampions,
		Weapon = profile.Data.UnlockedWeapons,
		CastleSkin = profile.Data.UnlockedSkins,
	})[kind]
	local id = Guard.keyOf(rawId, ownedMap)     -- existence in the OWNED map, in one check
	if not id then return end

	profile.Data.Equipped[kind] = id
	Net.event("Loadout_Updated"):FireClient(player, profile.Data.Equipped)
end)
```

`Guard.keyOf(rawId, ownedMap)` doing ownership and type validation in one call is the pattern to reuse everywhere.

### 19.2 Perk equip
Same shape, plus: array length ≤ current slot count, no duplicates, every entry owned.

### 19.3 Shop (Crowns)

| Category | Items | Price band (Crowns) |
|---|---|---|
| Weapons | 6 total, 1 free | 1,000 – 5,000 |
| Perks | 20 total, 3 free | 600 – 3,000 |
| Champions | 4 total, 1 free | 4,000 – 8,000 |
| Castle skins | cosmetic | 2,000 – 6,000 |

```lua
Net.event("Shop_Buy").OnServerEvent:Connect(function(player, rawKind, rawId)
	if not RateLimit.check(player, "Buy", 2, 4) then return end
	local kind = Guard.keyOf(rawKind, Config.Shop.Catalogs); if not kind then return end
	local catalog = Config.Shop.Catalogs[kind]
	local id = Guard.keyOf(rawId, catalog); if not id then return end

	local profile = DataService:GetProfile(player); if not profile then return end
	local def = catalog[id]
	local ownedMap = ownedMapFor(profile, kind)
	if ownedMap[id] then return end                                     -- already owned
	if profile.Data.Level < def.UnlockLevel then
		Net.event("Shop_Result"):FireClient(player, id, false, "LevelLocked"); return
	end
	if profile.Data.Crowns < def.Cost then
		Net.event("Shop_Result"):FireClient(player, id, false, "NotEnoughCrowns"); return
	end

	profile.Data.Crowns -= def.Cost                    -- take payment
	ownedMap[id] = true                                -- then grant
	AnalyticsService:LogEconomy("Sink", "Crowns", def.Cost, profile.Data.Crowns, `Shop:{kind}:{id}`)
	Net.event("Shop_Result"):FireClient(player, id, true)
end)
```

The client never sends a price. It sends an id; the server looks up the cost.

---

## 20. CHALLENGESERVICE — DAILY CHALLENGES

### 20.1 Design

**Three challenges per day, identical for every player**, deterministically generated from the UTC day index. Everyone getting the same set means players can talk about them, which is worth more than personalised variety.

```lua
local function dayIndex(): number
	return math.floor(os.time() / 86400)
end

function ChallengeService:GetDailySet(day: number): { Types.ChallengeDef }
	local rng = Random.new(day * 7919)              -- deterministic per day, same on every server
	local pool = table.clone(Config.Challenges.Pool)
	local set = {}
	-- One challenge from each difficulty tier so the set is always Easy/Medium/Hard
	for _, tier in { "Easy", "Medium", "Hard" } do
		local tierPool = filterTier(pool, tier)
		local pick = tierPool[rng:NextInteger(1, #tierPool)]
		table.insert(set, materialise(pick, rng))   -- fills Param (mapId/weaponId) from the same rng
	end
	return set
end
```

Every server computes the same set from the same day index — no DataStore coordination needed, no drift.

### 20.2 Challenge kinds

| Kind | Example | Tracked where |
|---|---|---|
| `CompleteMap` | "Win a run on Ashridge" | Match, at victory |
| `UseWeapon` | "Win a run using the Longbow" | Match, at victory (checks equipped weapon) |
| `KillEnemies` | "Defeat 250 monsters" | Match, incremental on each kill |
| `SurviveNights` | "Survive 20 nights total" | Match, on each morning |
| `NoBuildingLost` | "Finish a night without losing a building" | Match, at morning |
| `PlayCoop` | "Complete a run with 2+ players" | Match, at victory |
| `BuildCount` | "Construct 30 buildings" | Match, on each build |
| `CompleteWithMutator` | "Win with any mutator active" | Match, at victory |

### 20.3 Tracking and commit

`ChallengeTracker` (match place) holds an in-memory counter table per player. **Nothing writes to the profile mid-run** — one commit at run end, inside the same in-memory transaction as the Crown award:

```lua
function ChallengeTracker:Commit(player: Player, won: boolean)
	local profile = DataService:GetProfile(player); if not profile then return end
	local today = dayIndex()
	local c = profile.Data.Challenges

	if c.Day ~= today then                          -- first run of a new day: roll the set
		c.Day, c.Progress, c.Claimed = today, {}, {}
	end

	for _, def in ChallengeService:GetDailySet(today) do
		local delta = self:ResolveDelta(player, def, won)
		if delta > 0 then
			c.Progress[def.Id] = math.min(def.Target, (c.Progress[def.Id] or 0) + delta)
		end
	end
end
```

`ResolveDelta` is a pure server-side function of the run's recorded facts. **The client is never consulted about challenge progress in any form.** A client that could report "I killed 250 monsters" is a client that will.

### 20.4 Claiming
Claiming happens in the lobby, one-shot, idempotent:

```lua
Net.event("Challenge_Claim").OnServerEvent:Connect(function(player, rawId)
	if not RateLimit.check(player, "Claim", 3, 5) then return end
	local profile = DataService:GetProfile(player); if not profile then return end
	local today = dayIndex()
	if profile.Data.Challenges.Day ~= today then return end

	local def = findInSet(ChallengeService:GetDailySet(today), Guard.string(rawId, 32))
	if not def then return end
	local c = profile.Data.Challenges
	if c.Claimed[def.Id] then return end                            -- idempotent
	if (c.Progress[def.Id] or 0) < def.Target then return end       -- not complete

	c.Claimed[def.Id] = true
	profile.Data.Crowns += def.CrownReward
	ProgressionService:AddXp(player, def.XpReward)

	if allThreeClaimed(c, today) then
		c.Streak = if c.LastCompleteDay == today - 1 then c.Streak + 1 else 1
		c.LastCompleteDay = today
		profile.Data.Crowns += Config.Challenges.StreakBonus(c.Streak)
	end
	Net.event("Challenge_Claimed"):FireClient(player, def.Id, profile.Data.Crowns)
end)
```

### 20.5 Rewards

| Tier | Crowns | XP |
|---|---|---|
| Easy | 150 | 60 |
| Medium | 300 | 120 |
| Hard | 500 | 200 |
| All three same day | +250 bonus | +100 |
| Streak bonus | `min(50 × streak, 500)` | — |

A player completing all three dailies earns roughly one full run's worth of Crowns. That is the right weight: meaningful, not a replacement for playing.

---

## 21. META PROGRESSION

### 21.1 Crown payout (paid on **every** run, win or lose)

```lua
Crowns = floor(
    Config.Progression.BaseCrowns                       -- 100
  + NightsSurvived × Config.Progression.CrownsPerNight  -- 25
  + (Won and Config.Progression.WinBonus or 0)          -- 200
  + BuildingsSurviving × 3
  + floor(Kills / 10) × 2
) × MapDifficultyMult × DifficultyTierMult × MutatorMult
  × (1 + 0.10 × CoopBonus) × PassMult

-- v2: hero shards are a SEPARATE currency, rolled independently (§33.4)
Shards = rollShardDrops(mapId, difficultyTier, won, nightsSurvived)
```

`DifficultyTierMult` is new in v2: Casual 0.7 / Normal 1.0 / Heroic 1.5 (§36).

Typical values: a lost tutorial run ≈ 180; a won mid-map run on Normal ≈ 550; a won Heroic run with two mutators and three friends ≈ 1,900.

**Paying Crowns on a loss is non-negotiable.** Thronefall can afford to pay nothing on a loss because the player already bought it. A free-to-play Roblox game that pays nothing for a failed 12-minute run teaches players that failure is wasted time, and they leave.

### 21.2 XP and levels
`xpForLevel(n) = floor(120 × n^1.35)`. Max level 40. Levels gate map access and perk slots; Crowns buy the content. Two separate axes so a player always has both "I'm progressing" and "I'm choosing".

### 21.3 Codex
Every enemy, building, and champion the player has seen is marked in `Data.Codex`. Grid UI with silhouettes for unseen entries and a completion reward per page. Collection pressure is the strongest long-tail retention force available, and this version costs almost nothing to build because `MarkSeen` is one line in `onDeath` and one in `Construct`.

### 21.4 Leaderboards
- **All-time high score per map** — `OrderedDataStore`, one key per player, written on the run-end save path, read once every 90 seconds and cached. Never let every server hammer pages.
- **Weekly** — MemoryStore SortedMap with a 7-day TTL, so newcomers can rank somewhere.

---

## 22. COMPLETE REMOTE CONTRACT

Every remote is created server-side in `Init` via `Net`. Clients only ever `WaitForChild`. Every client→server handler follows **rate → shape → possibility → mutate → respond**.

### 22.1 Match place

| Remote | Dir | Args | Rate (rate/burst) | Validation |
|---|---|---|---|---|
| `Match_State` | S→C | snapshot table | on phase change | — |
| `Match_Tick` | S→C | gold, castleHp, enemiesLeft | 10 Hz | — |
| `Match_SetReady` | C→S | `ready: boolean` | 2 / 3 | phase == Day; player alive |
| `Match_Heartbeat` | C→S | none | 0.5 / 2 | AFK stamp only |
| `Match_Morning` | S→C | summary table | per morning | — |
| `Match_Ended` | S→C | RunSummary | once | — |
| `Build_Request` | C→S | `slotId: string` | 4 / 6 | phase, alive, range+8, cost, level |
| `Build_Result` | S→C | slotId, ok, reason? | — | — |
| `Build_Placed` | S→C | slotId, level, userId | — | — |
| `Build_Destroyed` | S→C | slotId | — | — |
| `Upgrade_Choose` | C→S | slotId, choiceId | 2 / 3 | must be the payer; choice in offered set; not timed out |
| `Upgrade_Offer` | S→C | slotId, choices, payerId, deadline | — | — |
| `Combat_Ability` | C→S | `dir: Vector3` | 2 / 3 | phase == Night; alive; server cooldown ×0.92; unit vector |
| `Combat_AbilityUsed` | S→C | userId, abilityId, dir | — | — |
| `Unit_SetRally` | C→S | slotId, position | 4 / 8 | phase == Day; radius clamped; ground-snapped |
| `Unit_RallyMoved` | S→C | slotId, position | — | — |
| `Unit_RallyToMe` | C→S | `group: string` | 2 / 4 | group in {All, Melee, Ranged} |
| `Fx_Hit` | S→C (unreliable) | position, amount, tag, isSuper | — | — |
| `Fx_Swing` | S→C (unreliable) | userId, targetPos | — | — |
| `Fx_EnemyDied` | S→C (unreliable) | defId, position | — | — |
| `Fx_CoinCollected` | S→C (unreliable) | position | — | — |
| `Research_Complete` | S→C | researchId | — | — |

### 22.2 Lobby place

| Remote | Dir | Args | Rate | Validation |
|---|---|---|---|---|
| `Profile_Sync` | S→C | full public profile view | on load / change | — |
| `Loadout_Equip` | C→S | kind, id | 5 / 10 | `keyOf` against the OWNED map |
| `Loadout_SetPerks` | C→S | `perkIds: {string}` | 3 / 5 | length ≤ slots; no dupes; all owned |
| `Shop_Buy` | C→S | kind, id | 2 / 4 | catalog membership; level; Crowns; not owned |
| `Shop_Result` | S→C | id, ok, reason? | — | — |
| `Challenge_Claim` | C→S | challengeId | 3 / 5 | in today's set; complete; not claimed |
| `Party_Create` | C→S | none | 1 / 2 | not already in a party |
| `Party_Join` | C→S | `code: string(6)` | 2 / 3 | party exists; not full; not started |
| `Party_Leave` | C→S | none | 2 / 3 | — |
| `Party_SetReady` | C→S | boolean | 3 / 5 | member of party |
| `Party_SelectMap` | C→S | mapId, mutatorIds | 2 / 4 | **host only**; map unlocked for host; mutators exist |
| `Party_Start` | C→S | none | 1 / 2 | host only; all ready; teleport not already in flight |
| `Party_State` | S→C | party snapshot | on change | — |
| `Settings_Save` | C→S | settings table | 1 / 3 | numbers clamped 0–1 |

### 22.3 Honeypot
Create a remote named `Admin_GrantCrowns` that no legitimate client ever calls. Anyone who fires it is logged to analytics with their UserId and flagged. Keep enforcement delayed and randomised so exploiters cannot A/B test what triggered it.

---

## 23. MAP AUTHORING PIPELINE

The whole point of the build-slot constraint is that maps become content. This is the exact workflow.

### 23.1 Steps

1. Create a `Model` named `Map_<Name>` in `ServerStorage/Maps`.
2. Build terrain and decoration. Everything decorative: `Anchored = true`, `CanCollide = false`, `CanQuery = false`, `CanTouch = false`. Merge repeated decoration into shared `MeshPart` assets so the engine batches them.
3. Place an invisible anchored `Part` at each **build slot**. Tag it `BuildSlot`. Set attributes `SlotType`, `SlotId`, `MaxLevel`, `StartLevel`. Orient it — the building spawns using the slot's Y rotation.
4. Place a `Part` per **enemy spawn point**. Tag `EnemySpawn`. Attribute `SpawnIndex` (1..N).
5. For each spawn point, place a chain of `Part`s tagged `LaneNode` with attributes `SpawnIndex` and `Order` (1..M). These are the walking lane. Keep 15–30 studs between nodes; more nodes than that is wasted memory, fewer makes enemies cut corners through walls.
6. Place one slot with `SlotType = "Castle"`, `StartLevel = 1`. Exactly one per map.
7. Set the whole model's `ModelStreamingMode = Persistent`.
8. Add a `Config.Maps` entry with `StartGold`, `UnlockLevel`, and the full night-by-night wave table.

### 23.2 Validation script (run before shipping any map)

Write this as a plugin or a Studio command bar script. It has caught every map bug on this design:

```lua
-- Verifies a map model before it ships
local errors = {}
local seenSlotIds, spawnIndices = {}, {}

for _, part in CollectionService:GetTagged("BuildSlot") do
	if not part:IsDescendantOf(map) then continue end
	local id = part:GetAttribute("SlotId")
	local kind = part:GetAttribute("SlotType")
	if not id then table.insert(errors, `Slot missing SlotId: {part:GetFullName()}`) end
	if seenSlotIds[id] then table.insert(errors, `Duplicate SlotId: {id}`) end
	seenSlotIds[id] = true
	if not Config.Buildings[kind] then table.insert(errors, `Bad SlotType '{kind}' on {id}`) end
	if part:GetAttribute("MaxLevel") > #Config.Buildings[kind].Levels then
		table.insert(errors, `MaxLevel exceeds defined levels for {id}`)
	end
end

for _, part in CollectionService:GetTagged("EnemySpawn") do
	if part:IsDescendantOf(map) then spawnIndices[part:GetAttribute("SpawnIndex")] = true end
end

-- Every spawn point must have a contiguous lane
for index in spawnIndices do
	local nodes = laneNodesFor(index)
	if #nodes == 0 then table.insert(errors, `Spawn {index} has no LaneNodes`) end
	for order = 1, #nodes do
		if not nodes[order] then table.insert(errors, `Lane {index} missing Order {order}`) end
	end
end

-- Every wave entry must reference a spawn point that exists
for _, night in Config.Maps[mapId].Nights do
	for _, entry in night.Entries do
		if not spawnIndices[entry.SpawnIndex] then
			table.insert(errors, `Night {night.Night} references missing SpawnIndex {entry.SpawnIndex}`)
		end
		if not Config.Enemies[entry.EnemyId] then
			table.insert(errors, `Night {night.Night} references unknown enemy '{entry.EnemyId}'`)
		end
	end
end
```

### 23.3 Slot-count design guidance

Slot counts *are* the level design. Vary the shape of each map, don't just scale it up:

| Map | Character | Towers | Walls | Houses | Mills | Mines | Barracks | Archery |
|---|---|---|---|---|---|---|---|---|
| Greenhollow (tutorial) | Teach | 3 | 1 | 7 | 1 | 0 | 1 | 0 |
| Ashridge | Balanced | 12 | 14 | 11 | 3 | 0 | 2 | 2 |
| Frostmere | Kill zones, few chokepoints | 22 | 4 | 16 | 0 | 1 | 2 | 2 |
| Blackfen | Fortress, siege-heavy | 26 | 20 | 12 | 4 | 3 | 2 | 2 |

Frostmere having 22 towers and 4 walls makes it a completely different puzzle from Ashridge — without a line of new code. That is the payoff of the constraint.

---

## 24. UI SCREEN INVENTORY

Mobile-first: design at ~375×667 logical, verify on desktop after. `Scale` not `Offset` for anything structural. `UIAspectRatioConstraint` on cards and slots. `TextScaled` + `UITextSizeConstraint`. Layer via one `ScreenGui` per layer: HUD < menus < modals < toasts < loading.

### 24.1 Match HUD

```
┌──────────────────────────────────────────────────────────┐
│ 🪙 14 gold          NIGHT 4 / 13         🏰 ████████ 92% │  ← top edge
│                                                           │
│  [wave preview markers pinned to screen edge, pointing    │
│   at each active spawn point, with enemy icons + counts]  │
│                                                           │
│  ← teammate portraits, HP bars, downed indicators         │
│                                                           │
│                                                           │
│ [SPRINT]                    [BUILD 🔨 3g]      [⚡ ABILITY]│  ← thumb zone
│                             or [READY 2/4]     [🚩 RALLY]  │
└──────────────────────────────────────────────────────────┘
```

Conventions players already know: currency top-left, objective top-center, castle health top-right, primary action bottom-center, secondary bottom-right. Don't innovate on HUD layout — spend creativity on the game.

### 24.2 Screen list

| Screen | Place | Notes |
|---|---|---|
| Loading | Both | Interactive tip carousel; never a blank freeze |
| Match HUD | Match | Above |
| Build prompt (billboard) | Match | World-space, on the nearest eligible slot |
| Upgrade choice modal | Match | 2–4 cards, 12s ring timer, payer picks |
| Morning summary | Match | Income, score, research ticks — 6s, skippable |
| Results | Both | Crowns, XP fill, challenge ticks, next-unlock teaser |
| Lobby HUD | Lobby | Crowns, level bar, kiosk hints |
| Loadout | Lobby | Champion / weapon / perk tabs |
| Shop | Lobby | Category tabs, owned-state distinct, price always pre-tap |
| Challenges | Lobby | Progress bars over text; claim button lights up; HUD badge for unclaimed |
| Party | Lobby | Member list, ready ticks, invite code, map select for host |
| Map select | Lobby | Cards with difficulty, nights, best score, mutator toggles |
| Codex | Lobby | Grid, silhouettes for unseen |
| Leaderboard | Lobby | Per-map all-time + weekly tabs |
| Settings | Lobby | Music/SFX sliders, reduce effects, keybinds (PC) |

### 24.3 Non-negotiable mobile checks
- Every tap target ≥ 50px at phone scale.
- BUILD and ABILITY buttons far enough apart that a thumb cannot hit the wrong one.
- Interactive controls out of notch and home-bar regions.
- Test the entire FTUE with touch emulation. An unclickable tutorial button on phones is a silent D1 catastrophe you will only find in funnel data.

---

## 25. JUICE & AUDIO

Juice is legibility of reward, not decoration. **Every reward = sound + motion + number.**

| Moment | Recipe |
|---|---|
| **Building placed** | Mesh scales 0.6 → 1.15 → 1.0 with `Back` easing over 0.25s + dust ring particle burst + deep thunk. The single most-repeated action in the game — over-invest here. |
| **Enemy dies** | Brief scale-punch, 4–6 debris particles, pitch-varied death sound, coin bursts upward with an arc. |
| **Coin collected** | Coin flies to the counter using `Camera:WorldToViewportPoint`, counter pops, tick sound rising in pitch with combo. |
| **Damage numbers** | Pooled client-side labels, small drift up + fade over 0.6s. Yellow and larger when the counter multiplier ≥ 2 — this teaches the tag system with zero text. |
| **Big hit / ability** | 0.05s hit-stop, small camera shake, FOV punch of 3°. Respect the reduce-effects setting. |
| **Nightfall** | Lighting tweens over 2.5s (ClockTime, Ambient, fog). Music crossfades from calm to driving over the same 2.5s. Camera pulls back to 95. **The music is the phase-change signal** — get this right and the game feels twice as good. |
| **Morning** | Light returns fast (1.2s), a triumphant sting, buildings that rebuilt do the same plop animation as when first built. |
| **Castle under 30%** | Red vignette pulse, low heartbeat drone, castle HP bar shakes. |
| **Run victory** | Slow-motion final kill, banner drop, Crown counter counts up with escalating pitch. Never auto-dismiss — let them screenshot. |

Tween timings: 0.1–0.3s for feedback, 0.3–0.5s for screens. `Back` easing for arrivals, `Quad` for exits. If the UI feels slow, shorten tweens before removing them.

Audio: one `SoundService` group per category with volume driven by the profile's settings. Start music at modest volume — mobile players mute games that blast on join.

---

## 26. PERFORMANCE BUDGETS AND RULES

Target: 60 fps on a strong device, stable 30+ on a mid-range Android, servers responsive at 4 players for hours.

### 26.1 Budgets

| Metric | Budget |
|---|---|
| Server tick, all enemy logic at 180 enemies | ≤ 4 ms |
| Server tick, towers + units + coins | ≤ 2 ms |
| Client frame on mid-range Android during peak night | ≥ 30 fps |
| Concurrent enemies (design peak) | 120–180 |
| Concurrent enemies (hard cap) | 200 |
| Active projectiles | ≤ 120 |
| Join-to-playable (match place) | ≤ 8 s |
| Server memory growth over 60 min | ≈ 0 |

### 26.2 Rules
1. **No `Humanoid` on enemies or units.** Champions only.
2. **`SetNetworkOwner(nil)`** on every enemy, unit, and projectile part. Server authority and smooth replication in one call; also stops exploiters from owning your boss's physics.
3. **Pool everything spawned in volume.** Enemies, coins, projectiles, damage labels, VFX.
4. **No allocation in `Heartbeat` steady state.** Hoist tables, reuse scratch buffers with `table.clear`, no string concat in hot paths.
5. **One loop per system, not one script per entity.** A `while task.wait(0.1)` per enemy across 180 enemies is a hidden frame tax.
6. **Never `Touched` for gameplay.** Coin pickup, aggro, and zones all use spatial queries.
7. **Collision groups:** enemies don't collide with enemies, coins collide with nothing, champions don't collide with champions.
8. **One grid rebuild per tick**, shared by EnemyService, TowerService, and UnitService.
9. **Batch remotes.** Damage numbers for a tick go as one array, not one remote per hit.
10. **Trove per lifetime.** Every run, champion, and UI screen owns a Trove; everything it creates goes in. Leaked connections are the #1 cause of server memory death.
11. **Cap particle rates**; use `Emit()` bursts over always-on emitters. Transparency is an overdraw bomb on mobile.

### 26.3 Leak audit checklist (run at end of every phase)
- Every `[Player]`-keyed table has a `PlayerRemoving` cleanup.
- Every `CharacterAdded`-nested connection is in a Trove cleaned on death.
- No array grows without a cap (hit lists, logs, histories).
- Pools track their members; nothing is orphaned to `nil` parent and forgotten.
- Every long `task.spawn` loop exits on a flag or is `task.cancel`ed via Trove.

Measure with MicroProfiler and the F9 memory tab on a real device. Find the biggest bar, fix it, re-measure. Never optimise by folklore.

---

## 27. SECURITY CHECKLIST

The threat model: the exploiter fully controls their client, can read all of `ReplicatedStorage`, and can fire any remote with any arguments at any rate. Security is a server design property, not a script you bolt on.

### 27.1 Per-remote checklist (apply to every single client→server handler)
- [ ] Rate limited with a token bucket sized to legitimate use
- [ ] Every argument passed through `Guard` (type, range, NaN/inf, length)
- [ ] Ids validated with `keyOf` against a **server-side Config or owned-map**, never trusted
- [ ] Phase checked (`Day` vs `Night`) where relevant
- [ ] Player state checked (alive, in-run, profile loaded)
- [ ] Distance/ownership checked with a small latency grace, never a strict equality
- [ ] Cost/reward looked up server-side; the client never sends a number that becomes a value
- [ ] Mutation order: **take payment, then grant**
- [ ] Silent `return` on malformed input; friendly reason only for legitimate failures

### 27.2 Game-specific attack surface

| Attack | Defence |
|---|---|
| Fire `Build_Request` for every slot on the map | Range check from server-known champion position; gold check |
| Send a fake price / free build | Client never sends a price; server computes from Config |
| Spam `Combat_Ability` | Server-side `Cooldown.try` with 8% grace; rate limit |
| Report kills or challenge progress | Client is never consulted; all tracking is server-side |
| Equip an unowned weapon via TeleportData | Match server re-reads the profile; substitutes default silently |
| Speed hack the champion | 3 Hz position sanity check, snap-back not kick |
| Drag a rally flag across the map | Server clamps to radius and ground-snaps |
| Claim a challenge twice | `Claimed[id]` flag checked before granting; idempotent |
| Double-grant a Robux product | `PurchaseId` recorded in the profile inside the same transaction as the grant |
| Farm co-op scaling then leave | `PlayerCount` snapshotted at start; leavers forfeit rewards |
| Party host teleports a non-member | Server builds the member list from server-side party state |

### 27.3 Never
- Never call `InvokeClient` from the server.
- Never put admin user-id lists, webhook URLs, or unreleased content in `ReplicatedStorage`.
- Never treat `Humanoid.Health` on a champion as authority — `state.Players[p].Hp` is the record.
- Never use `SetAsync` on the profile store.

---

## 28. ANALYTICS

Wire `AnalyticsService` in Phase 2. You cannot fix a leaky funnel you cannot see.

### 28.1 FTUE funnel (lobby + match)
`Joined` → `EnteredLobby` → `PressedPlay` → `MatchLoaded` → `FirstBuild` → `FirstNightStarted` → `FirstNightSurvived` → `RunCompleted` → `ReturnedToLobby` → `FirstUnlockPurchased`

Any step losing more than 15–20% is a fire, and the fix comes before any new content.

### 28.2 Economy events
Log every gold and Crown source and sink with amount, ending balance, and a transaction tag. The Sources-vs-Sinks report is how you spot economy inflation before it kills the game.

### 28.3 Custom events
`RunEnded` (map, nights survived, won, players, mutators, duration, score), `ChallengeClaimed`, `UnlockPurchased`, `ChampionSelected`, `WeaponSelected`, `MutatorSelected`, `PlayerDowned`, `PlayerRevived`, `MapAbandoned` (which night).

`MapAbandoned` by night number is the single most useful balance signal you will have — it tells you exactly which night is too hard.

### 28.4 Weekly review
Creator Hub retention cohorts (D1/D7/D30), session length, platform mix (check your mobile %), acquisition source. Compass targets for a healthy growing game: D1 above ~25%, session 8–15 min, sub-60s bounce under 5%.

---

## 29. MONETIZATION (REBUILT IN v2)

**Never sell in-run power.** The run is a balanced puzzle; selling gold or damage inside it destroys both the design and the retention it produces. Sell **meta acceleration, convenience, access, and expression** — four separate axes, so a player who refuses one still has three others they might want.

Prices are set to how players actually hold Robux. Common denominations are 400 / 800 / 1700, so **399 converts better than 449**. Do not round prices up "because it's close."

### 29.1 Game passes

| Pass | R$ | Effect | Axis | Why it converts |
|---|---|---|---|---|
| **Royal Treasury** | 249 | +50% Crowns (meta only, never in-run gold) | Acceleration | The backbone. Highest attach rate, feels fair, never touches run balance |
| **VIP** | 799 | Treasury + perk slot + name tag + exclusive castle skin + gold banner | Identity | The **price anchor**. Its job is making 249 feel small. Price it as identity, not as maths |
| **Coin Magnet** | 149 | Coin collect radius ×3 | Convenience | Pure mobile QoL. Cheap, high volume, negligible balance impact |
| **Extra Perk Slot** | 199 | 6th perk slot | Expression | Build-crafters buy this instantly |
| **Hero Collector** | 399 | +1 hero roster slot, +25% shard drops | Acceleration | The collection monetizer — the one that **scales with the game** as you add heroes |
| **Stable Pass** | 299 | Unlocks 3 mounts + all future mount drops | Expression | Visible, flexable, zero balance cost |
| **Champion Pack** | 399 | 2 exclusive champions immediately | Access | Skips the Crown grind for two characters |
| **Auto-Ready** | 99 | Skips the ready confirmation, +10% day prep speed | Convenience | Tiny, impulse-priced, surprisingly strong volume |
| **Private Kingdom** | 99 | Private lobby server | Access | Friend groups colonize these and stay for months |
| **2x XP** | 199 | Faster level unlocks | Acceleration | Natural bundle upsell alongside Treasury |

### 29.2 Developer products

| Product | R$ | Notes |
|---|---|---|
| Crown bundle — Pouch | 25 | Impulse floor |
| Crown bundle — Chest | 99 | **"POPULAR"** badge |
| Crown bundle — Vault | 399 | |
| Crown bundle — Hoard | 899 | |
| Crown bundle — Treasury | 1,999 | **"BEST VALUE"** badge. Whales need the big tier to *exist* |
| **Starter Pack** | 199 | One-time, ~4x value (Crowns + Ranger + a mount). Offered after the **first completed run** |
| Hero shard pack | 149 / 499 | Rarity-weighted, odds displayed |
| Daily-challenge reroll | 25 | |
| Seasonal skin bundle | 299–699 | Rotates with liveops |
| **Gift Crowns to a friend** | 99–899 | Social pressure monetizes gently and doubles as a virality feature |

**The Starter Pack is the highest-converting single item in most Roblox games**, and its job is not revenue. It is to manufacture a *first purchase*, which multiplies the odds of every later one. Offer it once, time-limited per player, immediately after their first win.

### 29.3 Subscription (add once DAU is stable, not before)
Monthly: daily Crown stipend, a rotating exclusive mount, subscriber badge. Price the delivered value at 2–3x what the same Robux buys one-off. Do not ship this before your update cadence is proven — a subscription you stop feeding is a refund queue.

### 29.4 Premium Payouts
You implement nothing; Roblox pays you proportional to engagement time from Premium subscribers. For some genres this is a large fraction of total revenue. One more reason session length is sacred and bounce is poison.

### 29.5 The one thing to refuse to sell

**No Robux "continue" when the castle falls.** It is lucrative, and it is standard in round-based Roblox games. Refuse it anyway:
- It destroys score integrity, so your leaderboards become a spending ranking.
- It poisons your difficulty-tuning data — `MapAbandoned` by night is your best balance signal, and paid continues corrupt it.
- It converts a designed moment of tension into a checkout screen, which is exactly the feeling that makes players stop trusting a game.

Give **one free Last Stand per run** instead (all towers revive once when the castle drops below 30%) and sell nothing at that moment. The goodwill is worth more than the conversion.

### 29.6 ProcessReceipt
Record the `PurchaseId` inside the player's profile **in the same in-memory transaction as the grant**, then trigger an immediate save and return `NotProcessedYet` if the save fails. Roblox re-delivers, and the idempotency check absorbs it. A crash can then never double-grant or void a purchase.

Game passes: check with `UserOwnsGamePassAsync` (pcall'd, cached per session) and also connect `PromptGamePassPurchaseFinished` so benefits apply instantly — making players rejoin to receive a pass generates refunds.

### 29.7 Prompt placement
Contextual, never interruptive. Every wall gets a door:

| Wall the player hits | Door you open |
|---|---|
| Results screen: "Ranger — 820/1000 Crowns" | Crown bundle prompt |
| Hero roster full | Hero Collector pass |
| Missing 12 shards for a Legendary | Shard pack |
| Third run of the session | Royal Treasury (+50% Crowns) |
| Watching a teammate's rare mount | Stable Pass |
| First win completed | Starter Pack, once, time-limited |

### 29.8 Ethics that are also strategy
Disclose odds on every paid random, in the purchase UI. Never sell raw power in a mode with a shared leaderboard. No fake timers or guilt popups — this audience's parents issue refunds and its community broadcasts backlash. **Free players are content**: they fill your servers and they are the whale's audience. Make paid play delightful, never make free play miserable.

---

## 30. PHASED BUILD ORDER WITH ACCEPTANCE CRITERIA

Each phase ends with a playable build. Do not start a phase until the previous phase's criteria all pass.

### Phase 1 — Core loop graybox (match place only, solo)
**Build:** MatchService phase machine · BuildService with 3 slot types (House, Tower, Wall) · EconomyService · WaveService with hardcoded waves · EnemyService with 2 enemy types, pooled, no Humanoid · ChampionService with auto-attack only · one graybox map, 5 nights.
**Acceptance:**
- A 5-minute solo run is completable and *fun with grey boxes and no sound*.
- 60 enemies concurrent, server tick under 2 ms.
- Building, night, morning, income, and free rebuild all work.
- **Stop and iterate here until the loop is fun.** Nothing downstream saves a boring core.

### Phase 2 — Spine
**Build:** `Config.luau` fully populated · `Types.luau` · `Net`/`Guard`/`RateLimit`/`Trove`/`Signal` · session-locked `DataService` with `Release` · AnalyticsService with the FTUE funnel · the enemy simulation hardened to 180 concurrent · the map validation script.
**Acceptance:**
- 180 enemies on a mid-range Android at ≥ 30 fps.
- Every remote rate-limited and Guard-validated.
- Profile saves, reloads, survives a server restart, and reconciles a new field without wiping.
- Server memory flat over a 60-minute soak test.

### Phase 3 — Co-op and depth
**Build:** two-place structure · PartyService + reserved-server teleport with explicit profile release · **MatchmakingService with the MemoryStore Quick Play queue (§34)** · **rejoin via MemoryStore (§34.3)** · shared gold + toasts · co-op wave and drop scaling · downed/revive · UnitService with rally flags · TowerService with pooled projectiles · UpgradeService branching choices · **difficulty tiers (§36)** · 4 champions, 6 weapons · 14 enemies · 4 maps at 8–10 nights.
**Acceptance:**
- 4 players complete a 10-night map together without desync, in under 9 minutes.
- A solo player pressing **QUICK PLAY** is in a filling match within 30 seconds.
- Force-closing the app mid-run and reopening offers **REJOIN RUN**, and it works.
- Teleport lobby→match→lobby has no session-lock stall.
- Upgrade choices visibly change how a run plays.

### Phase 4 — Meta, collection, and lobby
**Build:** lobby place with all kiosks · LoadoutService · ShopService · ProgressionService · ChallengeService with the deterministic daily set · **HeroService: shards, rarity, roster, levelling, power normalization (§33, §36)** · **StableService: mounts (§37)** · Codex · leaderboards · results screen with next-unlock teaser **and shard reveal**.
**Acceptance:**
- Crowns *and shards* are paid on a loss.
- A Legendary hero is visibly, obviously better in Endless and visibly *capped* in Campaign.
- Daily challenges issue identically on two different servers.
- Claiming is idempotent under a double-fire test.
- A new player's first session ends on an almost-affordable unlock **and a partially-filled hero**.

### Phase 5 — Endless Siege and virality
**Build:** Endless Siege mode (§35) · weekly MemoryStore leaderboard · the three clip moments (§38.1) · codes system · server-wide event flag.
**Acceptance:**
- Endless holds 200 enemies at wave 30 without dropping below 30 fps on a mid-range Android.
- Each clip moment is recognisable and screenshot-worthy without audio.

### Phase 6 — Monetization
**Build:** the ten passes and all products in §29 · `ProcessReceipt` with profile-recorded `PurchaseId` · starter pack · contextual prompts per §29.7.
**Acceptance:** a simulated crash between grant and confirm results in exactly one grant. No purchasable item alters campaign balance.

### Phase 7 — Juice and mobile pass
**Build:** every recipe in §25 · lighting and music phase transitions · full mobile control pass · reduce-effects setting · **build hints for nights 1–3 (§36.3)**.
**Acceptance:** the full FTUE completed on a real phone by someone who has never seen the game, with no verbal help, on Casual difficulty.

### Phase 8 — Soft launch
Release quietly. Instrument. Fix the worst funnel drop-off. Iterate the icon for CTR. Two to four weeks of tuning is normal and is what separates games the algorithm adopts from games it samples and drops. Only scale ad spend once D1 looks healthy.

### Phase 9 — Liveops
**Two heroes per month** is the cadence that matters — the collection is the retention engine, so feeding it is feeding retention. Around that: a new map every 2–3 weeks (a map is a model plus a Config entry), a new champion monthly, seasonal castle skins and mounts, codes with every update, and a Blood Moon weekend event most months (§38.3). Mutators remain the cheapest content you have — ship more of them.

---

## 31. TEST PLAN

### 31.1 Automated (Studio command bar or a test place)
- Map validator on every map (§23.2).
- Config integrity: every `EnemyId` in every wave table exists; every `UpgradeChoices` id exists in `Config.Upgrades`; every `Damage` profile covers every tag; every shop item has a valid `UnlockLevel`.
- Spawn 200 enemies, assert tick time and zero allocation growth over 60 s.
- Profile round-trip: save → clear → load → assert deep equality; add a template field → assert reconcile fills it without touching existing values.

### 31.2 Manual pass list
| Case | Expect |
|---|---|
| Build with insufficient gold | Silent reject + client "not enough" toast |
| Build from 200 studs away (via exploit) | Server rejects |
| Two players build the same slot simultaneously | One succeeds, one gets "AlreadyBuilt", gold charged once |
| Castle destroyed | Defeat, results, Crowns still awarded |
| All players downed | Night continues, towers keep fighting |
| Host leaves in lobby party | Host migrates to next member |
| Player leaves mid-run | Run continues, their units remain, no rewards for them |
| Claim the same challenge twice rapidly | Granted once |
| Buy a weapon with exactly enough Crowns | Succeeds, balance 0 |
| Rejoin immediately after a run | No session-lock stall (proves `Release` works) |
| Day AFK for 300s | Night auto-starts |
| Flying enemy vs Warden | 0 damage, clear visual feedback |

### 31.3 Device pass
Real mid-range Android at quality level 1–3: peak-night frame rate, UI readability, tap target accuracy, join-to-playable time, thermal behaviour over a 15-minute session.

---

## 32. KICKOFF PROMPT FOR THE NEXT SESSION *(superseded by §39 — use that one)*

Retained for reference. The v2 prompt in §39 adds the hero types and the 6-minute run target.

> Use the `roblox-game-dev` skill. We're building **Kingdom Nights**, per `kingdom-nights-build-spec.md` (attached) and the accompanying `Config.luau`.
>
> Start **Phase 1: core loop graybox** in the match place only, solo, no art.
>
> Deliver complete files, each headed with its exact location and class:
> 1. `ReplicatedStorage/Shared/Types.luau`
> 2. `ReplicatedStorage/Shared/Net.luau`, `Signal.luau`, `Trove.luau`, `Guard.luau`, `RateLimit.luau`, `Cooldown.luau`
> 3. `ReplicatedStorage/Shared/Util/Pool.luau`, `SpatialGrid.luau`, `TableUtil.luau`
> 4. `ServerScriptService/Server` (bootstrap)
> 5. `ServerScriptService/Services/MatchService.luau` — the full phase machine from §7
> 6. `ServerScriptService/Services/BuildService.luau` — §8
> 7. `ServerScriptService/Services/EconomyService.luau` — §9
> 8. `ServerScriptService/Services/WaveService.luau` — §10
> 9. `ServerScriptService/Services/EnemyService.luau` — §11, pooled, no Humanoid, one flat Heartbeat loop
> 10. `ServerScriptService/Services/CombatService.luau` — §12
> 11. `ServerScriptService/Services/ChampionService.luau` — §13, auto-attack only for now
> 12. `StarterPlayer/StarterPlayerScripts/Client` (bootstrap) + `BuildController`, `HUDController`, `CameraController`
>
> Constraints: `--!strict` everywhere, all numbers from `Config`, server authority on every state change, no allocation in Heartbeat, no Humanoid on enemies. Then give me step-by-step Studio instructions to assemble the graybox map with tagged slots, spawns, and lane nodes so I can playtest it the same day.

---

## 33. HERO COLLECTION — SHARDS, RARITY, ROSTER *(NEW IN v2)*

This is the largest addition in v2 and the one that most changes the game's long-term shape. Read this before building §19 or §21.

### 33.1 Why

v1's meta was mastery: replay a map with harder mutators for a higher score. That is Thronefall's meta, and it works when someone paid for the game because they like strategy games. The Roblox tower-defense games that actually sustain — Tower Defense Simulator, Toilet Tower Defense, All Star Tower Defense — do not retain on tactics. They retain on **collecting**. The run is the content; the collecting is the game. Players return to get the unit they do not have, not to beat their own score.

You already have the slot for this: **Hero's Quarters**. v1 wasted it on a single static Golem. v2 turns it into a roster.

### 33.2 Design

```
• 12 heroes at launch, across 4 rarities: Common / Rare / Epic / Legendary.
• Each hero is a distinct model with a distinct silhouette, a role, and a passive.
• Heroes are earned with SHARDS, not Crowns — a separate currency with its own drop table.
  Unlock cost and level-up cost are both paid in that hero's shards.
• A player equips heroes to ROSTER SLOTS (3 at level 1, 4 at level 15, 5 at level 30,
  +1 from the Hero Collector pass, max 6).
• During a run, each built Hero's Quarters spawns the NEXT unequipped hero from the
  roster, in roster order. Two Hero's Quarters on a map = your top two heroes deploy.
• Heroes are VISIBLE on the battlefield to all four players. This is the flex, and the
  flex is the point — a Legendary walking across the field is free advertising to three
  other players every single run.
```

### 33.3 The roster

| Hero | Rarity | Role | Passive | Shards to unlock |
|---|---|---|---|---|
| Stoneguard | Common | Tank | Nearby walls take 15% less damage | 20 |
| Bowman Captain | Common | Ranged | +10% tower fire rate in radius | 20 |
| Hound Handler | Common | Anti-fast | 2× damage vs Fast tag | 20 |
| Torchbearer | Rare | Anti-monster | Applies burn; 1.5× vs Monster | 45 |
| Sky Lancer | Rare | Anti-air | Only reliable early answer to Flying | 45 |
| Siege Breaker | Rare | Anti-siege | 2.5× vs Siege, knocks back rams | 45 |
| Field Medic | Rare | Support | Heals allied units in radius | 45 |
| Golem | Epic | Tank/AoE | Splash damage, huge HP pool | 90 |
| Frost Warden | Epic | Control | Attacks slow by 40% for 3s | 90 |
| Firewing | Epic | Flying DPS | Flies over walls, ignores ground pathing | 90 |
| Lizard Rider | Legendary | Hybrid | Fast, hits Flying and Siege at 2× | 160 |
| The Ashen Queen | Legendary | Nuke | Periodic AoE that damages everything on screen | 160 |

Add **two heroes per month** post-launch. That cadence is the retention engine; feeding it is feeding retention.

### 33.4 Shard economy

Shards drop from every run, win or lose, rolled independently of Crowns:

```lua
-- ServerScriptService/Services/RewardService.luau
function RewardService:RollShards(ctx: RunContext): { [string]: number }
	local budget = Config.Shards.Base                              -- 8
	           + ctx.NightsSurvived * Config.Shards.PerNight       -- 2
	           + (if ctx.Won then Config.Shards.WinBonus else 0)   -- 12
	budget *= Config.Difficulty[ctx.Tier].ShardMult                -- 0.7 / 1.0 / 1.6
	budget *= PassService:GetShardMultiplier(ctx.Player)           -- Hero Collector: 1.25

	local out = {}
	local remaining = math.floor(budget)
	while remaining > 0 do
		-- Weighted by rarity, biased toward heroes the player is already part-way through.
		-- Near-completion bias is what makes the drop feel like progress instead of noise.
		local heroId = weightedHeroRoll(ctx.Player, ctx.MapId)
		local grant = math.min(remaining, math.random(1, 4))
		out[heroId] = (out[heroId] or 0) + grant
		remaining -= grant
	end
	return out
end
```

Rarity drop weights: Common 55%, Rare 30%, Epic 12%, Legendary 3%. **Display these odds** in the shard-pack purchase UI — platform policy expects it and players punish hidden odds.

**The near-completion bias is the important detail.** A player 4 shards from unlocking Firewing should feel the game nudging them there. Weight each hero by `1 + 2 × (owned / required)` for heroes not yet unlocked. That single line converts a random drop into a visible ladder.

### 33.5 Hero levels

| Level | Shard cost | Effect |
|---|---|---|
| 1 | unlock cost | Base stats |
| 2 | ×1.5 | +15% HP and damage |
| 3 | ×2.5 | +35% HP and damage |
| 4 | ×4 | +60%, passive radius +25% |
| 5 | ×7 | +100%, passive effect ×1.5, unique visual (glow, cape, particle) |

The level-5 visual is a deliberate flex target. Make it obvious from across the map.

### 33.6 Types to add to `Types.luau`

```lua
export type HeroRarity = "Common" | "Rare" | "Epic" | "Legendary"

export type HeroDef = {
	Id: string,
	Display: string,
	Rarity: HeroRarity,
	Role: string,
	Hp: number,
	Damage: number,
	AttackInterval: number,
	AttackRange: number,
	Speed: number,
	DamageProfile: string,
	Passive: { Kind: string, Radius: number, Value: number },
	ShardsToUnlock: number,
	Model: string,
	Flying: boolean?,
	SplashRadius: number?,
}

-- Added to PlayerData:
--   Shards: { [string]: number },
--   Heroes: { [string]: { Level: number } },
--   HeroRoster: { string },            -- ordered; deploys in this order
```

### 33.7 Implementation notes

- Heroes reuse `UnitService` entirely — no `Humanoid`, anchored parts, one flat loop, `SetNetworkOwner(nil)`, pooled models. A hero is a unit with better stats, a passive, and a distinct model. **Do not write a separate hero simulation.**
- Roster order is set in the lobby and validated server-side on run start: every entry owned, no duplicates, length ≤ current slot count.
- The match server reads the roster from the player's own profile, never from TeleportData.
- `HeroService:GetDeployedHero(slot, index)` is the only entry point BuildService calls.

---

## 34. MATCHMAKING, QUICK PLAY, AND REJOIN *(NEW IN v2 — overrides §17.1)*

### 34.1 Why this overrides v1

v1 specced party-only matchmaking with reserved servers. That was a mistake. **A player with no friends online is the majority case**, and co-op is the game's headline feature. Party-only means most players never experience the thing the game is built around, which makes the headline feature invisible to exactly the audience that would spread it.

### 34.2 Quick Play

The lobby has **two** entry points, and Quick Play is the visually dominant one:

```
   ┌────────────────────────┐   ┌──────────────────┐
   │    ⚔ QUICK PLAY        │   │   👥 PLAY WITH   │
   │  (find 3 teammates)    │   │      FRIENDS     │
   └────────────────────────┘   └──────────────────┘
        large, centre-north          smaller, beside it
```

Implementation — a MemoryStore Queue, which is exactly what this primitive exists for:

```lua
-- ServerScriptService/Services/MatchmakingService.luau
--!strict
local MemoryStoreService = game:GetService("MemoryStoreService")
local TeleportService = game:GetService("TeleportService")

local QUEUE_TTL = 120

function MatchmakingService:Enqueue(player: Player, mapId: string, tier: string)
	local queue = MemoryStoreService:GetQueue(`KN_MM_{mapId}_{tier}`, 30)
	local ok, err = pcall(function()
		queue:AddAsync({ UserId = player.UserId, JoinedAt = os.time() }, QUEUE_TTL)
	end)
	if not ok then
		warn(`[MM] enqueue failed: {err}`)
		self:FallbackSolo(player, mapId, tier)   -- never leave a player stuck in a queue
	end
end

-- One lobby server per region runs the builder loop. Every server runs it; the
-- queue's invisibility window makes duplicate processing safe.
function MatchmakingService:_builderLoop()
	while true do
		task.wait(Config.Matchmaking.PollSeconds)   -- 3
		for _, bucket in Config.Matchmaking.Buckets do
			local queue = MemoryStoreService:GetQueue(`KN_MM_{bucket.MapId}_{bucket.Tier}`, 30)
			local ok, items, id = pcall(queue.ReadAsync, queue, 4, false, 30)
			if not ok or not items or #items == 0 then continue end

			-- Backfill rule: launch at 4 immediately, or at 2+ after WaitSeconds,
			-- or solo after SoloSeconds. Nobody waits longer than SoloSeconds.
			local oldest = items[1].JoinedAt
			local waited = os.time() - oldest
			local launch = #items >= 4
			           or (#items >= 2 and waited >= Config.Matchmaking.WaitSeconds)   -- 15
			           or waited >= Config.Matchmaking.SoloSeconds                     -- 30

			if launch then
				queue:RemoveAsync(id)
				self:_launch(items, bucket)
			end
		end
	end
end
```

**Design rules that matter more than the code:**
- **Nobody ever waits more than 30 seconds.** After that they launch solo or with whoever is there. A player staring at a spinner is a player closing the app.
- Show the queue as filling portraits — "2/4 kings gathering…" — not a progress bar. Seeing other players appear is itself the sell for co-op.
- The player can build their loadout and browse heroes **while queued**. Never freeze the lobby on a modal.
- If a matched player fails to teleport, the run proceeds without them. Never block three players on one bad connection.

### 34.3 Rejoin *(overrides the v1 "not supported" decision)*

Mobile players get phone calls, app-switch, background-kill, and lose signal in lifts. Losing a 9-minute co-op run to a Wi-Fi hiccup is a rage-quit generator, and rage-quits are the expensive kind of churn because they arrive right after the player's best session.

```lua
-- On match start, for every player:
local map = MemoryStoreService:GetHashMap("KN_Rejoin")
pcall(map.SetAsync, map, tostring(player.UserId), {
	Code = reservedCode, PlaceId = Config.MatchPlaceId, MapId = state.MapId,
}, Config.Matchmaking.RejoinTtl)   -- 1200 seconds

-- On run end, for every player: pcall(map.RemoveAsync, map, tostring(player.UserId))

-- In the lobby, on join: if a record exists, show REJOIN RUN prominently.
```

Rules:
- Rejoin restores the champion at the castle, **full HP, at the next morning** — never mid-night, which would drop a confused player into chaos.
- Their buildings, rally flags, and units were never removed.
- Wave scaling does not change on disconnect or rejoin (it is snapshotted at run start).
- A player who rejoins is paid rewards normally. Only a player who never returns forfeits.
- The ghost marker holds their slot for 300 seconds so teammates can see they might come back.

### 34.4 Config additions

```lua
Config.Matchmaking = {
	PollSeconds = 3,
	WaitSeconds = 15,     -- launch with 2+ after this
	SoloSeconds = 30,     -- launch with whoever's there after this — hard ceiling
	RejoinTtl   = 1200,
	RejoinWindowSeconds = 300,
	Buckets = { --[[ {MapId, Tier} pairs generated from Config.Maps × Config.Difficulty ]] },
}
```

---

## 35. ENDLESS SIEGE *(NEW IN v2)*

### 35.1 Why
This is the long-tail retention engine, and it is nearly free — waves, scaling, scoring, and the enemy simulation all already exist. "How far can you get" is a language Roblox speaks fluently, and it gives your best players somewhere to go after they have beaten four campaign maps.

### 35.2 Design

```
• One compact purpose-built map. Fewer slots than a campaign map (about 16), so
  decisions stay tight and the run stays readable at wave 40.
• Nights never stop. Every night the wave budget grows and new enemy types unlock.
• Full hero power applies — no normalization (§36). This is where the collection pays off.
• Score = nights survived × difficulty multiplier + buildings alive + kills/10.
• Weekly leaderboard, MemoryStore SortedMap with a 7-day TTL, resets Monday 00:00 UTC.
• A run ends when the castle falls. There is no win state — that is the point.
```

### 35.3 Wave generation

Endless is the **only** place procedural waves are allowed. Everywhere else, waves are hand-authored.

```lua
function EndlessService:BuildWave(night: number): { Types.WaveEntry }
	local budget = Config.Endless.BaseBudget * (Config.Endless.Growth ^ night)  -- 1.11^n
	local pool = filterByUnlockNight(Config.Enemies, night)
	local entries = {}
	while budget > 0 do
		local def = weightedPick(pool, night)          -- later nights weight heavier enemies
		local count = math.max(1, math.floor(budget / (def.Hp * 0.05)))
		count = math.min(count, Config.Endless.MaxPerEntry)
		table.insert(entries, {
			EnemyId = def.Id, Count = count,
			SpawnIndex = math.random(1, Config.Endless.SpawnPoints),
			StartDelay = math.random() * 8, Interval = 0.5,
			Elite = night > 20 and math.random() < 0.25 or nil,
		})
		budget -= count * def.Hp * 0.05
	end
	return entries
end
```

**Milestone nights** every 5: a boss, a mutator that activates permanently for the rest of the run, or a free upgrade choice. These are the beats that make a 40-minute Endless run feel structured rather than flat.

### 35.4 Performance
Endless is where you will hit the 200-enemy cap. Enforce it in the spawner: if `GetActiveCount() >= Config.Perf.MaxActiveEnemies`, the spawn thread waits rather than exceeding. Never let a procedural budget outrun the simulation.

---

## 36. DIFFICULTY TRACKS AND POWER NORMALIZATION *(NEW IN v2)*

### 36.1 The tension, and the resolution

Hero collection is power progression. §1.4 rule 7 says enemies are countered, not out-statted, and the whole campaign is a designed puzzle. A player with five Legendary heroes at level 5 would trivialize campaign maps, and a trivialized puzzle is not a puzzle.

**Resolution: two tracks.**

| Track | Hero power | Why |
|---|---|---|
| **Campaign** | Normalized — hero contribution capped to the map's tier | The puzzle stays a puzzle. Scores stay comparable. A day-one player and a day-200 player face the same design |
| **Endless & Trials** | Uncapped — full roster power | Where the collection pays off. Chase your own ceiling |

```lua
function HeroService:GetEffectiveLevel(player: Player, heroId: string, ctx: RunContext): number
	local owned = profile.Data.Heroes[heroId].Level
	if ctx.Mode == "Campaign" then
		return math.min(owned, Config.Maps[ctx.MapId].HeroLevelCap)   -- 1..5 per map tier
	end
	return owned
end
```

Tutorial map caps at 1, mid maps at 3, the final map at 5. So collection still *feels* useful in campaign — it unlocks access to a hero's roles and passives, just not runaway stats.

### 36.2 Difficulty tiers

Selected at map select, per run. Default a new player to **Casual** and let them opt into pain.

| Tier | Enemy HP | Enemy damage | Crowns | Shards | Notes |
|---|---|---|---|---|---|
| **Casual** | ×0.75 | ×0.75 | ×0.7 | ×0.7 | Default for `RunsPlayed < 3`. Build hints stay on |
| **Normal** | ×1.0 | ×1.0 | ×1.0 | ×1.0 | The designed experience |
| **Heroic** | ×1.45 | ×1.35 | ×1.5 | ×1.6 | Unlocks after a first Normal win on that map |

The source game is genuinely hard, and this audience skews younger than its. A difficulty selector is not a compromise of the design — it is what lets the *designed* difficulty exist without bouncing the players who would have grown into it.

### 36.3 Build hints (nights 1–3)

Strategy games have a comprehension wall, and comprehension walls are bounce.

```
• During days 1-3, the slot a strong player would build next gets a soft pulsing glow
  and a small "suggested" tag.
• Priority: economy first (houses), then one tower covering the active spawn lane.
• Disabled automatically after night 3, after the player's third completed run, or
  by a settings toggle — whichever comes first.
• Never blocks input, never forces the choice, never shows a modal.
```

This teaches the economy-first opening, which is the single most important thing a new player does not know, without a single line of tutorial text.

---

## 37. MOUNTS AND COSMETIC COLLECTIONS *(NEW IN v2)*

The source game's king rides a horse; v1 dropped it. Bring it back — as a cosmetic collection, which is the healthiest monetization axis available and costs the balance nothing.

### 37.1 Design
- A mount is a model welded under the champion, plus a WalkSpeed **visual** treatment (dust trail, gallop animation, footstep audio). **Mounts grant no stats.** Not 1%. The moment a mount grants speed, it becomes power and it belongs in the balance discussion forever.
- 6 at launch: Bay Horse (default), Warhorse, Dire Wolf, Sand Lizard, Skeletal Steed, Sun Stag.
- Sources: Crowns (2 of them), Stable Pass (3), seasonal event (1, never re-sold — this is what makes the collection mean something).
- Visible to all four players in every run. This is the flex.

### 37.2 Why this is the best cosmetic axis
Every other cosmetic in the game (castle skins, banners) is static scenery. A mount is attached to the thing players actually watch — the champion, moving, for nine minutes. It is the only cosmetic that is on screen continuously, and it makes the ride-between-slots loop feel better, which is the second-most-repeated action in the game.

### 37.3 Other cosmetic collections
| Collection | Where it shows | Source |
|---|---|---|
| Castle skins | The castle, which visually assembles as you build — a whole-server flex | Crowns / VIP / seasonal |
| Banners | Flown from walls and towers | Level rewards |
| Victory poses | The whole party auto-strikes one on the wall at victory (§38.1) | Crowns / event |
| Weapon trails | Champion attacks | Hero level 5 rewards |

---

## 38. VIRALITY — CLIP MOMENTS, CODES, EVENTS, TITLE *(NEW IN v2)*

v1 had no designed shareable moment. Shorts and TikTok are the cheapest top-of-funnel that exists, and they need something to point a camera at.

### 38.1 The three clip moments

Build all three. Each must be recognisable **without audio**, because that is how most of them will be watched.

| Moment | Trigger | Presentation |
|---|---|---|
| **Boss finisher** | Killing blow on any boss | 0.4s slow motion, camera pushes in, screen desaturates except the boss, impact freeze, then a shockwave |
| **LAST STAND** | Castle drops below 10% and the night is survived | Full-screen text flash, red-to-gold palette flip, all towers pulse, a rising sting |
| **Victory pose** | Run won, co-op | Camera orbits to the wall, all champions auto-strike a synchronized pose with their mounts, banner drops. **Never auto-dismiss** — let them screenshot |

The victory pose in particular is designed to be a group photo. Group photos get posted.

### 38.2 Codes
Ship a code with every update. Give creators a reason to feature you, and give players a reason to watch content about the game. Codes redeem for Crowns and shards, never for heroes directly — a code-unlocked Legendary devalues the collection for everyone who earned it.

Implementation: a server-side code table in `Config`, redemption recorded in `profile.Data.RedeemedCodes` for idempotency, rate-limited at 1/5s.

### 38.3 Server-wide events
A weekend **Blood Moon**: a mutator applies to every run universe-wide, Crowns and shards pay double, a unique banner drops for anyone who wins three runs during it. Costs you a DataStore-backed config flag polled every few minutes, with MessagingService as an instant-refresh hint. Buys you a reliable returning-player spike most months.

### 38.4 The title
"Kingdom Nights" tells the algorithm nothing. Roblox search is noun-driven and players type genre words.

> **⚔️ Kingdom Nights: Castle Defense**

Front-load a searchable noun. Iterate the icon aggressively during soft launch — icon CTR is the single highest-leverage number in Roblox discovery, and it is cheap to test.

---

## 39. REVISED KICKOFF PROMPT *(supersedes §32)*

Paste this to start implementation:

> Use the `roblox-game-dev` skill. We're building **Kingdom Nights: Castle Defense**, per `kingdom-nights-build-spec-v2.md` (attached) and the accompanying `Config.luau` (v2).
>
> Start **Phase 1: core loop graybox** in the match place only, solo, no art. Phases 3–6 add the v2 systems (matchmaking, heroes, difficulty, Endless); Phase 1 is unchanged from v1 and is still the right starting point — the core loop must be proven fun before any collection layer goes on top of it.
>
> Deliver complete files, each headed with its exact location and class:
> 1. `ReplicatedStorage/Shared/Types.luau` — **including the v2 hero types from §33.6**
> 2. `ReplicatedStorage/Shared/Net.luau`, `Signal.luau`, `Trove.luau`, `Guard.luau`, `RateLimit.luau`, `Cooldown.luau`
> 3. `ReplicatedStorage/Shared/Util/Pool.luau`, `SpatialGrid.luau`, `TableUtil.luau`
> 4. `ServerScriptService/Server` (bootstrap)
> 5. `ServerScriptService/Services/MatchService.luau` — the full phase machine from §7
> 6. `ServerScriptService/Services/BuildService.luau` — §8
> 7. `ServerScriptService/Services/EconomyService.luau` — §9
> 8. `ServerScriptService/Services/WaveService.luau` — §10
> 9. `ServerScriptService/Services/EnemyService.luau` — §11, pooled, no Humanoid, one flat Heartbeat loop
> 10. `ServerScriptService/Services/CombatService.luau` — §12
> 11. `ServerScriptService/Services/ChampionService.luau` — §13, auto-attack only for now
> 12. `StarterPlayer/StarterPlayerScripts/Client` (bootstrap) + `BuildController`, `HUDController`, `CameraController`
>
> Constraints: `--!strict` everywhere, all numbers from `Config`, server authority on every state change, no allocation in Heartbeat, no Humanoid on enemies or units (champions only). Target a **6-minute** graybox run, not 12.
>
> Then give me step-by-step Studio instructions to assemble the graybox map with tagged slots, spawns, and lane nodes so I can playtest it the same day.

---

## APPENDIX A — THE WAYS THIS PROJECT DIES *(updated for v2)*

1. Building the meta before the moment loop is fun. Fix the graybox first.
2. `Humanoid` + `PathfindingService` enemies. Solve it in Phase 1–2, not Phase 6.
3. Porting hold-`R` unit commanding literally. Mobile is the majority. Rally flags.
4. Enemy silhouettes that read alike — the source game's own admitted flaw, ten times worse on a phone screen.
5. Adding a day timer "for tension". It deletes the thing that makes the design pleasant.
6. Paying nothing for a lost run. Crowns *and* shards, every time.
7. Selling in-run power — including the Robux continue (§29.5).
8. Ten slot types on map one. Two.
9. Skipping the juice pass. The building plop is load-bearing, not decoration.
10. Saving run state. It is a 9-minute run — persist nothing but the profile.
11. **(v2) Shipping without public matchmaking.** Co-op is the headline feature; party-only hides it from the majority of players.
12. **(v2) Letting hero collection into campaign uncapped.** The moment the puzzle can be brute-forced with a Legendary roster, the design that made the game good is gone.
13. **(v2) Runs longer than 9 minutes.** Every extra minute is a bigger commitment you are asking a stranger to make before they know if they like you.
14. **(v2) Adding heroes slower than two a month.** The collection is the retention engine. An engine you stop feeding stops.

## APPENDIX B — LEGAL

Mechanics are not protected; day/night hero-defense is a shared genre skeleton. Do not take: the name Thronefall or anything near it, any asset, or the German map names (Neuland, Nordfels, Durststein, Frostsee, Uferwind, Sturmklamm, Wildbach, Moorweg, Freifort, Totend). Kingdom Nights, Greenhollow, Ashridge, Frostmere, and Blackfen are original. Roblox moderation is stricter than the law here — a near-identical name is a fast takedown regardless of legal nuance.
