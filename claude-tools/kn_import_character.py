"""kn-asset/1 character importer (enemies and allied units).

Usage: python3 -I kn_import_character.py <enemy-or-unit.json> <out_dir>

Writes ONE Luau script, <id>_import.luau, to run through execute_luau in the EDIT datamodel.
It builds ReplicatedStorage/Assets/<Enemies|Units>/<id> following the map brief, section 8.2:
  * HumanoidRootPart (the part marked "root": true) is Anchored and is the PrimaryPart,
    with PivotOffset moved to the model base so ScaleTo/PivotTo keep the feet on the ground.
  * every other part is UNanchored and WeldConstraint-welded to the root, so moving the root's
    CFrame carries the whole model (handoff gotcha 17).
  * all parts CanCollide/CanQuery/CanTouch = false, CastShadow = false (same as the graybox pool).
  * the Model is ModelStreamingMode Atomic, so a client never sees half a character.
The file is data only: nothing in it is executed. Run kn_validate.py first; this tool repeats
the structural checks and refuses to write a script for a file that fails them.
"""
import json, os, sys

def die(msg):
    print("REFUSED:", msg); sys.exit(1)

def main(path, out_dir):
    d = json.load(open(path, encoding="utf-8"))
    if d.get("format") != "kn-asset/1": die("format must be kn-asset/1")
    kind = d.get("kind")
    if kind not in ("enemy", "unit", "hero", "character"): die(f"kind must be enemy, unit, hero or character, got {kind!r}")
    cid, ver = d["name"], d["version"]
    parts = d["parts"]
    roots = [p for p in parts if p.get("root") is True]
    if len(roots) != 1 or roots[0]["name"] != "HumanoidRootPart": die("need exactly one root part named HumanoidRootPart")
    shapes = {"Block", "Ball", "Cylinder", "Wedge", "CornerWedge"}
    rows = []
    for p in parts:
        if p["shape"] not in shapes: die(f"bad shape {p['shape']}")
        rows.append([p["name"], p["shape"], *p["size"], *p["position"], *p["orientation"],
                     p["color"], p["material"], p.get("transparency", 0), bool(p.get("root"))])
    folder = {"enemy": "Enemies", "character": "Enemies", "unit": "Units", "hero": "Heroes"}[kind]  # "character" = enemy alias
    data = json.dumps(rows, separators=(",", ":"))
    if "]==]" in data: die("data contains the long-string terminator")
    lua = f'''-- kn-asset/1 import character '{cid}' v{ver} ({kind}) -> ReplicatedStorage/Assets/{folder}/{cid}
local HttpService = game:GetService("HttpService")
local RS = game:GetService("ReplicatedStorage")
local ID, VERSION, N = "{cid}", {ver}, {len(rows)}
local folder = RS:WaitForChild("Assets"):WaitForChild("{folder}")
-- The asset name must be a real Config id, or the pool will never find it.
local cfg = RS.Shared.Config.Source
assert(cfg:find('Id="' .. ID .. '"', 1, true), "no Config definition with Id=\\"" .. ID .. "\\" - refusing")
local old = folder:FindFirstChild(ID)
if old and not old:GetAttribute("KN_Import") then
	error(ID .. " exists and was NOT made by the importer - refusing to touch it")
end
local stale = folder:FindFirstChild(ID .. "__importing")
if stale then stale:Destroy() end

local SHAPE = {{ Block = Enum.PartType.Block, Ball = Enum.PartType.Ball, Cylinder = Enum.PartType.Cylinder }}
local rows = HttpService:JSONDecode([==[{data}]==])
local m = Instance.new("Model")
m.Name = ID .. "__importing"
m.ModelStreamingMode = Enum.ModelStreamingMode.Atomic
m:SetAttribute("KN_Import", "kn-asset/1")
m:SetAttribute("KN_Version", VERSION)
m:SetAttribute("KN_Author", "{d.get('author', '?')}")
local root: BasePart? = nil
local built = {{}}
for _, r in rows do
	local inst
	if r[2] == "Wedge" then inst = Instance.new("WedgePart")
	elseif r[2] == "CornerWedge" then inst = Instance.new("CornerWedgePart")
	else inst = Instance.new("Part"); inst.Shape = SHAPE[r[2]] end
	inst.Name = r[1]
	inst.Size = Vector3.new(r[3], r[4], r[5])
	inst.CFrame = CFrame.new(r[6], r[7], r[8]) * CFrame.fromOrientation(math.rad(r[9]), math.rad(r[10]), math.rad(r[11]))
	inst.Color = Color3.fromHex(r[12])
	inst.Material = Enum.Material[r[13]]
	inst.Transparency = r[14]
	inst.TopSurface = Enum.SurfaceType.Smooth
	inst.BottomSurface = Enum.SurfaceType.Smooth
	inst.CanCollide, inst.CanQuery, inst.CanTouch = false, false, false
	inst.CastShadow = false
	inst.Anchored = r[15]
	if r[15] then root = inst end
	inst.Parent = m
	table.insert(built, inst)
end
assert(root, "no root")
for _, p in built do
	if p ~= root then
		p.Massless = true
		local w = Instance.new("WeldConstraint")
		w.Part0 = root
		w.Part1 = p
		w.Parent = p
	end
end
m.PrimaryPart = root
-- Pivot at the model base, not the root's centre (handoff gotcha 18).
root.PivotOffset = CFrame.new(0, -root.Size.Y / 2, 0)

-- Verify before it can replace anything.
local nParts, nAnch, nWelds = 0, 0, 0
for _, x in m:GetDescendants() do
	if x:IsA("BasePart") then
		nParts += 1
		if x.Anchored then nAnch += 1 end
		assert(not x.CanCollide and not x.CanQuery and not x.CanTouch, x.Name .. " has a physics flag on")
	elseif x:IsA("WeldConstraint") then
		nWelds += 1
	end
end
local ok = nParts == N and nAnch == 1 and nWelds == N - 1 and m:FindFirstChildWhichIsA("Humanoid", true) == nil
local summary = `parts={{nParts}}/{{N}} anchored={{nAnch}}/1 welds={{nWelds}}/{{N - 1}} pivotY={{string.format("%.2f", m:GetPivot().Position.Y)}}`
if not ok then
	m:Destroy()
	return "NOT imported - " .. summary
end
if old then old:Destroy() end
m.Name = ID
m.Parent = folder
return `IMPORTED Assets/{folder}/{{ID}} v{{VERSION}} - {{summary}}`
'''
    os.makedirs(out_dir, exist_ok=True)
    out = os.path.join(out_dir, f"{cid}_import.luau")
    open(out, "w", encoding="utf-8").write(lua)
    print(f"{cid} v{ver} ({kind}, {len(rows)} parts) -> {out}")

if __name__ == "__main__":
    main(sys.argv[1], sys.argv[2])
