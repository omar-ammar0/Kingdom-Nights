#!/usr/bin/env python3
"""Generate Map_Lastwatch v1 (kn-asset/1, kind map) — the Endless Siege map.

Authored by Claude (cloud session 2026-11-04) because ChatGPT had not started L1.
Design: "the last watchtower" — a ruined hill fort at dusk. Castle at the origin, four
cardinal approaches in a pinwheel (each lane runs in offset from its side, then bends
toward the castle), a broken rampart ring at r=92 with gaps where the lanes pass, four
ruined corner towers, braziers, banners, rubble, a cliff rim at the map edge.
Everything inside +/-130 studs. Flat at Y=0.5 — Endless enemies ignore terrain.

    python3 -I claude-tools/kn_gen_lastwatch.py claude-out/maps/Map_Lastwatch.json
Deterministic (seeded), so re-running produces the identical file.
"""
import json, math, random, sys

OUT = sys.argv[1] if len(sys.argv) > 1 else "Map_Lastwatch.json"
rng = random.Random(1104)

GROUND = 300          # 300 x 300, edge at +/-150
BOUND = 150
RAMPART_R = 92
LANE_JITTER = 18
parts = []

def part(name, shape, size, pos, ori=(0, 0, 0), color="#FFFFFF", material="Slate",
         folder=None, transparency=None, tags=None, attributes=None):
    p = {"name": name, "shape": shape, "size": [round(s, 3) for s in size],
         "position": [round(c, 3) for c in pos], "orientation": [round(o, 3) for o in ori],
         "color": color, "material": material}
    if folder: p["folder"] = folder
    if transparency is not None: p["transparency"] = transparency
    if tags: p["tags"] = tags
    if attributes: p["attributes"] = attributes
    parts.append(p)
    return p

# ─────────────────────────── ground ───────────────────────────
part("Ground", "Block", (GROUND, 1, GROUND), (0, 0, 0), color="#4F4A44", material="Ground")

# ─────────────────────────── lanes ────────────────────────────
# Each lane: spawn → straight run → bend → straight toward castle. Pinwheel (rotational symmetry).
# Waypoints in world XZ. Last node ~24 studs from the castle centre.
def rot(x, z, quarter):          # rotate a point 90° * quarter about the origin (pinwheel)
    for _ in range(quarter % 4):
        x, z = -z, x
    return x, z

base_spawn = (-40, -126)
base_way = [(-40, -126), (-40, -66), (0, -24)]          # N approach: run south, bend to castle
lanes = []
for q in range(4):
    lanes.append([rot(x, z, q) for (x, z) in base_way])
# q=0 N, q=1 E (rot: (-40,-126)->(126,-40)), q=2 S, q=3 W

def seg_points(a, b, step):
    ax, az = a; bx, bz = b
    L = math.hypot(bx - ax, bz - az)
    n = max(1, round(L / step))
    return [(ax + (bx - ax) * i / n, az + (bz - az) * i / n) for i in range(1, n + 1)]

lane_segments = []   # for distance checks
for i, way in enumerate(lanes, start=1):
    sx, sz = way[0]
    part(f"Spawn_{i}", "Block", (2, 1, 2), (sx, 0.5, sz), color="#CAD7DB", material="Concrete",
         folder="Spawns", transparency=1, tags=["EnemySpawn"], attributes={"SpawnIndex": i})
    nodes = []
    for a, b in zip(way, way[1:]):
        lane_segments.append((a, b))
        nodes += seg_points(a, b, 21)
    for k, (x, z) in enumerate(nodes, start=1):
        part(f"Lane_{i}_{k:02d}", "Block", (1, 1, 1), (x, 0.5, z), color="#CAD7DB", material="Concrete",
             folder="Lanes", transparency=1, tags=["LaneNode"], attributes={"SpawnIndex": i, "Order": k})

def dist_to_segment(px, pz, a, b):
    ax, az = a; bx, bz = b
    dx, dz = bx - ax, bz - az
    L2 = dx * dx + dz * dz
    t = 0 if L2 == 0 else max(0, min(1, ((px - ax) * dx + (pz - az) * dz) / L2))
    return math.hypot(px - (ax + t * dx), pz - (az + t * dz))

def lane_dist(px, pz):
    return min(dist_to_segment(px, pz, a, b) for a, b in lane_segments)

# ─────────────────────────── slots ────────────────────────────
PAD = {"Castle": (18, 18, "#C9AC67", 3, 1), "House": (9, 9, "#B5A18C", 2, 0), "Tower": (10, 10, "#698596", 3, 0),
       "Wall": (14, 4, "#A5A194", 3, 0), "Barracks": (11, 11, "#7D8DAD", 3, 0), "ArcheryRange": (11, 11, "#6B9A9E", 3, 0)}
PREFIX = {"Castle": "cas", "House": "hou", "Tower": "twr", "Wall": "wal", "Barracks": "bar", "ArcheryRange": "arc"}
counters = {}
slot_rects = []   # (x, z, hx, hz) for decor avoidance

def slot(st, x, z, yrot=0):
    sx, sz, col, maxl, startl = PAD[st]
    counters[st] = counters.get(st, 0) + 1
    sid = f"{PREFIX[st]}_{counters[st]:02d}"
    part(sid, "Block", (sx, 0.4, sz), (x, 0.7, z), (0, yrot, 0), color=col, material="Slate",
         folder="Slots", transparency=0.25, tags=["BuildSlot"],
         attributes={"SlotId": sid, "SlotType": st, "MaxLevel": maxl, "StartLevel": startl})
    hx, hz = (sx / 2, sz / 2) if yrot % 180 == 0 else (sz / 2, sx / 2)
    slot_rects.append((x, z, hx, hz))

def on_pad(px, pz, hx, hz, margin=2.0):
    for (sx, sz, shx, shz) in slot_rects:
        if abs(px - sx) < hx + shx + margin and abs(pz - sz) < hz + shz + margin:
            return True
    return False

def clear(px, pz, hx=1.0, hz=1.0, lane_margin=LANE_JITTER + 3):
    """True if a raised decor piece may stand here: outside every horde corridor and off every pad."""
    return lane_dist(px, pz) > lane_margin + max(hx, hz) and not on_pad(px, pz, hx, hz)

slot("Castle", 0, 0)

# Walls: across the N and S lane runs, just inside the rampart (lane x=-40 runs along Z → wall long axis along X)
slot("Wall", -40, -86, 0)
slot("Wall", 40, 86, 0)

def snap(st, anchor, band, r_max=84):
    """Nearest grid point to `anchor` whose centre distance to the nearest lane lies in `band`,
    keeps clear of other pads, the rampart ring and the castle forecourt. Deterministic."""
    sx, sz = PAD[st][0], PAD[st][1]
    hx, hz = sx / 2, sz / 2
    best, best_d = None, 1e9
    ax, az = anchor
    for gx in range(-r_max, r_max + 1, 2):
        for gz in range(-r_max, r_max + 1, 2):
            d_anchor = math.hypot(gx - ax, gz - az)
            if d_anchor >= best_d: continue
            ld = lane_dist(gx, gz)
            if not (band[0] <= ld <= band[1]): continue
            if abs(math.hypot(gx, gz) - RAMPART_R) < 10: continue
            if math.hypot(gx, gz) > r_max: continue
            if on_pad(gx, gz, hx, hz, margin=6): continue
            best, best_d = (gx, gz), d_anchor
    if best is None:
        raise SystemExit(f"no valid spot for {st} near {anchor} in band {band}")
    slot(st, *best)
    return best

TOWER_BAND = (25.5, 29)      # contested: the horde passes 18-30 away, the tower must hold itself
THREAT_BAND = (25, 29)       # economy the player chooses to defend
SAFE_BAND = (32, 48)         # beyond ground aggro, inside tower cover (Tower L1 range 60)

# Towers (5): outside corner of each bend (sees the straight run and the diagonal), plus a hub tower
# between the N and E lane ends that covers both approaches to the keep.
for q in range(4):
    snap("Tower", rot(-5, -62, q), TOWER_BAND)
snap("Tower", (27, -27), TOWER_BAND)

# Houses: three on the inside of a bend (threat band), three safe in the pockets behind the towers
for q in range(3):
    snap("House", rot(-46, -40, q), THREAT_BAND)
for q in range(3):
    snap("House", rot(-74, -8, q), SAFE_BAND)

# Barracks + Archery: safe pockets, as close to the keep as the band allows
snap("Barracks", rot(-74, -8, 3), SAFE_BAND)
snap("ArcheryRange", (14, -62), SAFE_BAND)

# ─────────────────────────── decor: roads ─────────────────────
ROAD = "#6B6258"
for i, way in enumerate(lanes, start=1):
    for k, (a, b) in enumerate(zip(way, way[1:]), start=1):
        ax, az = a; bx, bz = b
        L = math.hypot(bx - ax, bz - az) + 12
        ang = math.degrees(math.atan2(bx - ax, bz - az))   # rotation about Y so the strip's Z axis follows the segment
        part(f"Road_{i}_{k}", "Block", (12, 0.04, L), ((ax + bx) / 2, 0.5, (az + bz) / 2), (0, ang, 0),
             color=ROAD, material="Cobblestone", folder="Decor")
    bx, bz = way[1]
    part(f"RoadJoin_{i}", "Cylinder", (0.04, 14, 14), (bx, 0.5, bz), (0, 0, 90), color=ROAD, material="Cobblestone", folder="Decor")
# castle forecourt + hill-fort plateau rings: flat overlays, layered 5 mm apart so nothing z-fights
# (edge top 0.505 < outer 0.51 < inner 0.515 < roads 0.52; the Ground top is 0.5)
part("Plateau_Edge", "Cylinder", (0.01, 80, 80), (0, 0.5, 0), (0, 0, 90), color="#3F3A36", material="Slate", folder="Decor")
part("Plateau_Outer", "Cylinder", (0.02, 76, 76), (0, 0.5, 0), (0, 0, 90), color="#5A544E", material="Cobblestone", folder="Decor")
part("Plateau_Inner", "Cylinder", (0.03, 44, 44), (0, 0.5, 0), (0, 0, 90), color="#635C55", material="Cobblestone", folder="Decor")

# ─────────────────────────── decor: rampart ring ──────────────
STONE = "#5B5753"; STONE_DK = "#49453F"
seg_len = 10.0
n_seg = int(round(2 * math.pi * RAMPART_R / (seg_len + 1.5)))
ramp_i = 0
for s in range(n_seg):
    ang = 2 * math.pi * s / n_seg
    x, z = RAMPART_R * math.cos(ang), RAMPART_R * math.sin(ang)
    if not clear(x, z, 5, 1.6):                               # leave gates where the lanes pass
        continue
    ramp_i += 1
    h = rng.choice([2.5, 3.5, 4.5, 5.5, 6.0, 3.0])              # ruined: uneven heights
    yrot = -math.degrees(ang)
    part(f"Rampart_{ramp_i:02d}", "Block", (seg_len, h, 3.2), (x, 0.5 + h / 2, z), (0, yrot, 0),
         color=STONE if rng.random() < 0.7 else STONE_DK, material="Slate", folder="Decor")
    if rng.random() < 0.35:                                       # crumbled crown
        part(f"RampartCrown_{ramp_i:02d}", "Wedge", (3.2, 1.6, 4.0), (x, 0.5 + h + 0.8, z), (0, yrot + 90, 0),
             color=STONE_DK, material="Slate", folder="Decor")

# gate pillars either side of each lane where it crosses the ring (+/-22 studs off the lane line)
for i, way in enumerate(lanes, start=1):
    (ax, az), (bx, bz) = way[0], way[1]
    dx, dz = bx - ax, bz - az
    L = math.hypot(dx, dz); dx, dz = dx / L, dz / L
    # crossing point of the straight run with r=92
    for t in range(0, 200):
        px, pz = ax + dx * t, az + dz * t
        if math.hypot(px, pz) <= RAMPART_R: break
    nx, nz = -dz, dx
    for side, sgn in (("L", -1), ("R", 1)):
        gx, gz = px + nx * 23 * sgn, pz + nz * 23 * sgn
        part(f"GatePillar_{i}{side}", "Block", (4, 9, 4), (gx, 5.0, gz), (0, 0, 0), color=STONE, material="Slate", folder="Decor")
        part(f"GateCap_{i}{side}", "Block", (5, 0.8, 5), (gx, 9.9, gz), (0, 0, 0), color=STONE_DK, material="Slate", folder="Decor")
        # brazier on the cap
        part(f"GateBrazier_{i}{side}", "Cylinder", (1.2, 2.4, 2.4), (gx, 10.9, gz), (0, 0, 90), color="#2E2A26", material="Metal", folder="Decor")
        part(f"GateFlame_{i}{side}", "Ball", (1.6, 1.6, 1.6), (gx, 12.1, gz), (0, 0, 0), color="#FF8A2A", material="Neon", folder="Decor")

# ─────────────────────────── decor: corner watchtowers ────────
for q, ang_deg in enumerate((45, 135, 225, 315), start=1):
    a = math.radians(ang_deg)
    x, z = 112 * math.cos(a), 112 * math.sin(a)
    part(f"WatchTower_{q}", "Cylinder", (15, 12, 12), (x, 8.0, z), (0, 0, 90), color=STONE, material="Slate", folder="Decor")
    part(f"WatchTowerBase_{q}", "Cylinder", (2, 15, 15), (x, 1.5, z), (0, 0, 90), color=STONE_DK, material="Rock", folder="Decor")
    part(f"WatchTowerBreak_{q}", "Wedge", (6, 4, 10), (x + 3, 17.5, z), (0, ang_deg, 0), color=STONE_DK, material="Slate", folder="Decor")
    part(f"WatchBrazier_{q}", "Cylinder", (1.4, 3, 3), (x - 2.5, 16.2, z - 2.5), (0, 0, 90), color="#2E2A26", material="Metal", folder="Decor")
    part(f"WatchFlame_{q}", "Ball", (2, 2, 2), (x - 2.5, 17.8, z - 2.5), (0, 0, 0), color="#FF8A2A", material="Neon", folder="Decor")
    # the "last watchtower" itself: the NE one is taller and whole — the map's landmark
part("LastWatch_Spire", "Cylinder", (19.4, 7, 7), (112 * math.cos(math.radians(45)), 10.2, 112 * math.sin(math.radians(45))), (0, 0, 90), color="#6A655F", material="Slate", folder="Decor")

# ─────────────────────────── decor: banners around the plateau ─
BANNER = "#7A1F2B"; POLE = "#3B2F26"
for k in range(8):
    a = math.radians(22.5 + 45 * k)
    x, z = 41 * math.cos(a), 41 * math.sin(a)
    if not clear(x, z, 0.5, 0.5): continue
    part(f"BannerPole_{k}", "Cylinder", (9, 0.5, 0.5), (x, 5.0, z), (0, 0, 90), color=POLE, material="Wood", folder="Decor")
    part(f"BannerCloth_{k}", "Block", (2.6, 4.2, 0.2), (x, 7.0, z), (0, -math.degrees(a), 0), color=BANNER, material="Fabric", folder="Decor")
# castle braziers at the forecourt corners
for k, (bx, bz) in enumerate([(14, 14), (-14, 14), (14, -14), (-14, -14)], start=1):
    if not clear(bx, bz, 1.2, 1.2, lane_margin=LANE_JITTER): continue
    part(f"CourtBrazier_{k}", "Cylinder", (1.6, 2.8, 2.8), (bx, 1.3, bz), (0, 0, 90), color="#2E2A26", material="Metal", folder="Decor")
    part(f"CourtFlame_{k}", "Ball", (1.8, 1.8, 1.8), (bx, 2.8, bz), (0, 0, 0), color="#FF8A2A", material="Neon", folder="Decor")

# ─────────────────────────── decor: rubble + scorched patches ─
RUB = ["#4F4C48", "#5B5753", "#3F3C3A"]
placed = 0; tries = 0
while placed < 110 and tries < 4000:
    tries += 1
    r = rng.uniform(26, 132); a = rng.uniform(0, 2 * math.pi)
    x, z = r * math.cos(a), r * math.sin(a)
    if abs(x) > 134 or abs(z) > 134: continue
    if abs(r - RAMPART_R) < 5: continue
    s = rng.uniform(1.6, 4.6)
    if not clear(x, z, s / 2, s / 2): continue
    placed += 1
    shape = rng.choice(["Block", "Block", "Wedge", "Ball"])
    size = (s, s * rng.uniform(0.5, 0.9), s * rng.uniform(0.7, 1.2)) if shape != "Ball" else (s, s, s)
    part(f"Rubble_{placed:03d}", shape, size, (x, 0.5 + size[1] / 2 - (0.2 if shape == "Ball" else 0), z),
         (0, rng.uniform(0, 360), 0), color=rng.choice(RUB), material=rng.choice(["Rock", "Slate"]), folder="Decor")
for k in range(26):
    r = rng.uniform(30, 128); a = rng.uniform(0, 2 * math.pi)
    x, z = r * math.cos(a), r * math.sin(a)
    if abs(x) > 134 or abs(z) > 134: continue
    w, l = rng.uniform(10, 24), rng.uniform(10, 24)
    part(f"Scorch_{k:02d}", "Block", (w, 0.016, l), (x, 0.5, z), (0, rng.uniform(0, 360), 0),
         color=rng.choice(["#3E3A33", "#56523F", "#45413B"]), material=rng.choice(["Grass", "Ground"]), folder="Decor")

# ─────────────────────────── decor: cliff rim + bounds ────────
CLIFF = ["#3C3A3F", "#45424A", "#34323A"]
k = 0
for side in range(4):
    for t in range(-7, 8):
        k += 1
        along = t * 19.5 + rng.uniform(-2, 2)
        inset = 142 + rng.uniform(-2, 2)
        h = rng.uniform(9, 18)
        if side == 0: x, z, yr = along, -inset, 0
        elif side == 1: x, z, yr = inset, along, 90
        elif side == 2: x, z, yr = along, inset, 0
        else: x, z, yr = -inset, along, 90
        if lane_dist(x, z) < 30: continue                      # the pass the horde comes through
        part(f"Cliff_{k:02d}", "Block", (20, h, 9), (x, 0.5 + h / 2, z), (0, yr + rng.uniform(-6, 6), 0),
             color=rng.choice(CLIFF), material="Rock", folder="Decor")
for name, size, pos in [("Bound_North", (GROUND, 20, 4), (0, 10.5, -BOUND + 2)), ("Bound_South", (GROUND, 20, 4), (0, 10.5, BOUND - 2)),
                        ("Bound_West", (4, 20, GROUND), (-BOUND + 2, 10.5, 0)), ("Bound_East", (4, 20, GROUND), (BOUND - 2, 10.5, 0))]:
    part(name, "Block", size, pos, color="#CAD7DB", material="Concrete", folder="Bounds", transparency=1)

# ─────────────────────────── write ────────────────────────────
doc = {
    "format": "kn-asset/1", "kind": "map", "name": "Map_Lastwatch", "version": 1, "author": "Claude",
    "notes": ("Endless Siege map (spec S35). 300x300 flat dusk hill fort, castle origin. Four cardinal lanes in a pinwheel: "
              "each runs in 40 studs off its axis, bends at r~77 and finishes 24 studs from the castle (every lane has one bend; "
              "all turns < 90 deg). Slots: 1 Castle, 6 House (3 in the 18-30 threat band at the bends, 3 safe), 5 Tower "
              "(one on the outside of each bend seeing the run + the diagonal, one NE seeing two gates), 2 Wall across the N and S "
              "runs at r=86, 1 Barracks, 1 ArcheryRange. Decor: broken rampart ring r=92 with gates where lanes pass, gate pillars "
              "with braziers, four ruined corner watchtowers (NE one whole = 'the last watch'), banners, rubble, scorched patches, "
              "cliff rim at +/-142. All raised decor is kept > 21 studs from every lane line and off every build pad. "
              "Generated by claude-tools/kn_gen_lastwatch.py (seeded)."),
    "parts": parts,
}
with open(OUT, "w", encoding="utf-8") as f:
    json.dump(doc, f, indent=1)
decor = sum(1 for p in parts if p.get("folder") == "Decor")
print(f"wrote {OUT}: {len(parts)} parts, {decor} decor, {len(slot_rects)} slots")
