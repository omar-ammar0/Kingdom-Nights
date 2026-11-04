"""kn-asset/1 building importer.

Usage: python3 -I kn_import_building.py <Model_Ln.json> [<Model_Ln.json> ...] <out_dir>
       python3 -I kn_import_building.py --bundle <out.luau> <Model_Ln.json> [...]
       (bundle = one script with one shared builder; keep each bundle to ~150 parts)

Writes ONE Luau script per file, <Model>_L<n>_import.luau, to run through execute_luau in the EDIT
datamodel. It builds ReplicatedStorage/Assets/Buildings/<Model>/L<n> following the building contract
(COLLAB-LOG 2026-10-14, map brief section 8.1):
  * NO PrimaryPart. A PrimaryPart overrides WorldPivot and sinks the building (handoff gotcha 18).
    The Model's WorldPivot is set to the base centre (0,0,0), which is where BuildService pivots it
    onto the slot.
  * every part Anchored (a building never moves, so no welds), CanQuery/CanTouch false (spec S8.3;
    BuildService forces these again on every clone), CanCollide true like the graybox, CastShadow on.
  * the Model is ModelStreamingMode Atomic, so a client never sees half a building.
  * <Model>/L<n> folder structure: Assets/Buildings/<Model> is a Folder; each level is a Model.
The file is data only: nothing in it is executed. Run kn_validate.py first; this tool repeats the
structural checks (no root, base at Y=0) and refuses to write a script for a file that fails them.
The script refuses to replace an existing level that the importer did not create.
"""
import json, math, os, re, sys

SHAPES = {"Block", "Ball", "Cylinder", "Wedge", "CornerWedge"}


def die(msg):
    print("REFUSED:", msg); sys.exit(1)


def one(path, out_dir):
    d = json.load(open(path, encoding="utf-8"))
    if d.get("format") != "kn-asset/1": die(f"{path}: format must be kn-asset/1")
    if d.get("kind") != "building": die(f"{path}: kind must be building")
    m = re.fullmatch(r"([A-Za-z]+)/L([0-9]+)", str(d.get("name")))
    if not m: die(f"{path}: name must be <Model>/L<n>")
    model, level, ver = m.group(1), int(m.group(2)), d["version"]
    parts = d["parts"]
    rows = []
    for p in parts:
        if p.get("root") or p["name"] == "HumanoidRootPart": die(f"{path}: buildings must have no root part")
        if p["shape"] not in SHAPES: die(f"{path}: bad shape {p['shape']}")
        rows.append([p["name"], p["shape"], *p["size"], *p["position"], *p["orientation"],
                     p["color"], p["material"], p.get("transparency", 0)])
    data = json.dumps(rows, separators=(",", ":"))
    if "]==]" in data: die("data contains the long-string terminator")
    author = re.sub(r"[^A-Za-z0-9 _.-]", "", str(d.get("author", "?")))
    lua = f'''-- kn-asset/1 import building '{model}/L{level}' v{ver} -> ReplicatedStorage/Assets/Buildings/{model}/L{level}
local HttpService = game:GetService("HttpService")
local RS = game:GetService("ReplicatedStorage")
local MODEL, LEVEL, VERSION, N = "{model}", {level}, {ver}, {len(rows)}
local LNAME = "L" .. LEVEL
-- The family name must be a real Config building Model, or BuildService will never find it.
assert(RS.Shared.Config.Source:find('Model%s*=%s*"' .. MODEL .. '"'), "no Config building with Model=\\"" .. MODEL .. "\\" - refusing")
local buildings = RS:WaitForChild("Assets"):WaitForChild("Buildings")
local family = buildings:FindFirstChild(MODEL)
if family and not family:IsA("Folder") then error(MODEL .. " exists and is not a Folder - refusing") end
if not family then
	family = Instance.new("Folder")
	family.Name = MODEL
	family:SetAttribute("KN_Import", "kn-asset/1")
	family.Parent = buildings
end
local old = family:FindFirstChild(LNAME)
if old and not old:GetAttribute("KN_Import") then
	error(MODEL .. "/" .. LNAME .. " exists and was NOT made by the importer - refusing to touch it")
end
local stale = family:FindFirstChild(LNAME .. "__importing")
if stale then stale:Destroy() end

local SHAPE = {{ Block = Enum.PartType.Block, Ball = Enum.PartType.Ball, Cylinder = Enum.PartType.Cylinder }}
local rows = HttpService:JSONDecode([==[{data}]==])
local m = Instance.new("Model")
m.Name = LNAME .. "__importing"
m.ModelStreamingMode = Enum.ModelStreamingMode.Atomic
m:SetAttribute("KN_Import", "kn-asset/1")
m:SetAttribute("KN_Version", VERSION)
m:SetAttribute("KN_Author", "{author}")
local lo, hi = math.huge, -math.huge
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
	inst.Anchored = true
	inst.CanCollide = true
	inst.CanQuery = false
	inst.CanTouch = false
	inst.CastShadow = true
	inst.Parent = m
end
-- Pivot at the base centre; no PrimaryPart (gotcha 18).
m.WorldPivot = CFrame.new(0, 0, 0)
local cf, size = m:GetBoundingBox()
lo, hi = cf.Position.Y - size.Y / 2, cf.Position.Y + size.Y / 2

local nParts, nAnch = 0, 0
for _, x in m:GetDescendants() do
	if x:IsA("BasePart") then
		nParts += 1
		if x.Anchored then nAnch += 1 end
	end
end
local ok = nParts == N and nAnch == N and m.PrimaryPart == nil and math.abs(lo) < 0.06
	and m:FindFirstChildWhichIsA("Humanoid", true) == nil
local summary = `parts={{nParts}}/{{N}} anchored={{nAnch}} primary={{tostring(m.PrimaryPart)}} pivotY={{string.format("%.2f", m:GetPivot().Position.Y)}} bounds Y[{{string.format("%.2f", lo)}},{{string.format("%.2f", hi)}}] X{{string.format("%.2f", size.X)}} Z{{string.format("%.2f", size.Z)}}`
if not ok then
	m:Destroy()
	return "NOT imported - " .. summary
end
if old then old:Destroy() end
m.Name = LNAME
m.Parent = family
return `IMPORTED Assets/Buildings/{{MODEL}}/{{LNAME}} v{{VERSION}} - {{summary}}`
'''
    os.makedirs(out_dir, exist_ok=True)
    out = os.path.join(out_dir, f"{model}_L{level}_import.luau")
    open(out, "w", encoding="utf-8").write(lua)
    print(f"{model}/L{level} v{ver} ({len(rows)} parts) -> {out}")


BUNDLE_HEAD = r'''-- kn-asset/1 building bundle: one builder, several levels. Generated by kn_import_building.py --bundle.
local HttpService = game:GetService("HttpService")
local RS = game:GetService("ReplicatedStorage")
local SHAPE = { Block = Enum.PartType.Block, Ball = Enum.PartType.Ball, Cylinder = Enum.PartType.Cylinder }
local buildings = RS:WaitForChild("Assets"):WaitForChild("Buildings")
local cfgSource = RS.Shared.Config.Source
local function build(MODEL: string, LEVEL: number, VERSION: number, AUTHOR: string, json: string): string
	local LNAME = "L" .. LEVEL
	if not cfgSource:find('Model%s*=%s*"' .. MODEL .. '"') then return MODEL .. "/" .. LNAME .. " REFUSED - no Config building with that Model" end
	local family = buildings:FindFirstChild(MODEL)
	if family and not family:IsA("Folder") then return MODEL .. " REFUSED - exists and is not a Folder" end
	if not family then
		family = Instance.new("Folder")
		family.Name = MODEL
		family:SetAttribute("KN_Import", "kn-asset/1")
		family.Parent = buildings
	end
	local old = family:FindFirstChild(LNAME)
	if old and not old:GetAttribute("KN_Import") then return MODEL .. "/" .. LNAME .. " REFUSED - existing level not made by the importer" end
	local stale = family:FindFirstChild(LNAME .. "__importing")
	if stale then stale:Destroy() end
	local rows = HttpService:JSONDecode(json)
	local N = #rows
	local m = Instance.new("Model")
	m.Name = LNAME .. "__importing"
	m.ModelStreamingMode = Enum.ModelStreamingMode.Atomic
	m:SetAttribute("KN_Import", "kn-asset/1")
	m:SetAttribute("KN_Version", VERSION)
	m:SetAttribute("KN_Author", AUTHOR)
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
		inst.Anchored = true
		inst.CanCollide = true
		inst.CanQuery = false
		inst.CanTouch = false
		inst.CastShadow = true
		inst.Parent = m
	end
	m.WorldPivot = CFrame.new(0, 0, 0)   -- base centre; no PrimaryPart (gotcha 18)
	local cf, size = m:GetBoundingBox()
	local lo, hi = cf.Position.Y - size.Y / 2, cf.Position.Y + size.Y / 2
	local nParts, nAnch = 0, 0
	for _, x in m:GetDescendants() do
		if x:IsA("BasePart") then
			nParts += 1
			if x.Anchored then nAnch += 1 end
		end
	end
	local ok = nParts == N and nAnch == N and m.PrimaryPart == nil and math.abs(lo) < 0.06
		and m:FindFirstChildWhichIsA("Humanoid", true) == nil
	local summary = `parts={nParts}/{N} anchored={nAnch} pivotY={string.format("%.2f", m:GetPivot().Position.Y)} Y[{string.format("%.2f", lo)},{string.format("%.2f", hi)}] X{string.format("%.2f", size.X)} Z{string.format("%.2f", size.Z)}`
	if not ok then
		m:Destroy()
		return MODEL .. "/" .. LNAME .. " NOT imported - " .. summary
	end
	if old then old:Destroy() end
	m.Name = LNAME
	m.Parent = family
	return `IMPORTED {MODEL}/{LNAME} v{VERSION} - {summary}`
end
local results = {}
'''


def bundle(paths, out_file):
    lines = [BUNDLE_HEAD]
    for path in paths:
        d = json.load(open(path, encoding="utf-8"))
        if d.get("format") != "kn-asset/1" or d.get("kind") != "building": die(f"{path}: not a kn-asset/1 building")
        m = re.fullmatch(r"([A-Za-z]+)/L([0-9]+)", str(d.get("name")))
        if not m: die(f"{path}: name must be <Model>/L<n>")
        rows = []
        for p in d["parts"]:
            if p.get("root") or p["name"] == "HumanoidRootPart": die(f"{path}: buildings must have no root part")
            if p["shape"] not in SHAPES: die(f"{path}: bad shape {p['shape']}")
            rows.append([p["name"], p["shape"], *p["size"], *p["position"], *p["orientation"],
                         p["color"], p["material"], p.get("transparency", 0)])
        data = json.dumps(rows, separators=(",", ":"))
        if "]==]" in data: die("data contains the long-string terminator")
        author = re.sub(r"[^A-Za-z0-9 _.-]", "", str(d.get("author", "?")))
        lines.append(f'table.insert(results, build("{m.group(1)}", {int(m.group(2))}, {int(d["version"])}, "{author}", [==[{data}]==]))')
        print(f"{d['name']} v{d['version']} ({len(rows)} parts) -> bundle")
    lines.append('return table.concat(results, "\\n")')
    open(out_file, "w", encoding="utf-8").write("\n".join(lines) + "\n")
    print(f"bundle -> {out_file}")


if __name__ == "__main__":
    if len(sys.argv) >= 4 and sys.argv[1] == "--bundle":
        bundle(sys.argv[3:], sys.argv[2])     # --bundle <out.luau> <file.json> [...]
    elif len(sys.argv) >= 3:
        for f in sys.argv[1:-1]:
            one(f, sys.argv[-1])
    else:
        die("usage: kn_import_building.py <file.json> [...] <out_dir>  |  --bundle <out.luau> <file.json> [...]")
