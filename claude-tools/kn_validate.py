"""kn-asset/1 validator. Usage: python3 -I validate.py <file.json> [--expect-slots JSON]"""
import json, math, re, sys

SHAPES = {"Block", "Ball", "Cylinder", "Wedge", "CornerWedge"}
MATERIALS = {"SmoothPlastic","Neon","Wood","WoodPlanks","Slate","Concrete","Grass","Brick",
             "Cobblestone","Metal","Sand","Ice","Fabric","Rock","Ground"}
# From the live Config.Buildings (level counts) - Harbour deliberately excluded.
SLOT_LEVELS = {"Castle":3,"House":2,"Mill":3,"Field":1,"GoldMine":1,"Tower":3,"Wall":3,
               "Barracks":3,"ArcheryRange":3,"HeroQuarters":2,"Blacksmith":3,"RoyalForge":3,"Temple":3}
# Max graybox footprint per type (Base + Per*(levels-1)), X/Z - the building must fit its pad.
GRAY_FOOT = {"Castle":(17,17),"House":(8,8),"Tower":(7,7),"Wall":(14,4),"Barracks":(11,11),
             "ArcheryRange":(11,11),"HeroQuarters":(10,10),"Mill":(9,9),"Field":(12,12),
             "GoldMine":(9,9),"Blacksmith":(10,10),"RoyalForge":(11,11),"Temple":(10,10)}
GROUND_Y = 0.5
LANE_JITTER = 18
DECOR_BUDGET = 2500
FOLDERS = {"Slots","Spawns","Lanes","Decor","Bounds"}

errors, warnings, info = [], [], []
def E(m): errors.append(m)
def W(m): warnings.append(m)
def I(m): info.append(m)

def num3(v): return isinstance(v, list) and len(v) == 3 and all(isinstance(x,(int,float)) and math.isfinite(x) for x in v)

def world_half(p):
    """World-space half extents (x, y, z) of a part's box after its rotation.
    Roblox CFrame.fromOrientation(rx, ry, rz) = Ry * Rx * Rz. A Cylinder stood on end
    (size [0.04, 36, 36], orientation [0, 0, 90]) is 0.02 tall, not 18 - found by ChatGPT 2026-10-13."""
    rx, ry, rz = (math.radians(a) for a in p["orientation"])
    cx, sx_, cy, sy, cz, sz_ = math.cos(rx), math.sin(rx), math.cos(ry), math.sin(ry), math.cos(rz), math.sin(rz)
    Rx = [[1,0,0],[0,cx,-sx_],[0,sx_,cx]]; Ry = [[cy,0,sy],[0,1,0],[-sy,0,cy]]; Rz = [[cz,-sz_,0],[sz_,cz,0],[0,0,1]]
    mul = lambda A,B: [[sum(A[i][k]*B[k][j] for k in range(3)) for j in range(3)] for i in range(3)]
    R = mul(mul(Ry, Rx), Rz)
    h = [s/2 for s in p["size"]]
    return tuple(sum(abs(R[i][k])*h[k] for k in range(3)) for i in range(3))

def wtop(p): return p["position"][1] + world_half(p)[1]
def wbottom(p): return p["position"][1] - world_half(p)[1]

def footprint_corners(p):
    """XZ corners of a part's box after Y rotation (maps only rotate about Y in practice)."""
    sx, _, sz = p["size"]; x, _, z = p["position"]; ry = math.radians(p["orientation"][1])
    c, s = math.cos(ry), math.sin(ry)
    pts = []
    for dx, dz in ((-sx/2,-sz/2),(sx/2,-sz/2),(sx/2,sz/2),(-sx/2,sz/2)):
        # Roblox Y rotation: x' = x cos + z sin ; z' = -x sin + z cos
        pts.append((x + dx*c + dz*s, z - dx*s + dz*c))
    return pts

def seg_dist(px, pz, ax, az, bx, bz):
    vx, vz = bx-ax, bz-az; L2 = vx*vx+vz*vz
    t = 0 if L2 == 0 else max(0, min(1, ((px-ax)*vx+(pz-az)*vz)/L2))
    cx, cz = ax+t*vx, az+t*vz
    return math.hypot(px-cx, pz-cz)

def poly_dist(px, pz, poly):
    return min(seg_dist(px, pz, *poly[i], *poly[i+1]) for i in range(len(poly)-1))

def main(path):
    try:
        d = json.load(open(path, encoding="utf-8"))
    except Exception as ex:
        E(f"not valid JSON: {ex}"); return
    if d.get("format") != "kn-asset/1": E(f"format must be 'kn-asset/1', got {d.get('format')!r}")
    kind = d.get("kind")
    if kind not in ("map","building","enemy","unit","hero","character","mount"): E(f"bad kind {kind!r}")
    if not isinstance(d.get("version"), int) or d["version"] < 1: E("version must be an integer >= 1")
    parts = d.get("parts")
    if not isinstance(parts, list) or not parts: E("parts must be a non-empty list"); return

    names = set()
    for i, p in enumerate(parts):
        tag = f"part[{i}] {p.get('name','?')!r}"
        for k in ("name","shape","size","position","orientation","color","material"):
            if k not in p: E(f"{tag}: missing '{k}'")
        if p.get("name") in names: E(f"{tag}: duplicate name")
        names.add(p.get("name"))
        if p.get("shape") not in SHAPES: E(f"{tag}: bad shape {p.get('shape')!r}")
        if p.get("material") not in MATERIALS: E(f"{tag}: bad material {p.get('material')!r}")
        for k in ("size","position","orientation"):
            if k in p and not num3(p[k]): E(f"{tag}: '{k}' must be [x,y,z] finite numbers")
        if num3(p.get("size",[0])) and min(p["size"]) <= 0: E(f"{tag}: size must be > 0 on every axis")
        if p.get("shape") == "Ball" and num3(p.get("size",[0])) and max(p["size"]) - min(p["size"]) > 1e-6:
            W(f"{tag}: Ball with unequal size {p['size']} - Roblox renders a sphere of the SMALLEST axis; for a flat disc use Cylinder [thick, d, d] orientation [0,0,90]")
        if not re.fullmatch(r"#[0-9A-Fa-f]{6}", str(p.get("color",""))): E(f"{tag}: color must be #RRGGBB")
        t = p.get("transparency", 0)
        if not isinstance(t,(int,float)) or not 0 <= t <= 1: E(f"{tag}: transparency must be 0..1")
        for forbidden in ("Anchored","CanCollide","CanQuery","CanTouch","anchored","canCollide"):
            if forbidden in p: W(f"{tag}: '{forbidden}' is ignored - the importer owns physics flags")
    if errors: return d
    if kind == "map": check_map(d, parts)
    if kind in ("enemy", "unit", "hero", "character"): check_character(d, parts)  # "character" = enemy (E3 batch, 2026-10-18)
    if kind == "building": check_building(d, parts)
    if kind == "mount": check_mount(d, parts)
    return d

# Part budgets from character-roster-and-design-brief.md (hard ceilings, root included).
CHAR_BUDGET = {"weakling": 6, "swordsman": 9, "knight": 8, "archer": 8,
               "slime": 4, "racer": 10, "archer_e": 9, "pikeman": 9, "wasp": 8, "ram": 12, "ogre": 12,
               "catapult": 14,  # roster E14: 12-14 parts (added 2026-10-15)
               # Batch E3 (2026-10-18, Omar-approved): brief ceilings, root included
               "bloodwing": 10, "darkwarrior": 12, "exploder": 7, "fenwraith": 40, "spiderling": 10}

# Heroes (Phase 4.4, COLLAB-LOG 2026-10-15 assignment). Hard ceiling = the top of each hero's range in
# character-roster-and-design-brief.md 1.2 (root included). Same 4-colour rule as every model (brief 2.3).
# Ids must match Config.Heroes exactly.
HERO_BUDGET = {"stoneguard": 16, "bowcaptain": 16, "houndhandler": 20,
               "torchbearer": 18, "skylancer": 18, "siegebreaker": 18, "fieldmedic": 18,
               "golem": 24, "frostwarden": 24, "firewing": 24,
               "lizardrider": 32, "ashenqueen": 32}

def check_character(d, parts):
    name = d.get("name")
    if not isinstance(name, str) or not re.fullmatch(r"[a-z][a-z0-9_]*", name):
        E(f"character name must be the lower-case id (e.g. 'weakling'), got {name!r}")
    roots = [p for p in parts if p.get("root") is True]
    if len(roots) != 1: E(f"need exactly one part with \"root\": true, found {len(roots)}"); return
    r = roots[0]
    if r["name"] != "HumanoidRootPart": E(f"root part must be named HumanoidRootPart, got {r['name']!r}")
    if r.get("transparency", 0) != 1: E("root part must have transparency 1")
    if r["shape"] != "Block": E("root part must be a Block")
    if any(abs(v) > 1e-6 for v in r["orientation"]): E("root part must not be rotated")
    if abs(r["position"][0]) > 1e-6 or abs(r["position"][2]) > 1e-6: E("root part must be centred at X=0, Z=0")
    rb = r["position"][1] - r["size"][1]/2
    if abs(rb) > 1e-6: E(f"root part bottom must sit at Y=0 (the model base), got {rb:.3f}")
    for p in parts:
        if p is not r and p.get("transparency", 0) >= 1: W(f"{p['name']}: invisible non-root part costs a part for nothing")
    vis = [p for p in parts if p is not r]
    # Lowest visible point (axis-aligned estimate; rotated parts use their half-diagonal).
    lo = min(wbottom(p) for p in vis); hi = max(wtop(p) for p in vis)
    if lo < -0.25: W(f"lowest visible point Y={lo:.2f} - feet should start at Y=0 or the model sinks into the ground")
    if lo > 0.5: W(f"lowest visible point Y={lo:.2f} - the model will float above the ground")
    cols = {p["color"].upper() for p in vis}
    if len(cols) > 4: E(f"{len(cols)} colours - the brief allows at most 4")
    if d.get("kind") == "hero":
        if name not in HERO_BUDGET: E(f"unknown hero id {name!r} - must be one of {sorted(HERO_BUDGET)}")
        budget = HERO_BUDGET.get(name)
        if not (4.5 <= hi <= 8.5): W(f"hero visible height {hi:.2f} - the brief's scale is 5 (human) to 7 (Golem/Legendary)")
    else:
        budget = CHAR_BUDGET.get(name)
    if budget is None: W(f"no part budget on record for '{name}' - check the character brief")
    elif len(parts) > budget: E(f"{len(parts)} parts exceeds the hard ceiling of {budget} for {name} (root included)")
    I(f"character {name}: {len(parts)} parts (budget {budget}), {len(cols)} colours, visible height ~{hi:.2f} (lowest {lo:.2f})")

# Mount contract (Phase 4.6, COLLAB-LOG 2026-11-02 assignment M1). Ids = Config.Mounts keys.
# The game never moves the rider: it scales the mount so the saddle top meets the avatar's hips,
# so every mount is authored at the SAME reference saddle height and the rider zone must be empty.
MOUNT_BUDGET = {"bay_horse": 24, "warhorse": 30, "dire_wolf": 26,
                "sand_lizard": 26, "skeletal_steed": 30, "sun_stag": 32}
MOUNT_SADDLE_Y = 2.0          # saddle top, studs above the pivot (the ground)
MOUNT_HALF_W, MOUNT_HALF_L, MOUNT_MAX_H = 1.5, 3.5, 4.5
RIDER_HALF_W = 1.1            # rider zone: |x| < 1.1, y > saddle + 0.05,
RIDER_FRONT, RIDER_BACK = 1.6, 0.9   # z from (saddle z - 1.6) to (saddle z + 0.9)

def check_mount(d, parts):
    name = d.get("name")
    if name not in MOUNT_BUDGET: E(f"unknown mount id {name!r} - must be one of {sorted(MOUNT_BUDGET)}"); return
    roots = [p for p in parts if p.get("root") is True]
    if len(roots) != 1: E(f"need exactly one part with \"root\": true, found {len(roots)}"); return
    r = roots[0]
    if r["name"] != "Root": E(f"mount root part must be named Root, got {r['name']!r}")
    if r.get("transparency", 0) != 1: E("Root must have transparency 1")
    if r["shape"] != "Block": E("Root must be a Block")
    if any(abs(v) > 1e-6 for v in r["orientation"]): E("Root must not be rotated")
    if abs(r["position"][0]) > 1e-6 or abs(r["position"][2]) > 1e-6: E("Root must be centred at X=0, Z=0")
    if abs(r["position"][1] - r["size"][1]/2) > 1e-6: E("Root bottom must sit at Y=0 (the ground)")
    if any(p.get("name") == "HumanoidRootPart" for p in parts): E("mounts must not contain a HumanoidRootPart")
    vis = [p for p in parts if p is not r]
    for p in vis:
        if p.get("transparency", 0) >= 1: W(f"{p['name']}: invisible non-root part costs a part for nothing")
    saddles = [p for p in vis if p["name"] == "Saddle"]
    if len(saddles) != 1: E(f"need exactly one part named Saddle, found {len(saddles)}"); return
    s = saddles[0]
    st = wtop(s)
    if abs(st - MOUNT_SADDLE_Y) > 0.05: E(f"Saddle top Y={st:.3f} - must be {MOUNT_SADDLE_Y} (+/-0.05); the game scales the mount from it")
    if world_half(s)[0] * 2 < 1.4: E(f"Saddle is {world_half(s)[0]*2:.2f} wide - at least 1.4 so the rider sits on it")
    sz = s["position"][2]
    heads = [p for p in vis if p["name"] == "Head"]
    if len(heads) != 1: E("need exactly one part named Head (it proves the facing)")
    elif heads[0]["position"][2] >= sz: E(f"Head z={heads[0]['position'][2]:.2f} is not in front of the saddle (z={sz:.2f}) - mounts face -Z")
    lo = min(wbottom(p) for p in vis); hi = max(wtop(p) for p in vis)
    if abs(lo) > 0.1: E(f"lowest visible point Y={lo:.2f} - feet must touch the ground at Y=0 (+/-0.1)")
    if hi > MOUNT_MAX_H: E(f"visible height {hi:.2f} exceeds {MOUNT_MAX_H}")
    minx = min(p["position"][0] - world_half(p)[0] for p in vis); maxx = max(p["position"][0] + world_half(p)[0] for p in vis)
    minz = min(p["position"][2] - world_half(p)[2] for p in vis); maxz = max(p["position"][2] + world_half(p)[2] for p in vis)
    if max(-minx, maxx) > MOUNT_HALF_W + 0.01 or max(-minz, maxz) > MOUNT_HALF_L + 0.01:
        E(f"footprint X[{minx:.2f},{maxx:.2f}] Z[{minz:.2f},{maxz:.2f}] exceeds {MOUNT_HALF_W*2} wide x {MOUNT_HALF_L*2} long centred on the pivot")
    # Rider zone: where the seated champion's body and folded legs go.
    zx0, zx1 = -RIDER_HALF_W, RIDER_HALF_W
    zy0 = MOUNT_SADDLE_Y + 0.05
    zz0, zz1 = sz - RIDER_FRONT, sz + RIDER_BACK
    for p in vis:
        h = world_half(p); x, y, z = p["position"]
        if (x + h[0] > zx0 and x - h[0] < zx1 and y + h[1] > zy0 and z + h[2] > zz0 and z - h[2] < zz1):
            E(f"{p['name']} intrudes on the rider zone (|x|<{RIDER_HALF_W}, y>{zy0:.2f}, z {zz0:.2f}..{zz1:.2f}) - the champion sits there")
    cols = {p["color"].upper() for p in vis}
    if len(cols) > 4: E(f"{len(cols)} colours - the brief allows at most 4")
    budget = MOUNT_BUDGET[name]
    if len(parts) > budget: E(f"{len(parts)} parts exceeds the hard ceiling of {budget} for {name} (root included)")
    I(f"mount {name}: {len(parts)} parts (budget {budget}), {len(cols)} colours, saddle top {st:.2f} at z={sz:.2f}, "
      f"bounds X[{minx:.2f},{maxx:.2f}] Y[{lo:.2f},{hi:.2f}] Z[{minz:.2f},{maxz:.2f}]")

# Building contract (COLLAB-LOG 2026-10-14 assignment). Footprint = smallest slot pad the type is
# placed on across the shipped maps; budgets are per level. Types not yet assigned fall back to
# their graybox footprint and a 35-part budget until their batch is specified.
BUILD_FOOT = {"House": (9, 9), "Tower": (10, 10), "Castle": (16, 16), "Wall": (14, 4),
              "Barracks": (11, 11), "ArcheryRange": (11, 11), "Mill": (16, 16),           # B2
              "GoldMine": (9, 9)}
BUILD_BUDGET = {"House": 25, "Tower": 35, "Castle": 60, "Wall": 25,
                "Barracks": 35, "ArcheryRange": 35, "Mill": 35, "GoldMine": 30}
BUILD_COLOURS = 6

def check_building(d, parts):
    name = d.get("name")
    m = re.fullmatch(r"([A-Za-z]+)/L([0-9]+)", str(name))
    if not m: E(f"building name must be '<Model>/L<n>' (e.g. 'House/L1'), got {name!r}"); return
    model, level = m.group(1), int(m.group(2))
    if model not in SLOT_LEVELS: E(f"unknown building model {model!r} - must be a SlotType spelling"); return
    if not 1 <= level <= SLOT_LEVELS[model]: E(f"{model} has levels 1..{SLOT_LEVELS[model]}, got L{level}")
    # No root: a PrimaryPart overrides WorldPivot and sinks the building (handoff gotcha 18).
    for p in parts:
        if p.get("root"): E(f"{p['name']}: buildings must have NO root part")
        if p.get("name") == "HumanoidRootPart": E("buildings must not contain a HumanoidRootPart")
        if p.get("transparency", 0) >= 1: W(f"{p['name']}: invisible part costs a part for nothing")
        for k in ("folder", "tags", "attributes"):
            if k in p: W(f"{p['name']}: '{k}' is a map-only field and is ignored for buildings")
    lo = min(wbottom(p) for p in parts); hi = max(wtop(p) for p in parts)
    if abs(lo) > 0.05: E(f"lowest point Y={lo:.3f} - the base must sit exactly at Y=0 (sinks or floats otherwise)")
    fx, fz = BUILD_FOOT.get(model, GRAY_FOOT.get(model, (99, 99)))
    minx = min(p["position"][0] - world_half(p)[0] for p in parts); maxx = max(p["position"][0] + world_half(p)[0] for p in parts)
    minz = min(p["position"][2] - world_half(p)[2] for p in parts); maxz = max(p["position"][2] + world_half(p)[2] for p in parts)
    tol = 0.01
    if max(-minx, maxx) > fx/2 + tol or max(-minz, maxz) > fz/2 + tol:
        E(f"footprint X[{minx:.2f},{maxx:.2f}] Z[{minz:.2f},{maxz:.2f}] exceeds {fx} x {fz} centred on the pivot")
    cols = {p["color"].upper() for p in parts}
    if len(cols) > BUILD_COLOURS: E(f"{len(cols)} colours - the building contract allows at most {BUILD_COLOURS}")
    budget = BUILD_BUDGET.get(model, 35)
    if len(parts) > budget: E(f"{len(parts)} parts exceeds the {budget}-part budget for {model}")
    I(f"building {model}/L{level}: {len(parts)} parts (budget {budget}), {len(cols)} colours, "
      f"bounds X[{minx:.2f},{maxx:.2f}] Y[{lo:.2f},{hi:.2f}] Z[{minz:.2f},{maxz:.2f}] (limit {fx} x {fz})")

def check_map(d, parts):
    if not re.fullmatch(r"Map_[A-Z][A-Za-z]+", d["name"]): E(f"map name must look like Map_Name, got {d['name']!r}")
    tops = [p for p in parts if p.get("folder") in (None, "")]
    for p in parts:
        f = p.get("folder")
        if f not in (None, "") and f not in FOLDERS: E(f"{p['name']}: bad folder {f!r}")
    ground = [p for p in tops if p["name"] == "Ground"]
    if len(ground) != 1: E("need exactly one top-level part named 'Ground'")
    else:
        g = ground[0]; top = g["position"][1] + g["size"][1]/2
        if abs(top - GROUND_Y) > 1e-6: E(f"Ground top is Y={top}, must be {GROUND_Y}")
        I(f"Ground {g['size'][0]}x{g['size'][2]}, top Y={top}")
    for p in tops:
        if p["name"] != "Ground": W(f"top-level part {p['name']!r} - only Ground belongs at top level")
    for p in parts:
        if p.get("folder") == "Bounds" and p.get("transparency", 0) < 1:
            W(f"{p['name']}: Bounds parts are invisible collision walls - set transparency 1 and put the visible edge in Decor")

    slots = [p for p in parts if "BuildSlot" in (p.get("tags") or [])]
    spawns = [p for p in parts if "EnemySpawn" in (p.get("tags") or [])]
    nodes = [p for p in parts if "LaneNode" in (p.get("tags") or [])]
    decor = [p for p in parts if p.get("folder") == "Decor"]
    for p in parts:
        tg = p.get("tags") or []
        if len(tg) > 1: E(f"{p['name']}: more than one tag {tg}")
        exp = {"BuildSlot":"Slots","EnemySpawn":"Spawns","LaneNode":"Lanes"}
        for t in tg:
            if t not in exp: E(f"{p['name']}: unknown tag {t!r}")
            elif p.get("folder") != exp[t]: W(f"{p['name']}: tag {t} but folder {p.get('folder')!r}")

    # --- slots ---
    ids, counts, castles = set(), {}, 0
    for s in slots:
        a = s.get("attributes") or {}
        sid, st, ml, sl = a.get("SlotId"), a.get("SlotType"), a.get("MaxLevel"), a.get("StartLevel")
        if not isinstance(sid, str) or not sid or len(sid) > 32: E(f"{s['name']}: SlotId must be a 1-32 char string")
        elif sid in ids: E(f"duplicate SlotId {sid}")
        ids.add(sid)
        if st == "Harbour": E(f"{sid}: Harbour has no gameplay - not allowed")
        elif st not in SLOT_LEVELS: E(f"{sid}: bad SlotType {st!r}")
        else:
            counts[st] = counts.get(st, 0) + 1
            if not isinstance(ml, int) or not 1 <= ml <= SLOT_LEVELS[st]: E(f"{sid}: MaxLevel {ml} not in 1..{SLOT_LEVELS[st]}")
            want = 1 if st == "Castle" else 0
            if sl != want: E(f"{sid}: StartLevel must be {want}, got {sl}")
            fx, fz = GRAY_FOOT[st]
            if s["size"][0] < fx or s["size"][2] < fz: W(f"{sid}: pad {s['size'][0]}x{s['size'][2]} smaller than the {st} footprint {fx}x{fz}")
        if st == "Castle": castles += 1
        if abs(s["position"][1] - 0.7) > 0.05: W(f"{sid}: pad Y={s['position'][1]}, expected 0.7")
        if abs(s["orientation"][0]) > 1e-6 or abs(s["orientation"][2]) > 1e-6: E(f"{sid}: only Y rotation is allowed on slots")
    if castles != 1: E(f"need exactly 1 Castle slot, found {castles}")
    I("slot counts: " + ", ".join(f"{k}={v}" for k, v in sorted(counts.items())))

    # --- spawns + lanes ---
    sidx = {}
    for sp in spawns:
        i = (sp.get("attributes") or {}).get("SpawnIndex")
        if not isinstance(i, int) or i < 1: E(f"{sp['name']}: SpawnIndex must be an integer >= 1"); continue
        if i in sidx: E(f"duplicate SpawnIndex {i}")
        sidx[i] = sp
    for k in range(1, len(sidx)+1):
        if k not in sidx: E(f"SpawnIndex not contiguous - missing {k}")
    lanes = {}
    for n in nodes:
        a = n.get("attributes") or {}
        i, o = a.get("SpawnIndex"), a.get("Order")
        if not isinstance(i,int) or not isinstance(o,int): E(f"{n['name']}: LaneNode needs integer SpawnIndex and Order"); continue
        if o in lanes.setdefault(i, {}): E(f"lane {i}: duplicate Order {o}")
        lanes[i][o] = n
    castle = next((s for s in slots if (s.get("attributes") or {}).get("SlotType") == "Castle"), None)
    polys = {}
    for i in sidx:
        if i not in lanes: E(f"spawn {i} has no LaneNodes"); continue
        orders = sorted(lanes[i])
        if orders != list(range(1, len(orders)+1)): E(f"lane {i}: Order not contiguous from 1: {orders}")
        pts = [(sidx[i]["position"][0], sidx[i]["position"][2])] + [(lanes[i][o]["position"][0], lanes[i][o]["position"][2]) for o in orders]
        gaps = [math.hypot(pts[k+1][0]-pts[k][0], pts[k+1][1]-pts[k][1]) for k in range(1, len(pts)-1)]
        bad = [round(g,1) for g in gaps if not 15 <= g <= 30]
        if bad: W(f"lane {i}: node gaps outside 15-30 studs: {bad}")
        # Turns sharper than 90 degrees make enemies skip a node (they rejoin the
        # lane at whichever node is nearer after a detour).
        for k in range(1, len(pts)-1):
            ax, az = pts[k][0]-pts[k-1][0], pts[k][1]-pts[k-1][1]
            bx, bz = pts[k+1][0]-pts[k][0], pts[k+1][1]-pts[k][1]
            if ax*bx + az*bz < 0: E(f"lane {i}: turn sharper than 90 degrees at point {k} - not supported")
        if castle:
            end = math.hypot(pts[-1][0]-castle["position"][0], pts[-1][1]-castle["position"][2])
            I(f"lane {i}: {len(orders)} nodes, gaps {min(gaps):.1f}-{max(gaps):.1f}, ends {end:.1f} studs from the castle")
            if end > 40: W(f"lane {i}: last node {end:.1f} studs from the castle - enemies cut straight across from there")
            pts.append((castle["position"][0], castle["position"][2]))
        polys[i] = pts
    for i in lanes:
        if i not in sidx: E(f"LaneNodes reference SpawnIndex {i} with no EnemySpawn")

    # --- corridor clearance: anything in an enemy's path that isn't the wall/castle ---
    for s in slots:
        st = s["attributes"]["SlotType"]
        if st in ("Wall","Castle"): continue
        for i, poly in polys.items():
            cd = min(poly_dist(cx, cz, poly) for cx, cz in footprint_corners(s) + [(s["position"][0], s["position"][2])])
            if cd < LANE_JITTER:
                W(f"{s['attributes']['SlotId']} ({st}) sits {cd:.1f} studs from lane {i} - inside the {LANE_JITTER}-stud horde spread; enemies will walk through it")
    # Walls: must actually be on a lane to do anything.
    for s in slots:
        if s["attributes"]["SlotType"] != "Wall": continue
        near = {i: poly_dist(s["position"][0], s["position"][2], poly) for i, poly in polys.items()}
        best = min(near, key=near.get)
        I(f"{s['attributes']['SlotId']}: {near[best]:.1f} studs from lane {best}")
        if near[best] > 26: W(f"{s['attributes']['SlotId']}: {near[best]:.1f} studs from the nearest lane - outside WallBlockRadius 26, it won't block anything")

    # --- threat band (brief 3.3): plot-centre distance to the nearest lane ---
    band = {"walls-only (<18)": [], "threat 18-30": [], "safe (>30)": []}
    for s in slots:
        st = s["attributes"]["SlotType"]
        if st in ("Wall","Castle"): continue
        cd = min(poly_dist(s["position"][0], s["position"][2], poly) for poly in polys.values()) if polys else 999
        key = "walls-only (<18)" if cd < 18 else "threat 18-30" if cd <= 30 else "safe (>30)"
        band[key].append(f"{s['attributes']['SlotId']}={cd:.1f}")
    for k, v in band.items(): I(f"threat band {k}: {len(v)} {v}")
    if polys and not band["threat 18-30"]: W("no economy/defence plot in the 18-30 stud threat band - ground enemies will never attack the economy")

    # --- raised decor footprint vs the horde corridor (roads/flat overlays exempt) ---
    def rect_dist(px, pz, p):
        sx, _, sz = p["size"]; x, _, z = p["position"]; ry = math.radians(p["orientation"][1])
        c, s_ = math.cos(ry), math.sin(ry); dx, dz = px - x, pz - z
        lx, lz = dx*c - dz*s_, dx*s_ + dz*c          # inverse of footprint_corners' rotation
        ox, oz = max(abs(lx) - sx/2, 0), max(abs(lz) - sz/2, 0)
        return math.hypot(ox, oz)
    def seg_rect(ax, az, bx, bz, p):
        L = math.hypot(bx-ax, bz-az); n = max(1, int(L / 0.5))
        return min(rect_dist(ax + (bx-ax)*k/n, az + (bz-az)*k/n, p) for k in range(n+1))
    intrude = []
    onlane = tuple(s["attributes"]["SlotId"] + "_" for s in slots if s["attributes"]["SlotType"] in ("Wall","Castle"))
    for p in decor:
        if wtop(p) <= 0.6: continue                                       # flat road/path overlay
        if onlane and p["name"].startswith(onlane): continue            # wall/castle plot markers belong on the lane
        if abs(p["orientation"][0]) > 1e-6 or abs(p["orientation"][2]) > 1e-6: footprint_r = max(p["size"])/2
        else: footprint_r = None
        for i, poly in polys.items():
            if footprint_r is None:
                d_ = min(seg_rect(*poly[k], *poly[k+1], p) for k in range(len(poly)-1))
            else:
                d_ = poly_dist(p["position"][0], p["position"][2], poly) - footprint_r
            if d_ < LANE_JITTER:
                intrude.append(f"{p['name']}@lane{i}={d_:.2f}"); break
    if intrude: W(f"{len(intrude)} raised decor part(s) inside the {LANE_JITTER}-stud horde corridor: {intrude[:8]}")

    # --- slot overlap ---
    for a_i in range(len(slots)):
        for b_i in range(a_i+1, len(slots)):
            a, b = slots[a_i], slots[b_i]
            ra = max(a["size"][0], a["size"][2])/2; rb = max(b["size"][0], b["size"][2])/2
            dist = math.hypot(a["position"][0]-b["position"][0], a["position"][2]-b["position"][2])
            if dist < (ra + rb) * 0.8: W(f"slots {a['name']} and {b['name']} overlap or nearly touch ({dist:.1f} studs apart)")

    # --- decor ---
    if len(decor) > DECOR_BUDGET: E(f"{len(decor)} decor parts exceeds the {DECOR_BUDGET} budget")
    tall = [p["name"] for p in decor if wtop(p) > 20]
    if tall: W(f"{len(tall)} decor part(s) reach above Y=20 (flyer height): {tall[:5]}")
    for p in decor:
        if wtop(p) < GROUND_Y - 0.01: W(f"decor {p['name']} is buried below the ground")
    # decor intruding on build pads (clips through the building that will stand there)
    for s in slots:
        r = min(s["size"][0], s["size"][2]) / 2 - 1
        sx, sz = s["position"][0], s["position"][2]
        hits = [p["name"] for p in decor
                if math.hypot(p["position"][0]-sx, p["position"][2]-sz) < r and wtop(p) > 1.2]
        if hits: W(f"{s['name']}: decor stands on the build pad and will clip the building: {hits[:4]}")
    I(f"parts: {len(parts)} total, {len(decor)} decor, {len(slots)} slots, {len(spawns)} spawns, {len(nodes)} lane nodes")

if __name__ == "__main__":
    d = main(sys.argv[1])
    if d and len(sys.argv) > 2:
        want = json.loads(sys.argv[2])
        got = {}
        for p in d.get("parts", []):
            if "BuildSlot" in (p.get("tags") or []):
                st = p["attributes"]["SlotType"]; got[st] = got.get(st, 0) + 1
        for k, v in want.items():
            if got.get(k, 0) != v: E(f"slot count {k}: expected {v}, got {got.get(k, 0)}")
        for k in got:
            if k not in want: E(f"unexpected slot type {k} x{got[k]}")
    print(f"ERRORS ({len(errors)})"); [print("  -", e) for e in errors]
    print(f"WARNINGS ({len(warnings)})"); [print("  -", w) for w in warnings]
    print("INFO"); [print("  -", m) for m in info]
    sys.exit(1 if errors else 0)
