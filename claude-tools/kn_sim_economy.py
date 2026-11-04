#!/usr/bin/env python3
"""Kingdom Nights economy / progression / Endless simulation (pure Python, no game code).

Numbers: Config_v2.luau + HANDOFF §5 drift (map UnlockLevel/DifficultyMult/TargetSeconds, Endless as built).
Verified anchors from Studio evidence (HANDOFF §7 2b): Greenhollow solo Normal win = 428 Crowns, 160 XP, 30 shards.
    python3 claude-tools/kn_sim_economy.py > claude-out/SIM-2026-11-04-economy-endless.md
Assumptions are listed in the output. Change the constants at the top, not the formulas.
"""
import math

# ── Config (Normal tier, solo) ───────────────────────────────────────────────
P = dict(BaseCrowns=100, CrownsPerNight=25, WinBonus=200, CrownsPerBuilding=3, CrownsPerTenKills=2,
         XpPerNight=12, XpWinBonus=100, MaxLevel=40)
def xp_for_level(n): return math.floor(120 * n ** 1.35)      # XP to go from level n to n+1 (per-level, spec reading)
SH = dict(Base=8, PerNight=2, WinBonus=12)
# id: nights, DifficultyMult, UnlockLevel, TargetSeconds(run length), slots, est. enemies killed in a win
MAPS = {
    "greenhollow": dict(nights=5,  dm=1.0, unlock=1,  secs=300, slots=14, kills=90),
    "ashridge":    dict(nights=8,  dm=1.2, unlock=3,  secs=450, slots=44, kills=260),
    "frostmere":   dict(nights=8,  dm=1.4, unlock=6,  secs=500, slots=47, kills=380),
    "blackfen":    dict(nights=10, dm=1.6, unlock=10, secs=525, slots=70, kills=520),
}
WEAPONS = [("spear/2nd", 1000, 3), ("3rd", 1500, 4), ("4th", 2500, 8), ("5th", 3500, 12), ("6th", 5000, 18)]
CHAMPIONS = [("ranger", 4000), ("marshal", 6000), ("alchemist", 8000)]
MOUNTS = [("warhorse", 2500), ("dire_wolf", 4500)]
HERO_COST = {"Common": 20, "Rare": 45, "Epic": 90, "Legendary": 160}
HERO_COUNT = {"Common": 3, "Rare": 4, "Epic": 3, "Legendary": 2}
LEVEL_MULT = {2: 1.5, 3: 2.5, 4: 4.0, 5: 7.0}
PRODUCTS = [("crowns_pouch", 25, 1000), ("crowns_chest", 99, 4500), ("crowns_vault", 399, 20000),
            ("crowns_hoard", 899, 50000), ("crowns_treasury", 1999, 125000)]
SESSION_RUNS = 3            # assumption: one session = 3 runs
WIN_RATE = 0.6              # assumption: average player wins 60% of attempts on the hardest map they have unlocked
DAY_SWITCH = 60             # assumption: day phase ~60 s per night on top of TargetSeconds? No: TargetSeconds is the whole run.

# ── Per-run rewards ──────────────────────────────────────────────────────────
def run_rewards(map_id, won, crown_mult=1.0, xp_mult=1.0, shard_mult=1.0, nights_survived=None):
    m = MAPS[map_id]
    n = m["nights"] if won else (nights_survived or math.ceil(m["nights"] * 0.6))
    kills = m["kills"] if won else m["kills"] * 0.5
    buildings = m["slots"] * (0.8 if won else 0.5)
    crowns = P["BaseCrowns"] + P["CrownsPerNight"] * n + (P["WinBonus"] if won else 0) \
             + P["CrownsPerBuilding"] * buildings + P["CrownsPerTenKills"] * kills / 10
    crowns = crowns * m["dm"] * crown_mult
    xp = (P["XpPerNight"] * n + (P["XpWinBonus"] if won else 0)) * xp_mult
    shards = (SH["Base"] + SH["PerNight"] * n + (SH["WinBonus"] if won else 0)) * shard_mult
    secs = m["secs"] if won else m["secs"] * 0.6
    return crowns, xp, shards, secs

print("# Kingdom Nights — economy, progression and Endless simulation (2026-11-04)\n")
print("Pure-data model from `Config_v2.luau` + HANDOFF §5 drift. Anchor check: Greenhollow solo Normal win →")
c, x, s, _ = run_rewards("greenhollow", True)
print(f"model {c:.0f} Crowns / {x:.0f} XP / {s:.0f} shards vs Studio evidence 428 / 160 / 30 "
      f"(crowns differ only by the building/kill estimate).\n")
print("**Assumptions:** one session = 3 runs; players play the hardest map they have unlocked; 60% win rate there; "
      "`XpForLevel(n)` is the XP needed to go from level n to n+1; lost runs end at 60% of the nights; "
      "building count in a win = 80% of slots; kill counts per map are estimates (90/260/380/520).\n")

# ── Table 1: rewards per run ────────────────────────────────────────────────
print("## 1. Rewards per run (Normal, solo, no passes)\n")
print("| Map | Win: Crowns / XP / shards / min | Loss: Crowns / XP / shards / min | Crowns per minute (win) |")
print("|---|---|---|---|")
for mid in MAPS:
    cw, xw, sw, tw = run_rewards(mid, True)
    cl, xl, sl, tl = run_rewards(mid, False)
    print(f"| {mid} | {cw:.0f} / {xw:.0f} / {sw:.0f} / {tw/60:.1f} | {cl:.0f} / {xl:.0f} / {sl:.0f} / {tl/60:.1f} | {cw/(tw/60):.0f} |")

# ── Simulation: a player over 30 days ───────────────────────────────────────
def simulate(days=30, crown_mult=1.0, xp_mult=1.0, shard_mult=1.0, label=""):
    level, xp, crowns, shards, minutes, runs = 1, 0.0, 0.0, 0.0, 0.0, 0
    events = []
    bought = set()
    log = []
    for day in range(1, days + 1):
        for _ in range(SESSION_RUNS):
            # hardest unlocked map
            mid = max((m for m in MAPS if MAPS[m]["unlock"] <= level), key=lambda m: MAPS[m]["unlock"])
            won = (runs % 5) < round(WIN_RATE * 5)
            if level < 3 and mid == "greenhollow": won = runs > 0   # tutorial: first run may be lost, then wins
            c, x, s, t = run_rewards(mid, won, crown_mult, xp_mult, shard_mult)
            crowns += c; xp += x; shards += s; minutes += t / 60; runs += 1
            while level < P["MaxLevel"] and xp >= xp_for_level(level):
                xp -= xp_for_level(level); level += 1
                for m2, md in MAPS.items():
                    if md["unlock"] == level: events.append((day, runs, round(minutes), f"unlock map {m2} (L{level})"))
                if level == 5: events.append((day, runs, round(minutes), "unlock Endless/lastwatch (L5)"))
            # spend: cheapest useful thing first (weapon when level allows, then champion, then mount)
            for name, cost, lvl in WEAPONS:
                if name not in bought and level >= lvl and crowns >= cost:
                    crowns -= cost; bought.add(name); events.append((day, runs, round(minutes), f"buy weapon {name} ({cost})"))
            for name, cost in CHAMPIONS:
                if name not in bought and crowns >= cost:
                    crowns -= cost; bought.add(name); events.append((day, runs, round(minutes), f"buy champion {name} ({cost})"))
            for name, cost in MOUNTS:
                if name not in bought and crowns >= cost:
                    crowns -= cost; bought.add(name); events.append((day, runs, round(minutes), f"buy mount {name} ({cost})"))
        log.append((day, level, round(crowns), round(shards), round(minutes)))
    return events, log, dict(level=level, crowns=crowns, shards=shards, minutes=minutes, runs=runs)

print("\n## 2. Free player, one session a day (3 runs), 30 days\n")
events, log, end = simulate()
print("| Day | Runs | Minutes played | Event |\n|---|---|---|---|")
for d, r, mnt, e in events: print(f"| {d} | {r} | {mnt} | {e} |")
print(f"\nEnd of day 30: level {end['level']}, {end['crowns']:.0f} Crowns banked, {end['shards']:.0f} shards earned, "
      f"{end['runs']} runs, {end['minutes']/60:.1f} hours.\n")
print("| Day | Level | Crowns banked | Shards total | Minutes |\n|---|---|---|---|---|")
for d, lv, cr, sh, mn in log:
    if d in (1, 2, 3, 5, 7, 10, 14, 21, 30): print(f"| {d} | {lv} | {cr} | {sh} | {mn} |")

print("\n## 3. Same player with Royal Treasury (×1.5 Crowns) + 2x XP\n")
events2, log2, end2 = simulate(crown_mult=1.5, xp_mult=2.0)
print("| Day | Runs | Minutes played | Event |\n|---|---|---|---|")
for d, r, mnt, e in events2: print(f"| {d} | {r} | {mnt} | {e} |")
print(f"\nEnd of day 30: level {end2['level']}, {end2['crowns']:.0f} Crowns banked, {end2['runs']} runs.\n")

# ── XP curve ─────────────────────────────────────────────────────────────────
print("## 4. XP curve (per-level reading)\n")
print("| Level | XP for next | Cumulative | Greenhollow wins to reach | Blackfen wins to reach |\n|---|---|---|---|---|")
cum = 0
gw = run_rewards("greenhollow", True)[1]; bw = run_rewards("blackfen", True)[1]
for n in (1, 2, 3, 4, 5, 6, 8, 10, 12, 15, 18, 20, 25, 30, 40):
    cum = sum(xp_for_level(k) for k in range(1, n))
    print(f"| {n} | {xp_for_level(n)} | {cum} | {cum/gw:.0f} | {cum/bw:.0f} |")

# ── Hero shards ──────────────────────────────────────────────────────────────
print("\n## 5. Hero collection in shards\n")
total_unlock = sum(HERO_COST[r] * HERO_COUNT[r] for r in HERO_COST)
total_l5 = sum(HERO_COST[r] * HERO_COUNT[r] * (1 + sum(LEVEL_MULT.values())) for r in HERO_COST)
per_win = {m: run_rewards(m, True)[2] for m in MAPS}
print(f"- Unlock all 12 heroes: **{total_unlock} shards**. Every hero to L5: **{total_l5:.0f} shards**.")
print(f"- Shards per win: " + ", ".join(f"{m} {v:.0f}" for m, v in per_win.items()) + ". Casual tier ×0.7, Heroic ×1.6, Hero Collector pass ×1.25, Blood Moon ×2.")
print(f"- Greenhollow-only player: {total_unlock/per_win['greenhollow']:.0f} wins to unlock everything; Blackfen player: {total_unlock/per_win['blackfen']:.0f} wins.")
print(f"- shards_small (149 R$) = 80 shards = {80/per_win['ashridge']:.1f} Ashridge wins; shards_large (499 R$) = 300 = {300/per_win['ashridge']:.1f} Ashridge wins.")
print("- Shards are not freely assignable (rarity roll + near-completion bias), so real unlock times are longer than this floor "
      "and the first Legendary is a long-tail event. That is intended; just make sure the index screen shows progress bars.\n")

# ── Robux vs time ────────────────────────────────────────────────────────────
print("## 6. What a Robux buys, in minutes of play\n")
cpm = {m: run_rewards(m, True)[0] / (run_rewards(m, True)[3] / 60) for m in MAPS}
print("| Product | R$ | Crowns | Crowns per R$ | Minutes of Ashridge wins it replaces | Minutes of Blackfen wins |\n|---|---|---|---|---|---|")
for name, r, cr in PRODUCTS:
    print(f"| {name} | {r} | {cr} | {cr/r:.0f} | {cr/cpm['ashridge']:.0f} | {cr/cpm['blackfen']:.0f} |")
print(f"\nEarn rates (Crowns/min, Normal, winning): " + ", ".join(f"{m} {v:.0f}" for m, v in cpm.items()) + ".")

# ── Endless Siege ────────────────────────────────────────────────────────────
print("\n## 7. Endless Siege — HP budget vs what a full Lastwatch build can kill\n")
BASE, GROWTH = 400, 1.11
# full build on Lastwatch (16 slots): 5 towers L3, castle L3, 12 knights, 12 archers; heroes uncapped
tower_dps = 26 / 0.8; castle_dps = 26 / 0.85
knight_dps = 13 / 1.0; archer_dps = 20 / 1.2
hero_dps_l5 = 40 / 1.4 * 2.0 * 3          # three tank-ish heroes at L5 (StatMult 2.0); conservative
champ_dps = 22 / 1.0 * 1.75               # greatsword with one royal training
defense = dict(towers=5 * tower_dps, castle=castle_dps, knights=12 * knight_dps, archers=12 * archer_dps,
               heroes=hero_dps_l5, champion=champ_dps)
total_dps = sum(defense.values())
print("Defense DPS model (Normal, full build, no damage-profile multipliers, 100% uptime — an upper bound):")
print(", ".join(f"{k} {v:.0f}" for k, v in defense.items()) + f" → **{total_dps:.0f} DPS**. Tower-only (early run) ≈ {5*tower_dps + castle_dps:.0f} DPS.\n")
UPTIME = 0.35   # assumption: 4 lanes, random spawn per entry, walk time → a defender is shooting ~35% of the night
print(f"Effective DPS at {UPTIME:.0%} uptime: full build **{total_dps*UPTIME:.0f}**, tower-only **{(5*tower_dps+castle_dps)*UPTIME:.0f}**. "
      "A night is survivable while its kill time stays under the ~45 s engagement window (spawn streaming + a ~120-stud walk + wall time).\n")
print("| Night | Budget HP (×1.11^n) | = weaklings | = ogres | s to kill, full build (eff.) | s to kill, tower-only (eff.) | Gold if all killed (≈2 per 125 HP) |\n|---|---|---|---|---|---|---|")
for n in (1, 3, 5, 8, 10, 12, 15, 18, 20, 25, 30, 35, 40, 45, 50, 60):
    hp = BASE * GROWTH ** n
    gold = hp / 125 * 2
    print(f"| {n} | {hp:,.0f} | {hp/45:.0f} | {hp/1000:.1f} | {hp/(total_dps*UPTIME):.0f} | {hp/((5*tower_dps+castle_dps)*UPTIME):.0f} | {gold:.0f} |")
print("\nReading: kill time crosses the 45 s window at about **night 33** for a full build with uncapped heroes and about "
      "**night 20** for a tower-only build, and the ×1.11 curve doubles every 6.6 nights after that — nothing survives night 45+ "
      "without a damage multiplier, which is the intended 'chase your ceiling' shape (spec §35). With BudgetHpFactor 0.05 "
      "(spec text) night 1 would be 20 HP = half a weakling, so the as-built 1.0 is the right call; Omar's ruling to keep "
      "it stands. Milestone elite ogres every 5 nights add 4,000 HP each (4× ogre), which from night 10 on is a smaller share "
      "of the night than the base curve, so milestones read as events, not walls — good.\n")
print("Full-build gold cost on Lastwatch: 5 towers (3+5+9) 85 + castle 28 + 2 walls 14 each 28 + barracks 20 + archery 20 + "
      "6 houses 4 each 24 = **205 gold**. StartGold 8; income 6 L2 houses = 12/morning + drops (table above). The build "
      "completes around **night 12–15** on drops alone, which is before the curve bites (night 20+). OK.\n")

print("## 8. Findings\n")
print("1. **Levels 3→6 are the slow stretch.** Frostmere unlocks at level 6; in the model a free player reaches it on day "
      f"{next((d for d, r, m, e in events if 'frostmere' in e), '?')} with Ashridge wins. Blackfen (L10) lands on day "
      f"{next((d for d, r, m, e in events if 'blackfen' in e), '?')}. If D7 retention looks weak, lower Frostmere to L5 or raise XpWinBonus; do not touch Crowns.")
print("2. **Endless unlock at L5 arrives on day "
      f"{next((d for d, r, m, e in events if 'Endless' in e), '?')}**, between Ashridge and Frostmere: the right moment, it gives the stalled player a new mode.")
print("3. **The Crown shop is paced for weeks, not days**: in the model the second champion (4,000) is day "
      f"{next((d for d, r, m, e in events if 'ranger' in e), '?')}, the third (6,000) day "
      f"{next((d for d, r, m, e in events if 'marshal' in e), '?')}. Royal Treasury + 2x XP pulls those to day "
      f"{next((d for d, r, m, e in events2 if 'ranger' in e), '?')} and {next((d for d, r, m, e in events2 if 'marshal' in e), '?')}. "
      "That is a real, fair acceleration pass, not pay-to-win.")
print("4. **crowns_pouch (25 R$ = 1,000) is priced at roughly one Ashridge session**; crowns_treasury is 2 weeks of play per 1,999 R$. "
      "Per-Robux value rises 40 → 63 Crowns from pouch to treasury, a sane ladder. Keep it.")
print("5. **Starter Pack (4,000 Crowns + ranger + warhorse + 60 shards for 199 R$)** is worth ~12,000 Crowns of shop value: by far the best deal, as a first-purchase hook should be. Make sure it really shows only once after the first win (QA §4.3).")
print("6. **Shards are the long game:** 830 shards unlock the roster, ~14,000 to max it. At ~30–40 shards per win that is 25 wins to own everything and hundreds to max. Fine for a 'two heroes a month' live plan, as long as near-completion bias is visible in the UI.")
print(f"8. **The Crown sink runs dry around day 15.** After the third champion the only level-gated buys left are the 5th/6th weapons "
      f"(L12/L18) and the model banks {end['crowns']:,.0f} unspent Crowns by day 30. That is the first liveops lever: more Crown mounts "
      "(spec §37.3 collections), seasonal skins, or a Crown-priced Trials entry. Not a launch blocker, but plan the first Crown sink for week 2.")
print("7. **Endless BudgetHpFactor 1.0 confirmed sensible.** Expect leaderboard tops around night 30–35 at launch; if tops sit under 20, the lane is too short for tower time (check Lastwatch lanes: 6 nodes, ~110 studs); if over 50, lower Growth to 1.10 (doubles every 7.3 nights).")
