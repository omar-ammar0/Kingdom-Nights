-- kn-asset/1 MOUNT importer (Phase 4.6). Template: kn_import_mount.ps1 replaces the JSON
-- placeholder below with the asset file's text and writes <id>_import.luau, which is run
-- through execute_luau in the EDIT datamodel. The JSON is decoded as data, never executed.
--
-- Builds ReplicatedStorage/Assets/Mounts/<id> to the MountService contract:
--   * part "Root" (invisible); every other part UNanchored, Massless, WeldConstraint-welded to it
--   * all physics flags off, no shadows; WorldPivot at (0,0,0) = ground under the pivot, facing -Z
--   * attribute SaddleHeight = the Saddle part's top (the game scales the mount from it)
-- Re-checks the contract rules here, in Studio, so a validator bug cannot slip a bad model in.
-- Replaces an existing model only if it was made by this importer or is a KN_Placeholder.
local HttpService = game:GetService("HttpService")
local RS = game:GetService("ReplicatedStorage")
local d = HttpService:JSONDecode([==[__KN_JSON__]==])

local SADDLE_Y, SADDLE_TOL = 2.0, 0.05
local BUDGET = { bay_horse = 24, warhorse = 30, dire_wolf = 26, sand_lizard = 26, skeletal_steed = 30, sun_stag = 32 }

assert(d.format == "kn-asset/1", "format must be kn-asset/1")
assert(d.kind == "mount", "kind must be mount")
local ID, VERSION = d.name, d.version
assert(type(ID) == "string" and BUDGET[ID], "unknown mount id " .. tostring(ID))
assert(RS.Shared.Config.Source:find("\n%s*" .. ID .. "%s*=%s*{"), "no Config.Mounts entry for " .. ID)
assert(#d.parts <= BUDGET[ID], `{#d.parts} parts exceeds the {BUDGET[ID]} budget`)

local function rot(p) return CFrame.fromOrientation(math.rad(p.orientation[1]), math.rad(p.orientation[2]), math.rad(p.orientation[3])) end
local function cf(p) return CFrame.new(p.position[1], p.position[2], p.position[3]) * rot(p) end
local function topY(p)
	-- world-space half height of a rotated box
	local c = cf(p)
	local s = Vector3.new(p.size[1], p.size[2], p.size[3]) / 2
	local h = math.abs(c.RightVector.Y) * s.X + math.abs(c.UpVector.Y) * s.Y + math.abs(c.LookVector.Y) * s.Z
	return p.position[2] + h
end

local roots, saddle, head = {}, nil, nil
for _, p in d.parts do
	if p.root == true then table.insert(roots, p) end
	if p.name == "Saddle" then assert(not saddle, "two Saddle parts"); saddle = p end
	if p.name == "Head" then head = p end
end
assert(#roots == 1 and roots[1].name == "Root", "need exactly one root part named Root")
assert(saddle, "no Saddle part")
assert(head and head.position[3] < saddle.position[3], "Head must be in front of the saddle (-Z)")
local saddleTop = topY(saddle)
assert(math.abs(saddleTop - SADDLE_Y) <= SADDLE_TOL, `Saddle top {saddleTop} must be {SADDLE_Y}`)

local folder = RS:WaitForChild("Assets"):FindFirstChild("Mounts")
assert(folder, "Assets/Mounts missing")
local old = folder:FindFirstChild(ID)
if old and not (old:GetAttribute("KN_Import") or old:GetAttribute("KN_Placeholder")) then
	error(ID .. " exists and was not made by the importer - refusing to touch it")
end

local SHAPE = { Block = Enum.PartType.Block, Ball = Enum.PartType.Ball, Cylinder = Enum.PartType.Cylinder }
local m = Instance.new("Model")
m.Name = ID .. "__importing"
m:SetAttribute("KN_Import", "kn-asset/1")
m:SetAttribute("KN_Version", VERSION)
m:SetAttribute("KN_Author", tostring(d.author or "?"))
local root: BasePart? = nil
local built = {}
for _, p in d.parts do
	local inst
	if p.shape == "Wedge" then inst = Instance.new("WedgePart")
	elseif p.shape == "CornerWedge" then inst = Instance.new("CornerWedgePart")
	else
		assert(SHAPE[p.shape], "bad shape " .. tostring(p.shape))
		inst = Instance.new("Part"); inst.Shape = SHAPE[p.shape]
	end
	inst.Name = p.name
	inst.Size = Vector3.new(p.size[1], p.size[2], p.size[3])
	inst.CFrame = cf(p)
	inst.Color = Color3.fromHex(p.color)
	inst.Material = Enum.Material[p.material]
	inst.Transparency = p.transparency or 0
	inst.TopSurface, inst.BottomSurface = Enum.SurfaceType.Smooth, Enum.SurfaceType.Smooth
	inst.CanCollide, inst.CanQuery, inst.CanTouch = false, false, false
	inst.CastShadow = false
	inst.Anchored = false
	inst.Massless = true
	if p.root == true then root = inst end
	inst.Parent = m
	table.insert(built, inst)
end
assert(root, "no root")
for _, part in built do
	if part ~= root then
		local w = Instance.new("WeldConstraint")
		w.Part0 = root
		w.Part1 = part
		w.Parent = part
	end
end
m.WorldPivot = CFrame.new(0, 0, 0)
m:SetAttribute("SaddleHeight", saddleTop)

local nParts, nWelds = 0, 0
for _, x in m:GetDescendants() do
	if x:IsA("BasePart") then
		nParts += 1
		assert(not x.Anchored and not x.CanCollide and not x.CanQuery and not x.CanTouch, x.Name .. " has a physics flag on")
	elseif x:IsA("WeldConstraint") then
		nWelds += 1
	end
end
local N = #d.parts
local summary = `parts={nParts}/{N} welds={nWelds}/{N - 1} saddle={string.format("%.2f", saddleTop)}`
if nParts ~= N or nWelds ~= N - 1 then
	m:Destroy()
	return "NOT imported - " .. summary
end
if old then old:Destroy() end
m.Name = ID
m.Parent = folder
return `IMPORTED Assets/Mounts/{ID} v{VERSION} - {summary}`
