"""kn-asset/1 map DELTA importer.

Usage: python3 -I kn_patch_map.py <old Map_X.json (the version now in Studio)> <new Map_X.json> <out_dir>

For a new version that only changes how existing parts LOOK (shape, size, position, orientation,
colour, material, transparency), this writes one Luau patch that edits exactly those parts in
ServerStorage/Maps/Map_X and bumps its KN_Version. It REFUSES (exit 1) - meaning: do a full
kn_import_map.py import instead - when anything structural changed: parts added or removed, or
any change to folder, tags or attributes (slots, spawns, lanes). Slot/spawn/lane parts may not be
touched by a patch at all, because BuildService reads them at load.
The patch itself checks the map in Studio is the expected old version and carries KN_Import.
"""
import json, os, sys

VISUAL = ("shape", "size", "position", "orientation", "color", "material", "transparency")

def die(msg):
    print("REFUSED (do a full import):", msg); sys.exit(1)

def main(old_path, new_path, out_dir):
    old = json.load(open(old_path, encoding="utf-8")); new = json.load(open(new_path, encoding="utf-8"))
    if old["name"] != new["name"]: die("different map names")
    if new["version"] <= old["version"]: die(f"new version {new['version']} is not above {old['version']}")
    O = {p["name"]: p for p in old["parts"]}; N = {p["name"]: p for p in new["parts"]}
    if set(O) != set(N): die(f"parts added {sorted(set(N)-set(O))[:5]} / removed {sorted(set(O)-set(N))[:5]}")
    changed = []
    for name, np_ in N.items():
        op = O[name]
        for k in set(op) | set(np_):
            if k in VISUAL: continue
            if op.get(k) != np_.get(k): die(f"{name}: structural field '{k}' changed")
        if any(op.get(k, 0 if k == "transparency" else None) != np_.get(k, 0 if k == "transparency" else None) for k in VISUAL):
            if np_.get("folder") in ("Slots", "Spawns", "Lanes") or np_.get("tags"):
                die(f"{name}: gameplay part changed - BuildService reads it at load")
            changed.append(np_)
    if not changed: die("no visual changes found")
    rows = [[p["name"], p["shape"], *p["size"], *p["position"], *p["orientation"], p["color"], p["material"], p.get("transparency", 0)] for p in changed]
    data = json.dumps(rows, separators=(",", ":"))
    mname = new["name"]
    lua = f'''-- kn-asset/1 DELTA patch {mname} v{old["version"]} -> v{new["version"]}: {len(rows)} part(s), visual fields only
local HttpService = game:GetService("HttpService")
local m = game:GetService("ServerStorage").Maps:FindFirstChild("{mname}")
assert(m and m:GetAttribute("KN_Import"), "{mname} missing or not made by the importer")
assert(m:GetAttribute("KN_Version") == {old["version"]}, "expected v{old["version"]} in Studio, found v" .. tostring(m:GetAttribute("KN_Version")))
local SHAPE = {{ Block = Enum.PartType.Block, Ball = Enum.PartType.Ball, Cylinder = Enum.PartType.Cylinder }}
local rows = HttpService:JSONDecode([==[{data}]==])
-- Find every target first; patch nothing unless all are present and are plain Parts.
local targets = {{}}
for i, r in rows do
	local p = m:FindFirstChild(r[1], true)
	assert(p and p:IsA("BasePart"), "part " .. r[1] .. " not found")
	if r[2] == "Wedge" or r[2] == "CornerWedge" or not p:IsA("Part") then
		error(r[1] .. ": class change needed - do a full import")
	end
	targets[i] = p
end
for i, r in rows do
	local p = targets[i] :: Part
	p.Shape = SHAPE[r[2]]
	p.Size = Vector3.new(r[3], r[4], r[5])
	p.CFrame = CFrame.new(r[6], r[7], r[8]) * CFrame.fromOrientation(math.rad(r[9]), math.rad(r[10]), math.rad(r[11]))
	p.Color = Color3.fromHex(r[12])
	p.Material = Enum.Material[r[13]]
	p.Transparency = r[14]
end
m:SetAttribute("KN_Version", {new["version"]})
local s = targets[1]
return `PATCHED {mname} -> v{new["version"]}: {{#rows}} parts; sample {{s.Name}} shape={{s.Shape.Name}} size={{tostring(s.Size)}}`
'''
    os.makedirs(out_dir, exist_ok=True)
    out = os.path.join(out_dir, f"{mname}_v{new['version']}_patch.luau")
    open(out, "w", encoding="utf-8").write(lua)
    print(f"{mname} v{old['version']} -> v{new['version']}: {len(rows)} visual part change(s) -> {out}")
    print("changed parts:", ", ".join(sorted(p["name"] for p in changed))[:300])

if __name__ == "__main__":
    main(sys.argv[1], sys.argv[2], sys.argv[3])
