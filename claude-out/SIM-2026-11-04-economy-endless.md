# Kingdom Nights — economy, progression and Endless simulation (2026-11-04)

Pure-data model from `Config_v2.luau` + HANDOFF §5 drift. Anchor check: Greenhollow solo Normal win →
model 477 Crowns / 160 XP / 30 shards vs Studio evidence 428 / 160 / 30 (crowns differ only by the building/kill estimate).

**Assumptions:** one session = 3 runs; players play the hardest map they have unlocked; 60% win rate there; `XpForLevel(n)` is the XP needed to go from level n to n+1; lost runs end at 60% of the nights; building count in a win = 80% of slots; kill counts per map are estimates (90/260/380/520).

## 1. Rewards per run (Normal, solo, no passes)

| Map | Win: Crowns / XP / shards / min | Loss: Crowns / XP / shards / min | Crowns per minute (win) |
|---|---|---|---|
| greenhollow | 477 / 160 / 30 / 5.0 | 205 / 36 / 14 / 3.0 | 95 |
| ashridge | 789 / 196 / 36 / 7.5 | 380 / 60 / 18 / 4.5 | 105 |
| frostmere | 964 / 196 / 36 / 8.3 | 467 / 60 / 18 / 5.0 | 116 |
| blackfen | 1315 / 220 / 40 / 8.8 | 651 / 72 / 20 / 5.2 | 150 |

## 2. Free player, one session a day (3 runs), 30 days

| Day | Runs | Minutes played | Event |
|---|---|---|---|
| 2 | 4 | 18 | unlock map ashridge (L3) |
| 2 | 4 | 18 | buy weapon spear/2nd (1000) |
| 3 | 7 | 38 | buy weapon 3rd (1500) |
| 4 | 10 | 54 | buy mount warhorse (2500) |
| 5 | 13 | 76 | unlock Endless/lastwatch (L5) |
| 6 | 16 | 93 | buy champion ranger (4000) |
| 7 | 21 | 124 | unlock map frostmere (L6) |
| 8 | 23 | 141 | buy mount dire_wolf (4500) |
| 11 | 31 | 195 | buy champion marshal (6000) |
| 14 | 42 | 273 | buy weapon 4th (2500) |
| 15 | 45 | 291 | buy champion alchemist (8000) |
| 24 | 72 | 483 | unlock map blackfen (L10) |

End of day 30: level 11, 39782 Crowns banked, 2626 shards earned, 90 runs, 10.2 hours.

| Day | Level | Crowns banked | Shards total | Minutes |
|---|---|---|---|---|
| 1 | 2 | 1158 | 74 | 13 |
| 2 | 3 | 1804 | 158 | 30 |
| 3 | 4 | 2263 | 248 | 50 |
| 5 | 5 | 3272 | 410 | 86 |
| 7 | 6 | 3189 | 590 | 124 |
| 10 | 6 | 5378 | 842 | 186 |
| 14 | 8 | 6460 | 1202 | 273 |
| 21 | 9 | 14732 | 1814 | 421 |
| 30 | 11 | 39782 | 2626 | 612 |

## 3. Same player with Royal Treasury (×1.5 Crowns) + 2x XP

| Day | Runs | Minutes played | Event |
|---|---|---|---|
| 1 | 3 | 13 | unlock map ashridge (L3) |
| 1 | 3 | 13 | buy weapon spear/2nd (1000) |
| 2 | 6 | 30 | buy weapon 3rd (1500) |
| 3 | 7 | 37 | unlock Endless/lastwatch (L5) |
| 3 | 7 | 37 | buy mount warhorse (2500) |
| 4 | 12 | 68 | unlock map frostmere (L6) |
| 4 | 12 | 68 | buy champion ranger (4000) |
| 6 | 16 | 95 | buy mount dire_wolf (4500) |
| 7 | 21 | 130 | buy champion marshal (6000) |
| 8 | 23 | 147 | buy weapon 4th (2500) |
| 10 | 30 | 192 | buy champion alchemist (8000) |
| 13 | 37 | 244 | unlock map blackfen (L10) |
| 19 | 56 | 382 | buy weapon 5th (3500) |

End of day 30: level 14, 87785 Crowns banked, 90 runs.

## 4. XP curve (per-level reading)

| Level | XP for next | Cumulative | Greenhollow wins to reach | Blackfen wins to reach |
|---|---|---|---|---|
| 1 | 120 | 0 | 0 | 0 |
| 2 | 305 | 120 | 1 | 1 |
| 3 | 528 | 425 | 3 | 2 |
| 4 | 779 | 953 | 6 | 4 |
| 5 | 1053 | 1732 | 11 | 8 |
| 6 | 1347 | 2785 | 17 | 13 |
| 8 | 1987 | 5791 | 36 | 26 |
| 10 | 2686 | 10108 | 63 | 46 |
| 12 | 3436 | 15849 | 99 | 72 |
| 15 | 4644 | 27344 | 171 | 124 |
| 18 | 5940 | 42553 | 266 | 193 |
| 20 | 6848 | 54882 | 343 | 249 |
| 25 | 9255 | 93861 | 587 | 427 |
| 30 | 11838 | 145235 | 908 | 660 |
| 40 | 17456 | 288433 | 1803 | 1311 |

## 5. Hero collection in shards

- Unlock all 12 heroes: **830 shards**. Every hero to L5: **13280 shards**.
- Shards per win: greenhollow 30, ashridge 36, frostmere 36, blackfen 40. Casual tier ×0.7, Heroic ×1.6, Hero Collector pass ×1.25, Blood Moon ×2.
- Greenhollow-only player: 28 wins to unlock everything; Blackfen player: 21 wins.
- shards_small (149 R$) = 80 shards = 2.2 Ashridge wins; shards_large (499 R$) = 300 = 8.3 Ashridge wins.
- Shards are not freely assignable (rarity roll + near-completion bias), so real unlock times are longer than this floor and the first Legendary is a long-tail event. That is intended; just make sure the index screen shows progress bars.

## 6. What a Robux buys, in minutes of play

| Product | R$ | Crowns | Crowns per R$ | Minutes of Ashridge wins it replaces | Minutes of Blackfen wins |
|---|---|---|---|---|---|
| crowns_pouch | 25 | 1000 | 40 | 10 | 7 |
| crowns_chest | 99 | 4500 | 45 | 43 | 30 |
| crowns_vault | 399 | 20000 | 50 | 190 | 133 |
| crowns_hoard | 899 | 50000 | 56 | 475 | 333 |
| crowns_treasury | 1999 | 125000 | 63 | 1188 | 832 |

Earn rates (Crowns/min, Normal, winning): greenhollow 95, ashridge 105, frostmere 116, blackfen 150.

## 7. Endless Siege — HP budget vs what a full Lastwatch build can kill

Defense DPS model (Normal, full build, no damage-profile multipliers, 100% uptime — an upper bound):
towers 162, castle 31, knights 156, archers 200, heroes 171, champion 38 → **759 DPS**. Tower-only (early run) ≈ 193 DPS.

Effective DPS at 35% uptime: full build **266**, tower-only **68**. A night is survivable while its kill time stays under the ~45 s engagement window (spawn streaming + a ~120-stud walk + wall time).

| Night | Budget HP (×1.11^n) | = weaklings | = ogres | s to kill, full build (eff.) | s to kill, tower-only (eff.) | Gold if all killed (≈2 per 125 HP) |
|---|---|---|---|---|---|---|
| 1 | 444 | 10 | 0.4 | 2 | 7 | 7 |
| 3 | 547 | 12 | 0.5 | 2 | 8 | 9 |
| 5 | 674 | 15 | 0.7 | 3 | 10 | 11 |
| 8 | 922 | 20 | 0.9 | 3 | 14 | 15 |
| 10 | 1,136 | 25 | 1.1 | 4 | 17 | 18 |
| 12 | 1,399 | 31 | 1.4 | 5 | 21 | 22 |
| 15 | 1,914 | 43 | 1.9 | 7 | 28 | 31 |
| 18 | 2,617 | 58 | 2.6 | 10 | 39 | 42 |
| 20 | 3,225 | 72 | 3.2 | 12 | 48 | 52 |
| 25 | 5,434 | 121 | 5.4 | 20 | 80 | 87 |
| 30 | 9,157 | 203 | 9.2 | 34 | 135 | 147 |
| 35 | 15,430 | 343 | 15.4 | 58 | 228 | 247 |
| 40 | 26,000 | 578 | 26.0 | 98 | 385 | 416 |
| 45 | 43,812 | 974 | 43.8 | 165 | 648 | 701 |
| 50 | 73,826 | 1641 | 73.8 | 278 | 1092 | 1181 |
| 60 | 209,623 | 4658 | 209.6 | 789 | 3102 | 3354 |

Reading: kill time crosses the 45 s window at about **night 33** for a full build with uncapped heroes and about **night 20** for a tower-only build, and the ×1.11 curve doubles every 6.6 nights after that — nothing survives night 45+ without a damage multiplier, which is the intended 'chase your ceiling' shape (spec §35). With BudgetHpFactor 0.05 (spec text) night 1 would be 20 HP = half a weakling, so the as-built 1.0 is the right call; Omar's ruling to keep it stands. Milestone elite ogres every 5 nights add 4,000 HP each (4× ogre), which from night 10 on is a smaller share of the night than the base curve, so milestones read as events, not walls — good.

Full-build gold cost on Lastwatch: 5 towers (3+5+9) 85 + castle 28 + 2 walls 14 each 28 + barracks 20 + archery 20 + 6 houses 4 each 24 = **205 gold**. StartGold 8; income 6 L2 houses = 12/morning + drops (table above). The build completes around **night 12–15** on drops alone, which is before the curve bites (night 20+). OK.

## 8. Findings

1. **Levels 3→6 are the slow stretch.** Frostmere unlocks at level 6; in the model a free player reaches it on day 7 with Ashridge wins. Blackfen (L10) lands on day 24. If D7 retention looks weak, lower Frostmere to L5 or raise XpWinBonus; do not touch Crowns.
2. **Endless unlock at L5 arrives on day 5**, between Ashridge and Frostmere: the right moment, it gives the stalled player a new mode.
3. **The Crown shop is paced for weeks, not days**: in the model the second champion (4,000) is day 6, the third (6,000) day 11. Royal Treasury + 2x XP pulls those to day 4 and 7. That is a real, fair acceleration pass, not pay-to-win.
4. **crowns_pouch (25 R$ = 1,000) is priced at roughly one Ashridge session**; crowns_treasury is 2 weeks of play per 1,999 R$. Per-Robux value rises 40 → 63 Crowns from pouch to treasury, a sane ladder. Keep it.
5. **Starter Pack (4,000 Crowns + ranger + warhorse + 60 shards for 199 R$)** is worth ~12,000 Crowns of shop value: by far the best deal, as a first-purchase hook should be. Make sure it really shows only once after the first win (QA §4.3).
6. **Shards are the long game:** 830 shards unlock the roster, ~14,000 to max it. At ~30–40 shards per win that is 25 wins to own everything and hundreds to max. Fine for a 'two heroes a month' live plan, as long as near-completion bias is visible in the UI.
8. **The Crown sink runs dry around day 15.** After the third champion the only level-gated buys left are the 5th/6th weapons (L12/L18) and the model banks 39,782 unspent Crowns by day 30. That is the first liveops lever: more Crown mounts (spec §37.3 collections), seasonal skins, or a Crown-priced Trials entry. Not a launch blocker, but plan the first Crown sink for week 2.
7. **Endless BudgetHpFactor 1.0 confirmed sensible.** Expect leaderboard tops around night 30–35 at launch; if tops sit under 20, the lane is too short for tower time (check Lastwatch lanes: 6 nodes, ~110 studs); if over 50, lower Growth to 1.10 (doubles every 7.3 nights).
