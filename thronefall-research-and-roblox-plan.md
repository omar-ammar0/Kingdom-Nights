# Thronefall — Full Design Deconstruction & Roblox Adaptation Guide

*Research compiled August 2026. Part 1 deconstructs the original game. Part 2 translates it into a Roblox build plan.*

---

# PART 1 — THE ORIGINAL GAME

## 1. Snapshot

| | |
|---|---|
| Developer / Publisher | Grizzly Games (Jonas Tyroller, Paul Schnepf) — also made ISLANDERS and Superflight |
| Genre | Minimalist strategy / tower defense / action hybrid |
| Early Access | 2 August 2023 |
| Full release | 11 October 2024 |
| Scale | Passed 1 million copies sold shortly after the Nintendo Switch launch |
| Awards | Best Casual Game, German Game Developer Awards 2023 |
| Session length | 10–20 minutes per map |
| Players | Single-player only |
| Engine | Unity |

The pitch in one line: **you are a king on a horse; by day you spend gold on a fixed set of build slots, by night you personally fight the wave that attacks what you built.**

Its declared lineage: Kingdom (Thomas van den Berg), Stronghold, Age of Empires, Kingdom Rush, Mount & Blade, They Are Billions, and ISLANDERS. It is a deliberate *subtraction* of the strategy genre rather than an addition to it.

---

## 2. The design philosophy (this is the part worth stealing)

From the developers' own interviews, five principles drive everything. If you copy the buildings but miss these, you will build something that looks like Thronefall and feels nothing like it.

**2.1 — Subtract to create design space.**
The single biggest decision: *the player cannot choose what to build or where.* Every map ships with predefined build slots, each accepting one predefined building. The only decision left is **what order, and when**.

This sounds like a loss. It is actually the engine of the whole game, because it gives the designer total control:
- You can force the player to place economy in dangerous positions.
- You can guarantee they can't wall off a spawn point.
- You can cap building and unit counts without a supply/population system.
- You can control where units respawn and how far they have to walk — a huge strategic lever.
- You can guarantee the finished castle looks good.
- You can give every single level its own bespoke tech tree without breaking any other level.

**2.2 — Layer complexity slowly; never rebalance the onboarding.**
New buildings, units, upgrades, perks and weapons are added *at the end of the progression*, so the tutorial map stays untouched forever. The game grows with the player instead of front-loading them.

**2.3 — Forgiveness as a mechanic, not a difficulty setting.**
Every building destroyed at night is rebuilt for free the next morning. Units respawn. Heroes revive in ~10 seconds. The *only* permanent loss condition is the Castle Center falling. The punishment for losing a building is subtle: **it produces no gold on the morning it respawns**, and your end-of-night score drops. So the player is strongly incentivized to protect everything without ever being punished harshly enough to rage-quit. One mechanic serving three design goals at once — that's the pattern to imitate.

**2.4 — No idling.**
The explicit fix to Kingdom's weakness: the player does not stand and watch the night happen. They ride into it. Auto-attack keeps it accessible; the per-weapon active ability is the skill ceiling that beginners can ignore entirely.

**2.5 — Legibility over fidelity.**
Neither developer is a trained artist. The art style is a deliberate constraint: cel-shaded, very limited palette, simple low-poly meshes, and **silhouette as the primary information channel**, reinforced with outlines. Everything is readable at a glance during a chaotic night. They openly admit enemy silhouettes were their weakest point — enemies read too similarly to each other. *Learn from that failure; make your enemy silhouettes wildly distinct.*

---

## 3. The core loop

```
   ┌─ DAY (no timer, player ends it manually) ────────────────┐
   │  • Ride to build slots                                    │
   │  • Spend gold: economy vs military vs upgrades            │
   │  • Reposition units to cover approach lanes               │
   │  • Read the night preview: which spawn points, how many   │
   └──────────────────────┬────────────────────────────────────┘
                          │ player presses "start night"
   ┌──────────────────────▼────────────────────────────────────┐
   │  NIGHT (fixed wave, fixed spawn points)                    │
   │  • Enemies path toward buildings / Castle Center           │
   │  • Towers, walls, units auto-fight                         │
   │  • King fights directly + commands units                   │
   │  • Enemies drop gold on death (must be collected)          │
   └──────────────────────┬────────────────────────────────────┘
                          │
   ┌──────────────────────▼────────────────────────────────────┐
   │  MORNING                                                   │
   │  • All destroyed buildings/units restored free             │
   │  • Buildings that survived pay income; respawned ones don't│
   │  • Score awarded based on what survived                    │
   └───────────────────────────────────────────────────────────┘

Win: survive all nights on the map (8–19 depending on map).
Lose: Castle Center destroyed.
```

**Critical detail:** the day has *no time pressure*. The player ends it when ready. This is what makes it relaxing rather than stressful, and it's a deliberate anti-anxiety choice. Do not add a day timer.

**Second critical detail:** the night wave composition is *previewed during the day*. Little icons at each spawn point show what's coming and how many. The player plans against known information — this is a puzzle, not a reflex test.

---

## 4. The economy

**One resource: gold.** No wood, no stone, no food, no population. Every decision is "gold into economy" vs "gold into defense".

### 4.1 Income buildings

| Building | Cost | HP | Income | Notes |
|---|---|---|---|---|
| Fields | 1g | 10 | +1/night | Extremely fragile; unlocked by Mills |
| Houses | 2g | 20 | +1/night (Lv1), +2 (Lv2) | Safest — usually sit near the castle. Pays for itself in 2 nights |
| Bridges | 2g | 100 | +1/night | Also opens new map areas |
| Mills | 3g / 4g / 6g | 30 | +1 → +2 → **+6** total | Big payoff only at Lv3. Unlocks Fields |
| Fishing Harbours | 3g / 7g | 60 | 1 boat per morning, up to 5, +1g each; Lv2 doubles boat income | Water maps only |
| Gold Mines | 5g | 20 | +6 first night, **depletes 1/night** | Front-loaded; build early |

### 4.2 Defense & military buildings

| Building | Cost | HP |
|---|---|---|
| Walls | 3g | 240 |
| Towers | 3g | 100 |
| Barricades | 4g | — |
| Barracks (melee units) | 4g | 30 |
| Archery Range (ranged units) | 4g | 30 |
| Hero's Quarters (single hero unit) | 6g | 50 |

### 4.3 Special buildings

| Building | Cost | HP | Function |
|---|---|---|---|
| Castle Center | 3g (→ ~20g for Lv3) | 100 | Lose condition. Gates unlocks. Grants King upgrades |
| Blacksmith | 4g / 9g / 16g | 80 | Researches army-wide damage/armor |
| Royal Forge | 4g / 7g / 14g | 80 | Researches King-only combat stats |
| Temple | 2g / 6g / 25g | 150 | High-risk/high-reward global effects |
| Shrine | 3g | 777 | Very tanky; collects energy, drops gold |
| Summoning Circle | 1g | 10 | Cheap summon point |

### 4.4 Economic rules that shape play

- Enemies drop gold on death, and it must be physically collected by riding over it. This pulls the King out of position — a deliberate risk/reward tension.
- Some maps give **zero wave gold for the first 3–4 nights** (Freifort, Totend), forcing reliance on starting gold and building income.
- Starting gold ranges 0 (tutorial) to 23 (final map) — it's a difficulty and pacing dial, not a constant.
- Standard opening: economy first for the first 2–3 nights, because the King alone can clear early waves.

---

## 5. Upgrades — the real depth (34 across 6 buildings)

Most buildings offer a *choice* at each upgrade level, and the choice is permanent for that run. This is where the strategic identity of a run is formed.

### Castle Center — Level 2 (pick one)
| Upgrade | Effect |
|---|---|
| Royal Training | +75% King HP, +75% damage |
| Builder's Guild | Free house upgrade every morning, +50% King HP |
| Magic Armor | Attackers take reflected damage, +150% King HP |
| Assassin's Training | Precisely-timed attacks slash cooldown, +100% damage |

### Castle Center — Level 3 (pick one)
| Upgrade | Effect |
|---|---|
| Royal Mastery | +75% HP, +75% damage |
| Commander | Units fight *while following you*, +60% command speed, healing aura, +30% damage |
| Castle-Up | Wall/tower upgrade costs drop by 1 every night (min 1) |
| Godly Curse | Locked-on target takes +50% damage from all sources, +75% King HP |

### Towers — Lv2 specialization, then Lv3 spire
| Lv2 | Effect | | Lv3 | Effect |
|---|---|---|---|---|
| Castle Tower | +150 HP, faster attacks | | Archer's Spire | +350 HP, faster + extra arrow |
| Sniper Tower | More damage, longer range, slower | | Ballistic Spire | Massive damage, slows targets |
| Armored Tower | +350 HP, shield on damage | | Fire Spire | +250 HP, splash + oil |
| Bunker Tower | +75 HP, short range, unique pattern | | Healing Spire | +750 HP, heals allies instead of attacking |

### Mills — pick one improvement on first build, scales with later upgrades
| Improvement | Effect |
|---|---|
| Improved Plow | +1 income per future mill upgrade (best economy: 8g/night at max instead of 6) |
| Explosive Trap | Mill explodes when destroyed, big AoE |
| Scarecrows | Every field of this mill gets a free anti-air scarecrow |
| Wind Spirits | Intercepts a portion of enemy arrows in range |

### Blacksmith (army-wide) — one per level, 3 levels
+20% melee damage (3 nights) · +20% ranged damage (3 nights) · +30% melee resistance (2 nights) · +30% ranged resistance (2 nights)

### Royal Forge (King only) — one per level, 3 levels
−40% auto-attack cooldown (2n) · +50% HP & regen (2n) · −40% ability cooldown (3n) · +40% weapon damage (3n)

### Temple (powerful, with real drawbacks)
| Research | Effect |
|---|---|
| Sacrifice | Units die at nightfall but respawn 200–300% faster |
| Overload | Towers buffed but bleed health over time |
| Blessing | Big HP + attack, reduced movement speed |
| Ice Rain | Ice bolts damage *everything*, including your own units |
| Prayers | Shrines get more attack/range tonight but drop no gold tomorrow |
| Wisdom | Buildings destroyed at night drop gold (1–3), but all buildings slowly lose HP |

> **Research takes nights to complete.** This is a beautiful pacing mechanic — investing in research is a bet on surviving long enough to cash it in.

---

## 6. The King (player character)

| Stat | Value |
|---|---|
| HP | 100 |
| Move speed | 14 |
| Sprint speed | 23 (only at full HP by default) |
| Speed while dead | 8 |
| Base attack cooldown | 1.0s |

- The King **auto-attacks** anything in range. Accessibility decision.
- `Space` is context-sensitive: build/upgrade/start-night during the day, weapon ability at night.
- On death: short timer, then respawn at the Castle Center. **You can still move while dead**, slowly, but cannot attack. Death is a tempo loss, not a run loss.
- Passive HP regen after a delay out of combat.

### Weapons (9 — pick one before the level)

| Weapon | Range | Base DPS | AoE | Boss mult | Signature |
|---|---|---|---|---|---|
| Falchion & Traps | Close | 6.88 | No | 2x | Highest single-target melee; 2x vs Monsters |
| Bow & Dagger | Far | 5.26 | No | 2x (bow) / 3x (dagger) | 2.16x vs Flying; dagger burst 10 (30 vs boss) |
| Heavy Sword | Close | 4.00 | Yes | **3x** | Splash; 1.4x vs Ranged |
| Spear | Short | 1.71 | No | 2x | 2.06x vs Fast, 3s slow, self-heal on ability |
| Battle Ax | Close | 1.15 | Yes | 2x | 37.5% lifesteal, 2.25x vs Siege, **cannot hit flying** |
| Lightning Staff | Far | Varies | Yes | — | Hits everything in range simultaneously |
| Shadow Codex | Mid | AoE | Yes | — | Curses targets, AoE burst, range 15 |
| Blood Wand | Mid | Ramps | No | — | 1x → 10x scaling on the same target |
| Potion Vials | Far | 0.1 | Yes | — | Utility: heals and slows in an area |

Every weapon has a **passive auto-attack** and a **manual active ability**. Note the DPS spread is enormous (1.15 → 6.88) — it is balanced by damage-type multipliers, not by parity. A low-DPS weapon is a specialist.

Multipliers stack multiplicatively: Warrior Training (2x) × Glass Cannon (1.5x) × Sharper Weaponry (1.4x) takes Falchion from 6.88 to ~28.9 DPS.

---

## 7. Allied units

Recruited from Barracks (melee) / Archery Range (ranged) / Hero's Quarters (heroes). **Regular units come in groups that grow by 4 per upgrade. Heroes stay a single unit but get stronger per upgrade.**

| Unit | Type | HP | Dmg | Role |
|---|---|---|---|---|
| Knight | Melee | 105 | 2.5 | Frontline |
| Flails | Melee | 70 | 1.65 | Area damage |
| Spearmen | Melee | 66 | 2.02 | Anti-fast |
| Berserks | Melee | 58.5 | 2.5 | Anti-siege |
| Crossbowmen | Ranged | 45 | 7.0 | Anti-ranged / armor-piercing |
| Longbow Archers | Ranged | 25 | 4.0 | Long-range |
| Fire Archers | Ranged | 20 | 4.5 | Anti-air |
| Hunters | Hybrid | 45 | 2.74 | Anti-monster |
| Golem | Hero | 360 | 33 | Tank + AoE |
| Firewing | Hero | 30 | 4.0 | Anti-air ranged |
| Lizard Rider | Hero | 60 | — | Versatile |
| Support Mage | Hero | 75 | — | Healer |

All units move at speed 5 (vs the King's 14) — the King is dramatically more mobile than his army, which is what makes commanding meaningful.

### Unit commanding (the most divisive mechanic)
- `R` — gather nearby units into a follow group (a circle appears around the King)
- `R` again — release them at the current position
- Hold `R` after releasing — they hold position and defend that spot
- `Ctrl` — gather-while-running, so you can scoop units without stopping
- `F` — cycle unit type when commanding a mixed group
- `1`/`2`/`3`/`4` — instantly command all / melee / ranged / heroes regardless of distance

**Without the Commander castle upgrade, units cannot attack while following you** — they only walk. With it, they fight while following and move 60% faster. Reviewers have flagged this as the game's weakest link: tying all troop control to the hero's physical position is friction. **This is the #1 thing to redesign for Roblox** (see Part 2, §14).

---

## 8. Enemies — the bestiary

Four families: **Human, Monster, Siege, Boss.** Enemies carry tags (Flying, Fast, Siege, Monster, Ranged, Reduced Player Damage) that weapons and units counter. **Elite variants of any enemy have 4x HP and 3x damage.**

### Human
| Enemy | HP | Dmg | Speed |
|---|---|---|---|
| Weakling | 8.7 | 1 | 4 |
| Peasant | 8.7 | 1 | 4 |
| Archer | 20 | 2.5 | 5 |
| Swordsman | 25 | 2.5 | 5 |
| Pikes | 25 | 3.5 | 5 |
| Elite Crossbowman | 40 | 15 | 4 |
| Flail | 55 | 2.2 | 5 |
| Barrel Knight | 100 | 3.5 | 8 |
| Dark Warrior | 135 | 10 | 7 |
| Ogre | 200 | 20 | 4 |

### Monster
| Enemy | HP | Dmg | Speed | Note |
|---|---|---|---|---|
| Slime | 12.5 | 1.2 | 5 | |
| Small Spider | 12.5 | 2.4 | **15** | Fastest thing in the game |
| Wasp | 25 | 2.5 | 8 | Flying |
| Giraffe Slime | 30 | 1.5 | 5 | |
| Hunterling | 30 | 5 | 10 | |
| Racer | 35 | 2.5 | 10 | |
| Monster Rider | 40 | 3 | 11 | |
| Flying Mage | 45 | 2 | 7 | Flying |
| Fire Snail | 45 | 1.2 | 3 | |
| Spiky Slime | 50 | 3.6 | 5 | |
| Medium Spider | 50 | 6 | 14 | |
| Moleman Archer | 50 | 3.75 | 5 | |
| Bloodwing | 50 | 3 | 12 | Flying |
| Quicksling | 55 | 9.78 | 3 | |
| Moleman | 60 | 5 | 5 | |
| Exploder | 65 | **90** | 9 | Suicide bomber |
| Fury | 75 | 30 | 3 | |
| Ghost | 100 | 6.5 | 3.33 | |
| Strong Giraffe Slime | 100 | 3.5 | 7 | |
| Flogre | 275 | 9 | 4 | |
| Big Spider | 800 | 12 | 10 | |
| Thing | 1100 | 2.2 | 4 | Pure HP wall |

### Siege (targets buildings)
| Enemy | HP | Dmg | Speed |
|---|---|---|---|
| Catapult | 45 | **150** | 2 |
| Wheel | 180 | 3.5 | **15** |
| Iron Tower | 200 | 3.5 | 5 |
| Ram | 250 | 15 | 2.25 |
| Windboat | 300 | 15 | 3 |

### Bosses (3 maps have them)
| Boss | HP | Dmg | Map |
|---|---|---|---|
| Elara the Vile | 15,000 | 15.6 | Moorweg |
| Eldermole | 10,000 | 22.5 | — |
| Shadow in the Water | 100* | 6.5 | Frostsee |
| Strange Statue | — | — | Sturmklamm |
| Corrupt King | — | 80 | — |

*Shadow in the Water's low listed HP indicates a scripted/multi-phase fight rather than a stat check.*

**Design read:** the bestiary is built around *counters*, not power creep. Fast swarms punish slow melee. Flying punishes Battle Ax entirely (0x damage). Siege punishes lack of anti-siege. Exploders punish clumping. Every enemy is a question the player answers with build order and weapon choice.

---

## 9. Loadout modifiers

### Perks — 55 total, equip up to 5 (slots unlock at level 8 and 24)

Four categories. Representative examples:

**Economic:** Royal Mint (castle produces gold) · Interest (1g per 3g saved, cap 20) · Treasure Hunter (+15/+25/+40g before the last three waves) · Loan (+7 starting gold, first 10 enemy drops vanish) · Pumpkin Fields · Big Harbours · Indestructible Mines · Sustainable Mining · Faster Research

**Military:** Warrior Training (King up to 2x, allies −50%) · Commander Mode (allies +50%, King −50%) · Glass Cannon (+50% damage, much less HP) · Daredevil (low HP → up to +115% damage) · War Horse · Elite Warriors · Gladiator School · Pristine Warriors/Archers (2x cost, +75% damage & HP) · Royal Protection · Experience Gain (stacking buff per respawn)

**Defense:** Castle Fortifications · Castle Blueprints (+50% wall/tower HP) · Fortified Houses (+250% HP, houses shoot) · Explosive Walls · Emergency Repairs (walls share 25% HP) · Last Stand (all towers revive once when castle drops below 50%) · Power Tower · Elite Towers · Outpost (start with 2 free far towers)

**Special:** Ring of Resurrection (one revive per night, with all fallen units) · Ice Magic · Anti-Air Telescope · God's Lotion · Health Potions · Ancient Shrines · Timber Scaffolding · Architect's Council · Relentless Research

Note how many perks are **trade-offs, not upgrades**. Warrior Training and Commander Mode are direct opposites and define two entire playstyles: solo-carry king vs army commander. That's excellent design — perks change *how you play*, not just how big your numbers are.

### Mutators — 19, opt-in difficulty for score/XP multipliers

| Mutator | Effect | Reward |
|---|---|---|
| Challenge the Elite God | Every 3rd spawn is elite (4x HP, 3x dmg) | +75% |
| Challenge the God of Afterlife | Dead enemies respawn after a delay | +50% |
| Challenge the Growth God | Enemies get stronger every night | +50% |
| Challenge the God of Chaos | Enemies spawn at random map positions | +45% |
| Pacifist Pact | King cannot attack | +40% |
| No Units Pact | Cannot build units | +40% |
| Challenge the Turtle God | Enemies +75% HP | +40% |
| Challenge the Phoenix God | Enemies regen 4%/s | +30% |
| Challenge the Snake God | Enemies drop −50% gold | +30% |
| Falcon / Wasp / Tiger / Range / Destruction / Death Gods | Speed, early swarms, damage, ranged buffs, slower rebuilds, inactive allies | +20% each |
| No Towers Pact | Cannot build towers | +20% |
| No Walls Pact / God of Choice | Cannot build walls / restricted perks | +10% |
| Pray to the War Gods | Enemies −20% HP and damage | **−40%** (easy mode with a score cost) |

This is the entire replayability engine, and it costs almost nothing to build: they're global multipliers and boolean restrictions applied to existing systems. **Copy this pattern.** It's the highest content-per-line-of-code system in the game.

---

## 10. Maps

10 campaign maps. Each has unique terrain, its own subset of buildings, its own enemy roster, and its own build-slot layout.

| Map | Theme | Difficulty | Nights | Enemy types | Start gold |
|---|---|---|---|---|---|
| Neuland | Tutorial | Easy | 8 | 3 | 0 |
| Nordfels | Mountain & river | Medium | 13 | 7 | 8 |
| Durststein | Desert | Medium | 12 | 9 | 16 |
| Frostsee | Snowy tundra | Hard | 13 | 9 | 7 |
| Uferwind | Coastal grassland | Medium-Hard | 12 | 11 | 18 |
| Sturmklamm | Mountain | Hard | 13 | 15 | 11 |
| Wildbach | River & bridges | Medium | 13 | 11 | 14 |
| Moorweg | Swamp | Medium-Hard | 12 | 19 | 16 |
| Freifort | Fortress | Hard | 16 | 20 | 13 |
| Totend | Dark | Very Hard | 19 | 29 | 23 |

### Build-slot counts (the level-design fingerprint)

| Building | Neu | Nord | Dur | Frost | Ufer | Sturm | Wild | Moor | Frei | Tot |
|---|---|---|---|---|---|---|---|---|---|---|
| Towers | 3 | 10 | 16 | 17 | 26 | 24 | 17 | 27 | 31 | 26 |
| Walls | 1 | 16 | 15 | 18 | 28 | 4 | 14 | 7 | 21 | 20 |
| Houses | 7 | 11 | 13 | 18 | 13 | 11 | 10 | 12 | 13 | 11 |
| Fields | 5 | 15 | 20 | — | 25 | 15 | 15 | 10 | 20 | 15 |
| Mills | 1 | 3 | 4 | — | 5 | 3 | 3 | 2 | 4 | 3 |
| Gold Mines | — | — | 3 | 1 | — | 2 | 2 | 3 | 2 | 3 |
| Harbours | — | — | — | 3 | 3 | — | 1 | 1 | 2 | — |
| Barracks | 1 | 2 | 2 | 2 | 2 | 2 | 2 | 2 | 2 | 2 |
| Archery Range | — | 2 | 2 | 2 | 2 | 2 | 2 | 2 | 2 | 2 |
| Hero's Quarters | — | — | — | 2 | 1 | 2 | 1 | 2 | 2 | 3 |
| Shrine | — | 6 | 5 | 5 | 5 | 6 | 5 | 6 | 6 | 6 |

Read this table as **level design encoded as numbers**. Sturmklamm gives you 24 towers but only 4 walls — a map about kill zones, not chokepoints. Frostsee gives 18 houses and no mills or fields — an economy of one shape only. Freifort's 31 towers and 21 walls is a fortress-defense map. *Each map is a different economic and tactical puzzle expressed purely through slot counts.*

**Tutorial ramp:** Neuland has 3 towers, 1 wall, 1 barracks, no archery range, 3 enemy types, 8 nights, 0 starting gold. That is an incredibly tight tutorial — roughly a tenth of the final map's complexity.

---

## 11. Meta progression

- **XP → levels, max 54.** Unlocks maps, units (Flails at 6, Hunters at 19), perks, weapons, and extra perk slots (at 8 and 24). Everything is unlocked by level 54.
- **Quests:** up to 6 per map (A–F), 55 total, earning crowns. Examples: beat the map without a specific weapon, with specific perks, or with mutators active.
- **Bonus Modes:** 27 alternative challenge variants (3 per map) with fixed loadouts and unique objectives, earning Stars.
- **Eternal Trials:** endless roguelike mode with accumulated perks and high-score chasing.
- **Scoring:** points per night based on how much survived, multiplied by mutator bonuses.

The meta is entirely **mastery-based**: replay the same content with self-imposed constraints for a higher number. That works for a premium Steam game bought by strategy fans. **It will not carry a Roblox game on its own** — see Part 2, §16.

---

## 12. Presentation

**Visual:** cel-shaded low-poly, very restricted palette per map, outlines on everything, silhouette-first readability. Colour palette and terrain change entirely per map (pastel green fields → orange desert → icy tundra → spindly black forests), which is what keeps a minimalist style from getting stale over 10 maps.

**Camera:** fixed-perspective, follows the King automatically. **No zoom control.** Roughly an angled top-down/isometric view.

**Building feel:** the "plop" is deliberately over-juiced for how simple it is technically — mesh scale-punch, a particle burst, and a satisfying sound. The stated goal was making a single button press feel powerful. This is a very cheap, very high-value polish target.

**Audio:** composed by the developers. The signature move is the transition from peaceful daytime melodies into driving rhythmic battle music at nightfall. The music *is* the phase-change signal.

**UI:** minimal, tooltip-driven, deliberately sparse so that it never competes with the battlefield.

---

## 13. What actually makes it work — the eight load-bearing pillars

If you keep only eight things, keep these:

1. **Two phases with a clean emotional contrast** — calm planning, then loud combat. Music, lighting, and colour all flip.
2. **Predefined build slots.** The single highest-leverage decision in the design.
3. **The day has no timer.** Zero stress on the planning phase.
4. **The night is previewed.** Informed decisions, not surprises.
5. **Free rebuild every morning, with a soft cost.** Forgiveness that still incentivises protection.
6. **One resource, one axis of tension** (economy vs military).
7. **Auto-attack floor + active-ability ceiling.** Accessible to a non-gamer, deep for a veteran.
8. **Counter-based enemy design with tags**, so build order and loadout are a real answer to a real question.

---

# PART 2 — BUILDING IT ON ROBLOX

## 14. Translation matrix: what carries over, what breaks

| Thronefall element | Roblox verdict | What to do |
|---|---|---|
| Day/night phase loop | ✅ Carries perfectly | Server-authoritative phase state machine |
| Predefined build slots | ✅ Carries perfectly — and it's *easier* on Roblox | Slots as tagged Parts in the map model |
| One-currency economy | ✅ Carries | Per-run gold, server-owned |
| Auto-attack combat | ✅ Carries | Server-side targeting loop, client-side VFX |
| Free morning rebuild | ✅ Carries, and is even more valuable | Prevents rage-quits in a multiplayer run |
| Fixed no-zoom camera | ⚠️ Risky | Roblox players expect camera control; allow limited zoom + rotate |
| `R`-to-command-units | ❌ **Breaks on mobile** | Redesign — see §15.3 |
| Keyboard 1/2/3/4 hotkeys | ❌ Breaks on mobile | Touch-friendly unit-group buttons |
| Single-player only | ❌ Wrong for Roblox | 1–4 player co-op, see §15 |
| Mastery-only meta (mutators, quests) | ⚠️ Insufficient alone | Keep it, but add a persistent meta — see §16 |
| 10–20 min sessions | ⚠️ Slightly long for a first session | Make map 1 a 5–6 minute run |
| 100+ simultaneous enemies | ⚠️ Will kill a naive implementation | See §17.2 — this is the hard technical problem |
| Premium purchase model | ❌ N/A | Free-to-play + passes/products, see §19 |

**The headline:** the *strategy* transfers almost unchanged. The *control scheme* and the *meta progression* must be rebuilt from scratch for Roblox's mobile-majority, free-to-play, session-based reality.

---

## 15. The multiplayer redesign

Thronefall is single-player. On Roblox, a single-player experience wastes the platform's biggest advantage and hurts retention badly. Design for **1–4 player co-op** from the start.

### 15.1 Shared kingdom, shared gold
- One kingdom, one Castle Center, one gold pool. All players are Kings (or King/Queen/Champion variants).
- Any player can spend from the shared pool at any build slot. This creates natural social friction — "who's spending on what" — which is *good*: it generates conversation, which generates session length.
- Optional: a lightweight "proposed build" ping so players can flag a slot they want funded.

### 15.2 Roles instead of one king
Give each player a distinct **Champion class** with a different weapon and a different passive. This does three things at once: solves the "we're all identical" problem, creates a reason to replay, and creates a monetizable cosmetic/character axis.

Starter set of four, mapped from Thronefall's weapon archetypes:
| Champion | Weapon feel | Passive | Role |
|---|---|---|---|
| Warden | Heavy sword, splash, 3x vs boss | +15% wall/tower HP nearby | Tank / anchor |
| Ranger | Bow, 2x vs flying | +20% tower range nearby | Anti-air / kiting |
| Marshal | Spear, 2x vs fast, applies slow | Nearby allied units +25% damage | Commander |
| Alchemist | Thrown vials, AoE slow + heal | Allied units regen near them | Support |

Each has an auto-attack (the floor) and one manual ability on cooldown (the ceiling). Exactly Thronefall's structure.

### 15.3 Fixing unit commanding for mobile

This is the most important redesign in the whole project. Thronefall's `R`-to-gather system is its most criticised mechanic on PC and would be unusable on a phone.

**Replace it with rally points:**
- Each unit-producing building (Barracks / Archery Range) has a **rally flag** the player drags to a position on the map during the day.
- Units walk to their rally flag and hold there, engaging anything in range.
- One HUD button: **"Rally to me"** — all units of the player's chosen group converge on the player, then return to their flags when released.
- Group filter as three touch-friendly tabs: **All / Melee / Ranged**.
- On PC, keep `R` and the number keys as an accelerated equivalent.

This keeps the tactical decision (where do my troops stand?) but moves it into the *day phase*, where there's no time pressure — which is also more consistent with the game's own anti-stress philosophy.

### 15.4 Presence and pacing
- If a player leaves mid-run, their champion despawns but the run continues; the kingdom does not collapse.
- Late joiners drop into the current run at the next morning, with gold parity.
- Scale wave size by player count: roughly `waveBudget * (0.6 + 0.4 * playerCount)` so 4 players face a meaningfully bigger night than 1, but a solo run stays viable.

---

## 16. The retention redesign (this is what decides whether the game grows)

Thronefall's meta — replay for a higher score with harder mutators — works for people who paid $13 for a strategy game. On Roblox, the discovery algorithm feeds games that retain, and mastery-only progression retains a narrow audience. You need three nested loops.

**Moment loop (seconds):** swing → enemy pops → coin flies to counter. The building "plop" must be juiced to Thronefall's standard: scale-punch, particles, distinct sound. This is cheap and it is *not optional*.

**Session loop (minutes):** the day/night cycle already is this — gold in, defense up, survive a visibly bigger wave. Aim for 3–6 "I got stronger" beats per run. This part is already solved by the source design.

**Meta loop (days) — this is what you must add:**
| System | Why |
|---|---|
| **Crown currency** earned per run (scaled by nights survived, buildings saved, mutators) | Persistent progress even on a loss — critical, since a lost run currently gives nothing |
| **Champion unlock tree** — new champions and weapon variants | The single strongest long-tail hook; visible, flexable |
| **Permanent perk unlocks** — Thronefall's 55 perks, drip-fed | Already designed for you; just gate them on Crowns instead of XP |
| **Kingdom Codex** — collection log of every enemy, building and champion seen | Collection pressure is the strongest long-tail retention force on Roblox |
| **Daily quests** (3, rotating: "survive 8 nights", "kill 200 monsters", "finish a run without losing a building") | Reliable D1→D7 lift; also teaches underused mechanics |
| **Weekly leaderboard** — highest score on a rotating featured map + mutator set | Newcomers can rank somewhere; resets keep it live |
| **Login streak** | Cheap, reliable |

**Critical FTUE rule:** a new player must be riding, building, and getting a reward within 30 seconds. That means the tutorial map (your Neuland) should be:
- 5–6 nights, not 8
- 3 enemy types
- 2 build slot types (house + tower) for night 1
- Zero text walls — a glowing arrow to the first build slot, a highlighted button, done

Ending a session on an almost-affordable unlock ("Crowns 820/1000 — Ranger") is the strongest come-back-tomorrow hook that exists. Design the Crown payout curve so that happens.

---

## 17. Technical architecture

Follow the standard skeleton: exactly two entry-point scripts (one server `Script`, one client `LocalScript`), everything else `ModuleScript`, `--!strict` on every module, all tunable numbers in `Shared/Config.luau`.

```
ReplicatedStorage/Shared/
  Config.luau        -- ALL balance: costs, HP, damage, wave tables, map defs
  Types.luau         -- BuildSlot, EnemyDef, RunState, PlayerProfile
  Net.luau           -- remote wrapper
  Trove.luau, Signal.luau, Guard.luau
ServerScriptService/
  Server             -- Script, the only server entry point
  Services/
    RunService_Game.luau   -- phase state machine (Day → Night → Morning)
    BuildService.luau      -- slot ownership, cost validation, construction
    EconomyService.luau    -- gold, income, drops
    WaveService.luau       -- spawn tables, budget scaling by player count
    EnemyService.luau      -- the enemy simulation (see 17.2)
    CombatService.luau     -- damage resolution, all of it
    UnitService.luau       -- allied unit AI, rally points
    DataService.luau       -- session-locked profile: Crowns, unlocks, codex
ServerStorage/ServerAssets/Maps/   -- map models with tagged build slots
StarterPlayer/StarterPlayerScripts/
  Client             -- LocalScript, the only client entry point
  Controllers/
    UIController, BuildController, CameraController,
    InputController, VFXController, AudioController
```

### 17.1 The build-slot system (the core trick, and it's easy)

Author each map in Studio as a model. Every build slot is an anchored, invisible `Part` tagged with `CollectionService` and carrying attributes:

```lua
-- Attributes on each slot Part
SlotType   = "Tower"     -- Tower | Wall | House | Mill | Field | Mine | Barracks | ...
SlotId     = "twr_04"    -- stable id for save/replication
MaxLevel   = 3
```

Server on map load: `CollectionService:GetTagged("BuildSlot")` → build a `RunState.slots` table. That's the whole system. Costs, HP, and upgrade trees all live in `Config`, keyed by `SlotType` and level.

Because slots are authored in the map, **adding a new map is content work, not code work** — exactly the liveops property you want. This is why Thronefall's constraint is a gift on Roblox: a new map is a model plus one Config table entry.

Client shows a ghost preview + price when the player is in range of an unbuilt slot; server revalidates range, phase, gold, and slot state on the remote. Never trust the client's claimed slot or price.

### 17.2 The enemy simulation — the one genuinely hard problem

A late Thronefall wave is well over a hundred enemies. If you build those as `Model`s with `Humanoid`s driven by `PathfindingService`, the server will die. Specifically: Humanoids are expensive, and per-enemy `ComputeAsync` calls will destroy your frame budget.

**Do this instead:**

1. **No Humanoids.** Enemies are a single `MeshPart` (or a small welded model) with `Anchored = true`. You move them by writing `CFrame` yourself. This alone is the difference between 30 enemies and 300.

2. **Precomputed lanes, not pathfinding.** Each spawn point on the map has one or more authored waypoint paths toward the castle, laid out as tagged Parts in the map model. Enemies follow a lane with a small random lateral offset so they don't look like a conga line. Only recompute a target when the enemy switches to attacking a building.

3. **One flat update loop for all enemies**, not one script per enemy:

```lua
-- ServerScriptService/Services/EnemyService.luau (excerpt)
local function stepAll(dt: number)
    for i = #active, 1, -1 do
        local e = active[i]
        if e.hp <= 0 then
            release(e, i)          -- return to pool
        elseif e.target then
            attackTick(e, dt)
        else
            advanceAlongLane(e, dt)
        end
    end
end
RunService.Heartbeat:Connect(stepAll)
```

4. **Pool everything.** Enemy models, projectiles, coin drops, hit VFX. Nothing is created or destroyed in steady state, and nothing allocates a table per Heartbeat.

5. **Batch replication.** Don't fire a remote per enemy per frame — enemy transforms replicate naturally via `CFrame` on anchored parts. Fire remotes only for *events* (spawned, died, hit) and let the client do the juice.

6. **Spatial partitioning for targeting.** A uniform grid bucket keyed by rounded X/Z position, rebuilt each tick, so a tower asking "who's in range?" checks ~9 buckets instead of 200 enemies.

**Budget target:** design waves so peak concurrent enemies stays around 120–180 on a mid-range Android phone. That's plenty for the fantasy; test it early rather than discovering it at map 8.

### 17.3 Combat authority
- All damage is computed on the server. The client never reports a hit, a number, or a kill.
- Auto-attack is a server-side cooldown per champion: every tick, find nearest valid target in range, apply `Config` damage × the tag multiplier table, fire a "hit" event to clients for VFX.
- Active abilities: client sends "I pressed ability"; server checks cooldown, phase, and alive state, then resolves everything.
- Damage-type multipliers (Flying / Fast / Siege / Monster / Boss) live in one table in `Config`, and the whole counter-design of the game falls out of it for free.

### 17.4 Data
Two clearly separated tiers:
- **Run state** — gold, built slots, night number, wave progress. Lives in server memory only. Never saved. Wiped when the run ends.
- **Profile** — Crowns, unlocked champions, unlocked perks, codex entries, quest progress, streaks. Goes through **one** session-locked `UpdateAsync` pipeline with autosave, save-on-leave, and `BindToClose`. No stray `SetAsync` anywhere.

Never save run state. It's the source of most "my progress vanished" bugs in games like this, and it isn't worth it — a run is 10 minutes.

### 17.5 Camera
Thronefall's fixed no-zoom camera will frustrate Roblox players. Compromise:
- Scriptable camera in `CameraController`, angled top-down following the champion with smooth lerp.
- Allow **limited** zoom (e.g. 60–110 studs) and optional 90° rotation snaps.
- Auto-pull-back slightly at nightfall to widen the view — a free readability win and a nice phase-change cue.

---

## 18. Balance starting tables (converted to Roblox scale)

Thronefall's raw numbers assume its own unit scale. Suggested conversions to Roblox studs and a slightly larger HP scale (bigger numbers feel better on Roblox, and give room for multipliers):

| Thronefall | Roblox suggestion |
|---|---|
| King speed 14 / sprint 23 | WalkSpeed 18 / sprint 28 |
| Unit speed 5 | WalkSpeed 9 (keep the ~2x champion mobility ratio) |
| King 100 HP | 500 HP (×5 across the board) |
| Wall 240 HP | 1,200 HP |
| Tower 100 HP | 500 HP |
| Castle Center 100 HP | 2,000 HP (it's the lose condition; give it weight) |
| House 20 HP | 100 HP |
| Field 10 HP | 50 HP (keep it deliberately fragile) |
| Weapon DPS 1.15–6.88 | 6–35 DPS |
| Gold costs 1–25 | Keep 1:1 — small readable numbers are a feature |

**Keep gold small.** Resisting the Roblox instinct to make currency numbers huge is correct here: "3 gold" is instantly comprehensible and every purchase feels weighty. Save the big numbers for Crowns (the meta currency).

**Income pacing to preserve:** a house costs 2 and earns 1/night → pays for itself in 2 nights. That 2-night payback is the heartbeat of the whole economy. Whatever you scale, keep payback periods in the 2–4 night range for basic economy and 4–6 for the big investments (mills, mines).

---

## 19. Monetization (never sell power that breaks the run)

The run is a balanced puzzle. Selling raw combat power inside it destroys the design *and* the retention it produces. Sell access, speed, and expression instead.

**Game passes (permanent):**
| Pass | Effect |
|---|---|
| Royal Treasury | +25% Crowns earned (meta currency only — never in-run gold) |
| Champion Pack | Unlock 2 exclusive champions immediately |
| Extra Perk Slot | 6th perk slot (mirrors Thronefall's level-gated slots) |
| Private Kingdom | Private server for friend groups |

**Developer products (consumable):**
- Crown bundles
- Instant champion unlock
- Daily-quest reroll
- Cosmetic banner/castle-skin bundles

**Cosmetics** are the healthiest lane here and Thronefall hands you a perfect hook: the castle visually assembles as you build it. Sell **castle skins and banner sets** — a visible, shared, whole-server flex that costs the balance nothing.

**Do not sell:** in-run gold, damage multipliers, extra starting buildings, or anything that shortens a night. Those are exactly the things that would let a paying player trivialise the puzzle and then get bored.

---

## 20. Build roadmap

**Phase 0 — Hook.** One sentence a 12-year-old can repeat: *"Build your castle by day, fight the monsters yourself at night, with your friends."* Lock the core verb: **ride, build, fight.**

**Phase 1 — Vertical slice (graybox).** One map, 5 nights, 3 enemy types, 3 slot types (house, tower, wall), one champion, one currency. Ugly parts, no UI polish. **Do not proceed until a 5-minute run is genuinely fun with zero art.** This is where you find out whether the loop works.

**Phase 2 — Spine.** Config-driven balance tables, Net layer with full validation, session-locked DataService, the pooled enemy simulation at 150 concurrent enemies on a phone. Nothing ships before this exists.

**Phase 3 — Content depth.** Upgrade choice trees (the Lv2/Lv3 branching is what creates run identity — prioritise it), 4 champions, 12–15 enemy types with distinct silhouettes, 3 maps at different difficulties.

**Phase 4 — Retention layer.** Crowns, champion unlocks, perk unlocks, codex, daily quests, weekly leaderboard, login streak.

**Phase 5 — Mutators.** Cheapest content in the project — global multipliers over systems that already exist. Ship 8–10.

**Phase 6 — Juice + mobile pass.** Building plop, coin magnetism, hit-stop, screen shake, day/night music transition, number pop-ups. Then a hard performance pass on a mid-range Android device.

**Phase 7 — Soft launch.** Release quietly, instrument the FTUE funnel (Joined → FirstBuild → FirstNightSurvived → FirstUpgrade → RunComplete), fix the worst drop-off, iterate the icon for CTR, then scale.

**Phase 8 — Liveops.** New map every 2–3 weeks (remember: a map is a model + a Config entry), a new champion monthly, seasonal castle skins, codes with each update.

---

## 21. Legal — build inspired-by, not a clone

Game *mechanics* are not protected — day/night tower defense with a controllable hero is fair game, and dozens of games share that skeleton. What you must not take:

- ❌ The name "Thronefall", or anything confusingly close
- ❌ Any assets, models, textures, UI, icons, or audio from the game
- ❌ The German map names (Neuland, Nordfels, Durststein, Frostsee, Uferwind, Sturmklamm, Wildbach, Moorweg, Freifort, Totend)
- ❌ Marketing that presents your game as Thronefall or as official

✅ Fine: the day/night loop, build-slot constraint, one-currency economy, hero-with-army structure, counter-based enemy tags, and the general low-poly cel-shaded aesthetic (which Thronefall doesn't own — it's a widespread style).

Also note Roblox's own moderation is stricter than the law here: uploading recognisable assets or a near-identical name is a fast route to takedown regardless of legal nuance. Give it your own name, your own world, your own creature designs.

---

## 22. Pitfalls to avoid

1. **Building the meta before the moment loop is fun.** If riding around hitting things with auto-attack isn't satisfying in graybox, no amount of Crowns and codexes will save it.
2. **Naive enemy implementation.** Humanoids + PathfindingService at scale is the single most likely way this project dies technically. Solve it in Phase 2, not Phase 6.
3. **Porting the commanding controls literally.** Mobile is the majority of your players. Rally points, not hold-R.
4. **Enemy silhouettes that look alike.** The original's own admitted flaw. On a phone screen it's ten times worse. Make each enemy family read instantly by shape and colour, not by detail.
5. **Adding a day timer "for tension".** It removes the thing that makes the design pleasant.
6. **Making losses give nothing.** Thronefall gets away with it; a free-to-play Roblox game does not. Always pay Crowns on a loss, scaled to progress.
7. **Selling in-run power.** Breaks the puzzle and the retention it generates.
8. **Front-loading complexity.** Ten slot types on map one will bounce players in 40 seconds. Two.
9. **Skipping the juice pass.** The building plop and the coin-to-counter animation are load-bearing, not decoration.
10. **Copying the 8-night tutorial length.** Too long for a first Roblox session. Five to six minutes, then let them out with an almost-affordable unlock.

---

## 23. Sources

- Thronefall Wiki (game.wiki/thronefall) — buildings, units, enemies, weapons, upgrades, maps, perks, mutators, economy, controls, the King
- Game Developer interview with Jonas Tyroller & Paul Schnepf, "Mastering minimalism and layering complexity with strategy game Thronefall" (July 2023) — design philosophy, build-slot reasoning, art direction, combat rationale
- Checkpoint Gaming hands-on preview (Aug 2023) — spawn previews, economic/military split
- TheSixthAxis, GameLuster, New Game Network reviews (2023–2024) — art style, UI legibility, enemy readability criticism
- NamuWiki Thronefall entry — rebuild-on-morning rules, hero revive timing, run length
- Shapes encyclopedia entry — release history, sales, awards, mutator framing
