# KINGDOM NIGHTS — CHARACTER ROSTER & DESIGN BRIEF

**39 models total.** Blocky, primitive-built, cel-shaded, silhouette-first.

---

## PART 1 — THE ROSTER

### 1.1 Champions (4) — the player characters

Highest detail budget in the game. These are on screen for the entire nine-minute run and they're what players see when they pick a character in the lobby.

| # | Name | Role | Silhouette hook | Palette | Part budget |
|---|---|---|---|---|---|
| C1 | **Warden** | Tank, greatsword | Widest shoulders in the game; huge squared pauldrons; sword as tall as they are | Ivory + steel blue, gold trim | 24–30 |
| C2 | **Ranger** | Ranged, longbow | Narrowest champion; hooded pointed head; bow arc breaks the outline | Forest green + leather brown, silver | 20–26 |
| C3 | **Marshal** | Anti-fast, spear | Tallest champion; long vertical spear line; short cape | Crimson + brass, white plume | 22–28 |
| C4 | **Alchemist** | Support, vials | Round hunched back from a bottle-rack backpack; shortest champion | Violet + copper, glowing teal vials | 22–28 |

**The four must be distinguishable in a 40px lobby thumbnail.** Test: wide / narrow / tall / round. That's the whole silhouette system, and it's deliberately crude because crude is what reads on a phone.

---

### 1.2 Heroes (12) — the collection

These carry the game's retention. Rarity must be readable **from the model alone**, before any UI frame appears — a player should see a Legendary walk past and know.

| # | Name | Rarity | Role | Silhouette hook | Palette | Parts |
|---|---|---|---|---|---|---|
| H1 | **Stoneguard** | Common | Tank | Squat, thick, tower shield wider than the body | Grey stone + moss green | 12–16 |
| H2 | **Bowman Captain** | Common | Ranged | Feathered cap spike; bow held low | Olive + tan | 12–16 |
| H3 | **Hound Handler** | Common | Anti-fast | Human + small quadruped hound at the heel — two shapes, one unit | Rust brown + grey hound | 16–20 |
| H4 | **Torchbearer** | Rare | Anti-monster | Raised torch arm; flame is the highest point | Charcoal + orange flame glow | 14–18 |
| H5 | **Sky Lancer** | Rare | Anti-air | Lance angled 45° upward; winged helm | Sky blue + white, silver lance | 14–18 |
| H6 | **Siege Breaker** | Rare | Anti-siege | Enormous hammer head, small body — top-heavy | Iron grey + red leather | 14–18 |
| H7 | **Field Medic** | Rare | Support | Satchel bag, cross emblem, staff with a lantern | Cream + soft green | 14–18 |
| H8 | **Golem** | Epic | Tank/AoE | Massive, armless-looking blocks; floating gap between torso and limbs | Mossy granite + glowing amber cracks | 18–24 |
| H9 | **Frost Warden** | Epic | Control | Jagged ice shards radiating from the shoulders | Pale cyan + deep blue, white | 18–24 |
| H10 | **Firewing** | Epic | Flying DPS | Only flying hero — wings wider than body, hovers 6 studs up | Ember red + black, gold underglow | 18–24 |
| H11 | **Lizard Rider** | Legendary | Hybrid | Rider on a quadruped mount — tallest and longest hero footprint | Jade + gold + sand | 26–32 |
| H12 | **The Ashen Queen** | Legendary | Nuke | Floating, no visible legs; tall crown; trailing ash particles | Ash grey + violet + ember orange | 26–32 |

**Rarity visual language — apply consistently:**

| Rarity | Treatment |
|---|---|
| Common | Flat matte colours. No emissive. No accessories. |
| Rare | One metallic accent + one small emissive detail |
| Epic | Emissive cracks or glow seams, a floating element (shard, ember), a subtle particle |
| Legendary | Emissive + floating elements + a persistent particle trail + a unique base plate |

**Level 5 (max) treatment** for every hero: add a cape or banner, a crown/halo element, and a colour shift toward gold. This is a flex target — make it obvious from across the map.

---

### 1.3 Allied units (2) — the mass troops

Spawned in groups of 4–12 from Barracks and Archery Range. **Lowest part budget in the game** — twelve of these on screen at once is normal.

| # | Name | Silhouette hook | Palette | Parts |
|---|---|---|---|---|
| U1 | **Knight** | Simple boxy body, round shield, stubby sword | Player blue + steel | **6–8** |
| U2 | **Archer** | Thinner than Knight, bow arc, quiver spike on the back | Player blue + leather | **6–8** |

They only need to read as "mine, melee" and "mine, ranged." Resist detailing them.

---

### 1.4 Enemies (14) — the bestiary

**This is the most important section in the document.** The source game's own developers named enemy readability as their weakest point — enemies looked too similar to each other. On a phone screen during a chaotic night that flaw is ten times worse.

**Every one of these must be identifiable by black silhouette alone at 30 pixels.** Build the silhouette strip test (§2.4) and actually run it.

**Humans** — desaturated crimson and charcoal, angular, military

| # | Name | Silhouette hook | Parts |
|---|---|---|---|
| E1 | **Weakling** | Smallest thing in the game. Hunched, round head, no weapon, stubby | 5–6 |
| E2 | **Swordsman** | Standard proportions, square shield, flat-top helm | 7–9 |
| E3 | **Archer** | Thin and tall, bow arc breaking the outline at chest height | 7–9 |
| E4 | **Pikeman** | Extreme vertical line — pike is 2.5× body height | 7–9 |
| E5 | **Ogre** | Very wide, hunched, tiny head sunk between huge shoulders | 10–12 |
| E6 | **Dark Warrior** | Tall spiked crown, trailing cape, narrow waist | 10–12 |

**Monsters** — acid green and violet, organic, irregular

| # | Name | Silhouette hook | Parts |
|---|---|---|---|
| E7 | **Slime** | Rounded cube, no limbs, no head. Pure blob | **3–4** |
| E8 | **Racer** | Low quadruped, long body, head thrust forward | 8–10 |
| E9 | **Spiderling** | Eight thin legs in a wide low X. Body barely visible | 9–10 |
| E10 | **Wasp** | Flying. Narrow segmented body, fast small wings, hovers 8 studs up | 6–8 |
| E11 | **Bloodwing** | Flying. Big bat wings wider than anything else airborne, hovers 12 studs | 8–10 |
| E12 | **Exploder** | Bulging sphere body with a lit fuse spike on top. Round + one spike | 6–7 |

**Siege** — raw timber and iron, mechanical, horizontal

| # | Name | Silhouette hook | Parts |
|---|---|---|---|
| E13 | **Battering Ram** | Wide low horizontal box on wheels. The widest ground silhouette | 10–12 |
| E14 | **Catapult** | Tall asymmetric throwing arm. The only diagonal silhouette in the game | 12–14 |

**Boss**

| # | Name | Silhouette hook | Parts |
|---|---|---|---|
| B1 | **The Fen Wraith** | Huge, floating, no legs, tattered hanging cloth, enormous antler crown. 4× the height of a Swordsman | 30–40 |

**Elite variants are not new models.** Same mesh, tinted 25% toward white, with a small particle aura and a 1.15× scale. One flag on the spawn call.

---

### 1.5 Mounts (6) — cosmetic, zero stats

Welded under the champion. On screen continuously for the whole run — the best cosmetic axis in the game.

| # | Name | Source | Silhouette hook | Palette | Parts |
|---|---|---|---|---|---|
| M1 | **Bay Horse** | Default | Baseline quadruped, calm proportions | Warm brown + cream | 10–12 |
| M2 | **Warhorse** | Crowns | Armoured barding, thicker legs, plume on the head | Steel grey + blue caparison | 14–18 |
| M3 | **Dire Wolf** | Crowns | Lower, longer, pointed ears, bushy tail | Slate grey + white belly | 12–16 |
| M4 | **Sand Lizard** | Stable Pass | Splayed reptile legs, long low tail, spinal frill | Sand gold + turquoise frill | 14–18 |
| M5 | **Skeletal Steed** | Stable Pass | Visible rib gaps — negative space in the silhouette | Bone white + violet glow | 14–18 |
| M6 | **Sun Stag** | Event only | Tall branching antlers — highest point of any mount | White + gold, warm glow | 16–20 |

---

### 1.6 Build order

Don't make 39 models before testing one. This order gets you playable fastest:

| Batch | Models | Why first |
|---|---|---|
| **1** | Warden, Knight, Weakling, Swordsman | Phase 1 graybox needs exactly these four |
| **2** | Remaining 3 champions, Archer unit, 4 more enemies | Phase 3 co-op |
| **3** | Siege pair, flyers, Exploder, Fen Wraith | Phase 3 map variety |
| **4** | All 12 heroes | Phase 4 collection |
| **5** | 6 mounts | Phase 4 cosmetics |

---

## PART 2 — THE STYLE BIBLE

These rules apply to every model. Put them at the top of every design request.

### 2.1 Construction
- **Primitives only**: blocks, cylinders, spheres, wedges. No organic sculpting, no smooth curves, no bevels.
- **Visible seams are correct.** Parts read as separate blocks. Don't blend them.
- **Floating limbs are allowed and encouraged** — small gaps at shoulders and hips, Roblox-style. It reads as charming, not broken, and it simplifies rigging.
- **Symmetry by default**, broken deliberately for character (Catapult's arm, Torchbearer's raised torch).

### 2.2 Proportion
- Head is **large** — roughly 1/3 of total height for humanoids. Chunky and toy-like, not realistic.
- Limbs are **thick and short**. No thin spindly arms except where it's the silhouette hook (Spiderling, enemy Archer).
- Champions are the height reference: **5 studs**. Everything else scales relative to that.

| Scale reference | Height |
|---|---|
| Weakling | 3.5 |
| Slime | 3 |
| Standard enemy / allied unit | 5 |
| Champion | 5 |
| Ogre / Golem | 7 |
| Legendary hero | 6–7 |
| Fen Wraith | 18 |

### 2.3 Colour
- **Maximum 4 colours per model.** Three is better.
- Flat, unlit-looking colour. No gradients, no textures, no patterns.
- Emissive used **only** for rarity signalling and magic — never for decoration.
- Each faction owns a palette and never borrows from another:

| Faction | Palette |
|---|---|
| Player (champions, units, heroes) | Ivory, steel blue, gold |
| Human enemies | Desaturated crimson, charcoal, iron |
| Monsters | Acid green, violet, bone |
| Siege | Raw timber brown, dark iron |
| Boss | Teal-black, ash grey, ember |

A player must be able to tell friend from enemy by colour alone, peripherally, without looking directly at the unit.

### 2.4 The silhouette strip test — run this, don't skip it

Render every model in a category as **pure black on white, at 30 pixels tall, in a row.** Then look at it.

If you can't name each one, they're not done. This is the specific failure the source game shipped with, and it's the single highest-value quality gate in the whole art pipeline.

### 2.5 Face
Faces are **two dark rectangle eyes and nothing else** — or nothing at all. No mouths, no noses, no expressions. Cheap, timeless, and it keeps focus on the silhouette. Enemies get angled eye rectangles to read as hostile; allies get level ones.

---

## PART 3 — PROMPT FOR CLAUDE DESIGN

Use this to generate reference sheets. **Run it one batch at a time** — 4–6 characters per request. Asking for 39 at once produces mush.

---

> I'm designing characters for a blocky, low-poly Roblox game called Kingdom Nights: Castle Defense — a co-op medieval kingdom-defense game. I need **character reference sheets** I'll use to build these as primitive-part models in Roblox Studio.
>
> **Art direction — follow strictly:**
> - Built entirely from simple primitives: boxes, cylinders, spheres, wedges. Absolutely no organic sculpting, smooth curves, or bevels.
> - Chunky toy proportions. Large heads (about 1/3 of total height), thick short limbs.
> - Visible seams between parts. Small floating gaps at shoulders and hips are correct and desirable.
> - Flat unlit colour. **Maximum 4 colours per character.** No gradients, no textures, no patterns.
> - Faces are two dark rectangles for eyes and nothing else. No mouths or noses.
> - Cel-shaded look with a clean dark outline around every form.
> - Fun and characterful, but readable above all — these are seen small, on phones, during chaotic combat.
>
> **The single most important requirement: every character must be identifiable by its black silhouette alone at 30 pixels tall.** Push proportions to extremes to achieve this. If two characters could be confused as silhouettes, exaggerate one until they can't be.
>
> **For each character, produce:**
> 1. **Orthographic turnaround** — front, side, and back, aligned on a shared baseline
> 2. **Part-breakdown diagram** — an exploded view showing which primitive shapes compose it, with approximate proportions labelled
> 3. **Colour swatches** — every colour used, with hex values
> 4. **Silhouette test strip** — all characters in the batch as pure black shapes on white, in a row at small scale, so I can verify they're distinguishable
> 5. **Scale line-up** — all characters in the batch side by side at correct relative heights
>
> **Layout:** one clean sheet per character with the character name as a heading, then a shared silhouette strip and scale line-up at the end of the batch. Neutral light background, generous spacing, labels in a simple sans-serif.
>
> **This batch — [BATCH NAME]:**
>
> [PASTE THE 4–6 ROWS FROM THE ROSTER TABLE HERE: name, role, silhouette hook, palette, height in studs, part budget]
>
> Faction palette for this batch: **[PALETTE FROM §2.3]**
> Height reference: a standard champion is 5 studs tall.

---

**Fill-in example, ready to run — Batch 1:**

> **This batch — Phase 1 Core Four:**
>
> 1. **Warden** — player champion, tank with a greatsword. Silhouette hook: the widest shoulders in the game, huge squared pauldrons, sword as tall as he is. Ivory + steel blue + gold trim. 5 studs. 24–30 parts.
> 2. **Knight** — allied foot soldier, spawned in groups of 8. Silhouette hook: simple boxy body, round shield, stubby sword. Must be extremely simple — twelve on screen at once. Player blue + steel. 5 studs. 6–8 parts.
> 3. **Weakling** — the weakest enemy, first one players ever fight. Silhouette hook: the smallest thing in the game, hunched, round head, no weapon. Desaturated crimson + charcoal. 3.5 studs. 5–6 parts.
> 4. **Swordsman** — standard human enemy. Silhouette hook: normal proportions, square shield, flat-top helm. Must be clearly distinct from the Knight above despite similar equipment — solve this with colour AND with a boxier, more angular build. Desaturated crimson + charcoal + iron. 5 studs. 7–9 parts.
>
> Note: Knight and Swordsman are the highest-risk confusion pair in the game — one is the player's ally, the other is an enemy. Make them unmistakable at a glance.

---

## PART 4 — PROMPT FOR ROBLOX STUDIO (the actual 3D step)

Once you have a sheet, paste this into Claude Code with the Studio MCP connected. It builds the model from primitives, which is the right tool for this style — cheap, editable, and exactly matching the aesthetic.

---

> Using the Roblox Studio MCP connection, build the character model described in the attached reference sheet.
>
> **Use `generate_procedural_model`** — primitives only, no `generate_mesh`. This style is blocky by design and primitives give me controllable part counts and editable geometry.
>
> **Requirements:**
> - Target part count: **[N from the roster table]**. Treat this as a hard ceiling, not a suggestion — enemies run 120–180 concurrent and part count is a direct performance cost.
> - Build as a `Model` with a clearly named `PrimaryPart` at the base centre, named `HumanoidRootPart` for consistency with the codebase.
> - **No `Humanoid`** unless this is a champion. Enemies, units, heroes, and mounts are anchored primitive models moved by CFrame — see §11 of the build spec.
> - Every part: `Anchored = true`, `CanCollide = false`, `CanQuery = false`, `CanTouch = false`.
> - Use `Color` with the exact hex values from the sheet. Material `SmoothPlastic` throughout, except emissive details which get `Neon`.
> - Name parts semantically: `Head`, `Torso`, `ArmLeft`, `ShoulderPadRight`, `WeaponBlade`. I need to reference these from code.
> - Weld everything to the PrimaryPart with `WeldConstraint`.
> - Total height must be **[H] studs** — verify with `GetExtentsSize` and report the actual number.
>
> **After building:**
> 1. `screen_capture` from three angles so I can check it against the sheet
> 2. Report actual part count and actual height
> 3. Parent it to `ReplicatedStorage/Assets/[Category]/[Name]`
>
> **Then run the silhouette check:** place it beside the models already in `ReplicatedStorage/Assets`, capture them together from the standard gameplay camera angle, and tell me honestly whether it's distinguishable from the others at small scale. If it isn't, propose which proportion to exaggerate — and be blunt about it. A model that fails this test is worse than no model, because it makes the ones around it harder to read too.

---

## PART 5 — QUALITY GATES

Before any model is considered done:

- [ ] Passes the 30px black silhouette test against every model in its faction
- [ ] Part count within budget
- [ ] Four colours or fewer
- [ ] Correct faction palette, no borrowed colours
- [ ] Height correct relative to the 5-stud champion reference
- [ ] Reads correctly from the gameplay camera angle (angled top-down, 55°), not just from the front
- [ ] Friend-or-enemy is obvious peripherally, by colour alone
- [ ] For heroes: rarity tier is readable from the model without UI
