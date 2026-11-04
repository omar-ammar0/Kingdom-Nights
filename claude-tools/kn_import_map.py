"""Build Studio import scripts for a kn-asset/1 MAP.

    python3 -I kn_import_map.py <Map_X.json> <out_dir> [parts_per_chunk=150]

Writes out_dir/<name>_0_shell.luau, _1..N_parts.luau, _9_finalise.luau.
Run each through execute_luau (Edit datamodel) in order. ALWAYS run
kn_validate.py first - this script assumes a valid file.

Physics flags are decided here by role, never read from the file:
  Ground (top level)  Anchored, CanCollide, CanQuery            - the floor
  Bounds              Anchored, CanCollide, no query/touch      - invisible edge walls
  Slots/Spawns/Lanes/Decor  Anchored, no collide/query/touch    - spec S23.1
"""
import json, os, sys

src, out = sys.argv[1], sys.argv[2]
per = int(sys.argv[3]) if len(sys.argv) > 3 else 150
d = json.load(open(src, encoding="utf-8"))
assert d["format"] == "kn-asset/1" and d["kind"] == "map"
name, ver = d["name"], d["version"]
shell = f"{name}__importing"
os.makedirs(out, exist_ok=True)

def r(v): return [round(x, 4) for x in v]
rows = [[p["name"], p["shape"], *r(p["size"]), *r(p["position"]), *r(p["orientation"]),
         p["color"], p["material"], p.get("transparency", 0), p.get("folder") or "",
         p.get("tags") or [], p.get("attributes") or {}] for p in d["parts"]]
counts = {"BuildSlot": 0, "EnemySpawn": 0, "LaneNode": 0}
for p in d["parts"]:
    for t in p.get("tags") or []:
        counts[t] = counts.get(t, 0) + 1

open(f"{out}/{name}_0_shell.luau", "w").write(f'''-- kn-asset/1 import {name} v{ver}: step 0, shell
local maps = game:GetService("ServerStorage"):WaitForChild("Maps")
local final = maps:FindFirstChild("{name}")
if final and not final:GetAttribute("KN_Import") then
	error("{name} exists and was NOT made by the importer - refusing to touch it")
end
local stale = maps:FindFirstChild("{shell}")
if stale then
	assert(stale:GetAttribute("KN_Import"), "stale shell without KN_Import - refusing")
	stale:Destroy()
end
local m = Instance.new("Model")
m.Name = "{shell}"
m.ModelStreamingMode = Enum.ModelStreamingMode.Persistent
m:SetAttribute("KN_Import", "kn-asset/1")
m:SetAttribute("KN_Version", {ver})
m:SetAttribute("KN_Author", {json.dumps(d.get("author", ""))})
for _, f in {{ "Slots", "Spawns", "Lanes", "Decor", "Bounds" }} do
	local folder = Instance.new("Folder")
	folder.Name = f
	folder.Parent = m
end
m.Parent = maps
return "shell ready"
''')

body = r'''
local made = 0
for _, r in rows do
	local name, shape = r[1], r[2]
	local inst
	if shape == "Wedge" then
		inst = Instance.new("WedgePart")
	elseif shape == "CornerWedge" then
		inst = Instance.new("CornerWedgePart")
	else
		inst = Instance.new("Part")
		inst.Shape = SHAPE[shape]
	end
	inst.Name = name
	inst.Size = Vector3.new(r[3], r[4], r[5])
	inst.CFrame = CFrame.new(r[6], r[7], r[8])
		* CFrame.fromOrientation(math.rad(r[9]), math.rad(r[10]), math.rad(r[11]))
	inst.Color = Color3.fromHex(r[12])
	inst.Material = Enum.Material[r[13]]
	inst.Transparency = r[14]
	inst.TopSurface = Enum.SurfaceType.Smooth
	inst.BottomSurface = Enum.SurfaceType.Smooth
	inst.Anchored = true
	local folder = r[15]
	if folder == "" then
		inst.CanCollide, inst.CanQuery, inst.CanTouch = true, true, false
	elseif folder == "Bounds" then
		inst.CanCollide, inst.CanQuery, inst.CanTouch = true, false, false
		inst.CastShadow = false
	else
		inst.CanCollide, inst.CanQuery, inst.CanTouch = false, false, false
		inst.CastShadow = folder == "Decor"
	end
	for k, v in r[17] do
		inst:SetAttribute(k, v)
	end
	for _, t in r[16] do
		CS:AddTag(inst, t)
	end
	inst.Parent = if folder == "" then model else model:FindFirstChild(folder)
	made += 1
end
local total = 0
for _, x in model:GetDescendants() do
	if x:IsA("BasePart") then total += 1 end
end
return `chunk built {made}; model now holds {total} parts`
'''
chunks = [rows[i:i+per] for i in range(0, len(rows), per)]
for n, c in enumerate(chunks, 1):
    payload = json.dumps(c, separators=(",", ":"))
    assert "]==]" not in payload
    open(f"{out}/{name}_{n}_parts.luau", "w").write(f'''-- kn-asset/1 import {name} v{ver}: parts chunk {n}/{len(chunks)}
local HttpService = game:GetService("HttpService")
local CS = game:GetService("CollectionService")
local model = game:GetService("ServerStorage").Maps:FindFirstChild("{shell}")
assert(model and model:GetAttribute("KN_Import"), "import shell missing")
local SHAPE = {{ Block = Enum.PartType.Block, Ball = Enum.PartType.Ball, Cylinder = Enum.PartType.Cylinder }}
local rows = HttpService:JSONDecode([==[{payload}]==])''' + body)

open(f"{out}/{name}_9_finalise.luau", "w").write(f'''-- kn-asset/1 import {name} v{ver}: finalise (only if every count matches)
local CS = game:GetService("CollectionService")
local maps = game:GetService("ServerStorage").Maps
local m = maps:FindFirstChild("{shell}")
assert(m and m:GetAttribute("KN_Import"))
local count = {{ BuildSlot = 0, EnemySpawn = 0, LaneNode = 0 }}
local parts, bad = 0, 0
for _, x in m:GetDescendants() do
	if x:IsA("BasePart") then
		parts += 1
		if not x.Anchored then bad += 1 end
		for _, t in CS:GetTags(x) do
			if count[t] then count[t] += 1 end
		end
	end
end
local summary = `parts={{parts}}/{len(rows)} BuildSlot={{count.BuildSlot}}/{counts["BuildSlot"]} EnemySpawn={{count.EnemySpawn}}/{counts["EnemySpawn"]} LaneNode={{count.LaneNode}}/{counts["LaneNode"]} unanchored={{bad}}`
if parts ~= {len(rows)} or count.BuildSlot ~= {counts["BuildSlot"]} or count.EnemySpawn ~= {counts["EnemySpawn"]}
	or count.LaneNode ~= {counts["LaneNode"]} or bad ~= 0 then
	return "NOT finalised - " .. summary
end
local old = maps:FindFirstChild("{name}")
if old then
	assert(old:GetAttribute("KN_Import"), "refusing to replace a non-imported map")
	old:Destroy()
end
m.WorldPivot = CFrame.new()
m.Name = "{name}"
return "FINALISED {name} v{ver} - " .. summary
''')
print(f"{name} v{ver}: {len(rows)} parts -> {len(chunks)} chunk(s) in {out}")
