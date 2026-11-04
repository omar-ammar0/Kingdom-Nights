# Kingdom Nights — Map & Asset Brief (for ChatGPT)

**From:** Claude (lead engineer) · **For:** ChatGPT (map design & 3D modelling) · **Owner:** Omar
**Date:** 2026-10-13

You are joining an in-progress Roblox game, *Kingdom Nights: Castle Defense* — a co-op day/night
kingdom-defense game. The game systems are built and working. **Your job is the content: maps and
models.** Everything in this document was taken from the live code, not from the design docs, so
when this brief and an older doc disagree, this brief wins.

Read alongside: `character-roster-and-design-brief.md` (style bible for characters — with one
correction in §8.2 below) and `kingdom-nights-build-spec-v2.md` §23 (map pipeline).

---

## 1. How we work together — through this folder

**You never touch Studio.** You write files into the project folder; Claude validates them and
builds them into Studio. The folder is our shared channel:

```
Thronefall Roblox/
  COLLAB-LOG.md              ← both of us append here. Read it first, every time.
  chatgpt-out/
    maps/                    ← Map_Greenhollow.json, Map_Ashridge.json …
    buildings/               ← House_L1.json, House_L2.json, Tower_L1.json …
    enemies/                 ← weakling.json, swordsman.json …
    units/                   ← knight.json, archer.json
    waves/                   ← ashridge.lua  (proposed Config entry, §6)
    reference/               ← your reference sheets / concept images
```

| Area | Owner | Rule |
|---|---|---|
| `chatgpt-out/*` | **ChatGPT** | Your deliverables. Bump `version` inside the file on every revision |
| Everything in Studio, all code, `Config` | **Claude** | Built from your files. Never send code to run |
| Wave tables, gold, any number | **Omar approves** | You propose (§6); Claude validates and integrates |
| `COLLAB-LOG.md` | **Both** | Append-only. Never edit or delete the other side's entries |

**The loop:** you drop a file and append a log entry saying what it is → Claude imports it,
validates it, and appends what passed, what failed and why (with exact error lines) → you revise
and bump `version`. Every model and map is delivered as data in the format in **§11** — never as a
Luau script.

---

## 2. Hard rules — breaking any of these breaks the game

1. **The battlefield is flat, at Y = 0.5.** The walkable ground's top surface sits at exactly
   **Y = 0.5** (`Config.Graybox.GroundY`). Enemies are moved by code along the lanes at that height
   and **ignore terrain completely** — they do not raycast for the floor. Hills, ramps, bridges or
   raised paths anywhere enemies or champions travel will make enemies float or walk through the
   ground. Height variation is fine **outside** the playable area as backdrop.
2. **No `Humanoid` on anything except player champions.** Enemies, allied units and heroes are
   anchored part assemblies moved by CFrame. A Humanoid on an enemy is a performance failure at
   the 120–180 enemy counts this game runs.
3. **No scripts inside maps or models.** All behaviour lives in Claude's code.
4. **Moving models: anchored root, unanchored children.** See §8.2 — this corrects the character brief.
5. **Map model `ModelStreamingMode = Persistent`.**
6. **Original names and assets only.** Nothing named or taken from *Thronefall*. Map names in use:
   Greenhollow, Ashridge, Frostmere, Blackfen.

---

## 3. Map structure

Reference implementation: `ServerStorage/Maps/Map_Graybox` — open it, it is the working example.

```
ServerStorage/
  Maps/
    Map_Greenhollow          (Model, ModelStreamingMode = Persistent)
      Ground                 (Part — top surface at Y = 0.5)
      Slots/                 (Folder — every BuildSlot)
      Spawns/                (Folder — every EnemySpawn)
      Lanes/                 (Folder — every LaneNode)
      Decor/                 (Folder — everything purely visual)
      Bounds/                (Folder — invisible walls at the map edge, §3.5)
```

The code finds things by **CollectionService tag + attributes**, not by folder — but use the
folders anyway, it keeps maps readable.

Graybox reference scale: ground 420 × 420 studs, castle at the origin, spawns ~225 studs out on
the diagonals (`-160, y, -160` and `160, y, 160`), slots 28–70 studs from the castle.

### 3.1 BuildSlot — where buildings can go

Players **cannot choose what to build or where**. Every slot accepts exactly one building type.
Slot placement *is* the level design.

| Property | Value |
|---|---|
| Class | `Part` |
| Tag | `BuildSlot` |
| Attribute `SlotId` | string, **unique within the map**, max 32 chars. Convention: `hou_01`, `twr_04`, `cas_01` |
| Attribute `SlotType` | exact string from §4 |
| Attribute `MaxLevel` | number, ≤ the level count in §4 |
| Attribute `StartLevel` | `0` for every slot except the Castle, which is `1` |
| `Anchored` | true |
| `CanCollide` / `CanQuery` / `CanTouch` | false / false / false |
| Size | flat pad, 0.4 tall. Footprint ≥ the building that goes on it: House 9×9, Tower 10×10, Wall 12×12, Barracks/Archery 11×11, Castle 16×16 |
| Position | Y = 0.7 (sitting on the ground) |
| Orientation | **Y rotation is used** — the building is placed facing the slot's rotation |

**Exactly one Castle slot per map.** It is the loss condition.

Slots should read as "something goes here" before anything is built — a dirt foundation, cleared
plot or stone outline as part of the map. Graybox uses a 55%-transparent pad.

### 3.2 EnemySpawn — where waves enter

| Property | Value |
|---|---|
| Class | `Part`, anchored |
| Tag | `EnemySpawn` |
| Attribute `SpawnIndex` | `1, 2, 3…` contiguous, no gaps |

Put them at the edge of the playable area. Wave tables reference spawns by this index.

### 3.3 LaneNode — the path enemies walk

There is **no pathfinding**. Each spawn has one authored lane of nodes enemies walk in order.

| Property | Value |
|---|---|
| Class | `Part`, anchored, CanCollide/CanQuery/CanTouch false |
| Tag | `LaneNode` |
| Attribute `SpawnIndex` | which spawn this lane belongs to |
| Attribute `Order` | `1, 2, 3…` contiguous per lane, no gaps or duplicates |

- **Spacing 15–30 studs** between consecutive nodes. Wider and enemies cut corners through
  buildings; tighter wastes memory. Graybox uses 21–28.
- Node 1 near the spawn; the **last node near the castle** — when a lane runs out, enemies head
  straight for the castle.
- Enemies spread **about 18 studs** sideways from the lane line so a wave reads as a horde, not a
  queue. Keep the lane corridor visually clear on that width.
- **Walls should sit across lanes.** Walls physically block enemy movement (block radius 26 studs);
  a wall that isn't on a lane does nothing.
- **Flying enemies ignore lanes** and fly straight from spawn to target at 20 studs height.
- **No turn sharper than 90°** between consecutive lane segments. Enemies that detour to attack a
  building rejoin the lane at whichever node is nearer; a hairpin would make them skip a node.
- **Ground enemies follow the lane faithfully** and only leave it for something within about 30
  studs (their aggro radius) — a building, a unit, a champion, or a wall in their way. When the
  lane ends they go for the castle. So the lane *is* the attack route: buildings within ~30 studs
  of it will be fought over; buildings further away are safe from ground enemies.
- **Use the threat band on purpose.** Think of three distances from a lane's centre line:

  | Distance from lane | What happens | Put here |
  |---|---|---|
  | 0–18 studs | Inside the horde. Enemies walk through it | Walls only (and the Castle at the lane's end) |
  | **18–30 studs** | **Threatened.** Passing enemies break off and attack it | Some Houses and Towers — economy the player must choose to defend |
  | beyond ~30 | Safe from ground enemies (ranged and flying enemies still reach) | The rest of the economy |

  A map where nothing but the Castle and Walls sits inside 30 studs has no economic risk at all,
  and the game's core "destroyed buildings pay no income next morning" lesson can never happen.
  Every map should put **some** income buildings in the 18–30 band. (Greenhollow v1 put every
  plot beyond 30 studs because an earlier version of this brief only warned about the 18-stud
  spread — Claude's mistake, not yours.)
- **Make the lane visible.** Players plan their defence around where enemies walk, so the route
  should read as a road at the gameplay camera — see §3.4.

### 3.4 Decor

Everything purely visual — the importer makes it non-colliding and non-interactive.

**Road surfaces** are decor: flat strips **0.04 studs thick with their top at Y = 0.52**, laid over
the Ground (which stays the single walkable floor at 0.5). The 0.02 lift stops them flickering into
the ground; it's far too small for anyone to notice walking on it. Reuse and merge repeated pieces. Keep decor below ~20 studs inside the battle
area so flyers don't visually clip through it. Remember the camera: **angled top-down at about
55°, 55–115 studs from the player**, mostly on phones. Design for that view, not ground level.

### 3.5 Bounds — the map edge

Without an edge, a champion can ride straight off the side of the map into the void. Put
**invisible collision walls** around the playable area in the `Bounds` folder (`transparency: 1`,
tall enough to stop a jumping champion — 20 studs is plenty), and dress the edge visually in
`Decor` with a tree line, fence, cliff face or river bank so the boundary reads as a place, not an
invisible wall. Bounds parts collide with champions only; enemies ignore them.

### 3.6 Validation

When a match loads a map, the server validates it and prints either
`[Build] map 'Map_X' validated - 0 errors` or one `[Build] MAP VALIDATION:` warning per problem:
missing/duplicate SlotId, bad SlotType, MaxLevel too high, not exactly one Castle, spawn with no
lane, lane with a gap in Order, wave entry referencing a missing spawn or unknown enemy. **A map is
not done until it validates with 0 errors.**

---

## 4. Building types you can place

| SlotType | Levels | What it does | Status |
|---|---|---|---|
| `Castle` | 3 | Loss condition; shoots; branching upgrades at L2/L3 | ✅ |
| `House` | 2 | Gold income each morning | ✅ |
| `Field` | 1 | Gold income | ⚠️ see §9 |
| `Mill` | 3 | Gold income; branching upgrade at L1 | ⚠️ see §9 |
| `GoldMine` | 1 | Gold income (flat for now) | ⚠️ see §9 |
| `Tower` | 3 | Shoots; branching upgrades at L2/L3 | ✅ |
| `Wall` | 3 | Blocks lanes, high HP | ✅ |
| `Barracks` | 3 | Spawns melee units | ✅ |
| `ArcheryRange` | 3 | Spawns ranged units | ✅ |
| `HeroQuarters` | 2 | Deploys a hero (collection is Phase 4) | ✅ |
| `Blacksmith` | 3 | Army-wide research | ⚠️ see §9 |
| `RoyalForge` | 3 | Champion research | ⚠️ see §9 |
| `Temple` | 3 | High-risk research | ⚠️ see §9 |
| ~~`Harbour`~~ | — | **Do not use.** Has no gameplay implemented | ❌ |

### Slot counts per map (from the design spec)

| Map | Character | Nights | Towers | Walls | Houses | Mills | Mines | Barracks | Archery |
|---|---|---|---|---|---|---|---|---|---|
| **Greenhollow** (tutorial) | Teach | 5 | 3 | 1 | 7 | 1 | 0 | 1 | 0 |
| **Ashridge** | Balanced | 8–10 | 12 | 14 | 11 | 3 | 0 | 2 | 2 |
| **Frostmere** | Kill zones, few chokepoints | 8–10 | 22 | 4 | 16 | 0 | 1 | 2 | 2 |
| **Blackfen** | Fortress, siege-heavy | 8–10 | 26 | 20 | 12 | 4 | 3 | 2 | 2 |

Vary the *shape* of each map, don't just scale it up. Frostmere's 22 towers and 4 walls make it a
completely different puzzle from Ashridge — that is the point.

---

## 5. Run-length constraints

- A run is **6–9 minutes. 9 is a hard ceiling.** If a map plays long, cut nights — never shorten
  the day (players enjoy the day).
- Campaign maps: **8–10 nights**, each night **45–75 seconds**.
- The day phase has no timer; players build at their own pace.

---

## 6. Wave tables — propose these, Claude integrates them

Waves are **hand-authored, never random**. Players see each night's wave in advance and build
against it; that is what makes the game a puzzle.

Propose each map's table in exactly this shape:

```lua
ashridge = {
	Id = "ashridge", Display = "Ashridge", Theme = "Highland", Difficulty = "Medium",
	StartGold = 3, UnlockLevel = 3, DifficultyMult = 1.2,
	Model = "Map_Ashridge",
	HeroLevelCap = 3,           -- 1 tutorial, 3 mid maps, 5 final map
	TargetSeconds = 450,
	Nights = {
		{ Night = 1, Entries = {
			{ EnemyId = "weakling", Count = 6, SpawnIndex = 1, StartDelay = 0, Interval = 0.9 },
		}},
		-- ...one entry per night
	},
},
```

**Valid `EnemyId`s** — exactly these strings:

| Family | Ids |
|---|---|
| Human | `weakling`, `swordsman`, `archer_e`, `pikeman`, `ogre`, `darkwarrior` |
| Monster | `slime`, `racer`, `spiderling`, `exploder` |
| Flying | `wasp`, `bloodwing` |
| Siege (targets buildings) | `ram`, `catapult` |
| Boss | `fenwraith` |

**Size waves for four players, not one.** The game scales every wave by
`1 + 0.35 × (players − 1)`, so a 4-player party gets **2.05×** what you author. The engine's
comfortable peak is 120–180 enemies alive at once, hard cap 200. So author your biggest night to
peak around **60–85 enemies alive solo** — that lands at 120–175 with four. Authoring 180 solo
means 369 at four players: the spawner stalls at the cap and the night drags.

Counter design matters: enemies are beaten by the *right* damage type, not bigger numbers. Flying
enemies are immune to the Warden's sword; siege enemies ignore champions and hit buildings. A good
wave asks a question the slot layout lets players answer.

**Greenhollow already has a wave table** (5 nights, 2 spawns) — it only needs a map model. Build it
with **exactly 2 EnemySpawns** so the existing table validates.

---

## 7. Order of work

1. **Greenhollow map** — the tutorial, and the first thing every new player sees. The wave table
   exists, so this is pure map work.
2. **Ashridge map + its wave table** — the first 8–10 night map, which unblocks the "4 players,
   10 nights, under 9 minutes" test.
3. **Character Batch 1** — Warden, Knight, Weakling, Swordsman (per the character brief §1.6).
4. **Building models** — Castle, House, Tower, Wall first (they appear in every map).
5. Frostmere, Blackfen, and the remaining character batches.

**Definition of done for a map:** validates with 0 errors · every slot count matches §4 · a solo
run on Normal fits inside 9 minutes · Omar has played it once.

---

## 8. Model contracts

### 8.1 Buildings

```
ReplicatedStorage/Assets/Buildings/<Model>/L1, L2, L3    (one Model per level)
```

`<Model>` is exactly the SlotType name (`Castle`, `House`, `Tower`…). Each level should look
visibly grander than the last — upgrading is one of the most-repeated actions in the game.

- **Pivot at the base centre**, bottom at the model's Y = 0, front facing −Z.
- Footprint inside the slot pad (§3.1). Height guide — the current graybox placeholders:
  Castle 16 → 26, House 6 → 9, Tower 15 → 27, Wall 8 → 14 (14 wide × 4 deep), Barracks/Archery
  ~7 tall and wide-and-low so they read as compounds, not towers.
- Physics flags are set by Claude's importer — you don't specify them (§11).

### 8.2 Enemies, allied units, heroes — **corrects the character brief**

```
ReplicatedStorage/Assets/Enemies/<EnemyId>     e.g. Enemies/weakling
ReplicatedStorage/Assets/Units/<UnitId>        knight, archer
```

Folder name = the exact id from §6.

> ⚠️ **Correction to `character-roster-and-design-brief.md` Part 4.** It says *"Every part:
> Anchored = true"* and *"Weld everything to the PrimaryPart."* Those two together produce models
> that **don't move**: the code moves an enemy by setting its root's CFrame, and welds only carry
> **unanchored** parts along. Anchored children stay where they spawned.
>
> **Correct rule:** the PrimaryPart (named `HumanoidRootPart`, at the base centre) is
> `Anchored = true`. **Every other part is `Anchored = false`**, welded to the PrimaryPart with a
> `WeldConstraint`. All parts `CanCollide = false`, `CanQuery = false`, `CanTouch = false`.
>
> In practice: mark exactly one part `"root": true` in your file (§11) — a small block at the base
> centre — and Claude's importer applies all of the above. You never set these flags yourself.

Everything else in the character brief stands: primitives only, the part budgets (hard ceilings —
180 enemies × parts is the performance cost), ≤4 colours, faction palettes, the 30-pixel silhouette
test, the height references.

---

## 9. Known engine gaps — Claude's side, being fixed

So you know what not to rely on yet:

- **Buildings: ready.** Building models load from `Assets/Buildings`, and anything not yet modelled
  falls back to a grey box (verified 2026-10-13). A missing upper level reuses the highest level
  below it, so `House/L1` alone already covers a level-2 House.
- **Enemies and units: not yet.** Their pool was built for single grey-box parts and needs a
  per-type rebuild for multi-part models. Claude does that when your first enemy file arrives, so
  it's tested against a real model. Deliver them anyway — nothing is wasted.
- **Mill, Field, GoldMine, Blacksmith, RoyalForge, Temple: fixed** (2026-10-13). They used to crash
  on construction; they now build.
- **Enemies follow lanes: fixed** (2026-10-13). Ground enemies used to ignore lanes entirely and
  walk straight at the nearest building anywhere on the map. Greenhollow's bent lane exposed it.
  Lanes, chokepoints and wall placement now behave as this brief describes.
- **GoldMine pays a flat income.** The designed "6 gold, decreasing each night" behaviour isn't
  built.
- **Harbour has no gameplay.** Don't place it.

---

## 10. Open decisions (Omar)

- **Map performance budget.** The spec doesn't set one. Claude's proposal: decor under ~2,500 parts
  per map, repeated pieces reused. Not yet approved — treat 2,500 as the ceiling until it is.

---

## 11. Delivery format — `kn-asset/1`

Every map and model is one JSON file describing its parts. Plain data only.

```json
{
  "format": "kn-asset/1",
  "kind": "enemy",
  "name": "weakling",
  "version": 1,
  "author": "ChatGPT",
  "notes": "Batch 1. Hunched, round head, no weapon.",
  "parts": [
    { "name": "HumanoidRootPart", "root": true, "shape": "Block",
      "size": [1.4, 0.4, 1.4], "position": [0, 0.2, 0], "orientation": [0, 0, 0],
      "color": "#8A3B3B", "material": "SmoothPlastic", "transparency": 1 },
    { "name": "Torso", "shape": "Block",
      "size": [2.2, 1.6, 1.6], "position": [0, 1.4, 0], "orientation": [12, 0, 0],
      "color": "#8A3B3B", "material": "SmoothPlastic" },
    { "name": "Head", "shape": "Ball",
      "size": [1.8, 1.8, 1.8], "position": [0, 2.6, -0.3], "orientation": [0, 0, 0],
      "color": "#3A3A3A", "material": "SmoothPlastic" }
  ]
}
```

### Top-level fields

| Field | Values |
|---|---|
| `format` | always `"kn-asset/1"` |
| `kind` | `"map"`, `"building"`, `"enemy"`, `"unit"` |
| `name` | map: `"Map_Greenhollow"` · building: `"House/L1"` · enemy: the enemy id (§6) · unit: `"knight"` or `"archer"` |
| `version` | integer, **bump on every revision** |
| `notes` | anything Claude should know |

### Per-part fields

| Field | Required | Values |
|---|---|---|
| `name` | yes | semantic: `Head`, `ArmLeft`, `WeaponBlade`, `Ground`, `hou_01` |
| `shape` | yes | `Block`, `Ball`, `Cylinder`, `Wedge`, `CornerWedge`. Note: a Roblox cylinder's length runs along its **X** axis |
| `size` | yes | `[x, y, z]` studs |
| `position` | yes | `[x, y, z]`. **Maps: world space. Models: relative to the pivot** — base centre at `0,0,0`, front facing −Z |
| `orientation` | yes | `[x, y, z]` degrees — identical to the Orientation property shown in Studio |
| `color` | yes | `"#RRGGBB"` |
| `material` | yes | `SmoothPlastic`, `Neon`, `Wood`, `WoodPlanks`, `Slate`, `Concrete`, `Grass`, `Brick`, `Cobblestone`, `Metal`, `Sand`, `Ice`, `Fabric`, `Rock`, `Ground` |
| `transparency` | no | 0–1, default 0 |
| `root` | models: exactly one | marks the PrimaryPart |
| `folder` | maps only | `"Slots"`, `"Spawns"`, `"Lanes"`, `"Decor"`, `"Bounds"`, or omit for top level (`Ground`) |
| `tags` | maps only | `["BuildSlot"]`, `["EnemySpawn"]`, `["LaneNode"]` |
| `attributes` | maps only | e.g. `{ "SlotId": "hou_01", "SlotType": "House", "MaxLevel": 2, "StartLevel": 0 }` |

**You never specify `Anchored`, `CanCollide`, `CanQuery` or `CanTouch`.** The importer sets them
from `kind` and the part's role, so the anchoring and collision rules in §2 and §8 can't be broken.

### What Claude's importer checks

The file is rejected with exact reasons if any of these fail: valid JSON and `format` · every
required field present and in range · names unique within the file · models have exactly one
`root` · character part counts within the budgets in `character-roster-and-design-brief.md` ·
characters use ≤4 distinct colours · maps pass every rule in §3 (one Castle, contiguous SpawnIndex
and lane Order, unique SlotIds, valid SlotTypes and MaxLevels), the `Ground` top surface is at
Y = 0.5, and the part count is under the §10 budget.

Large maps are fine as one file. Claude handles splitting it into Studio.
