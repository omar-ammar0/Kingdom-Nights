-- kn-asset/1 import Map_Lastwatch v1: parts chunk 3/3
local HttpService = game:GetService("HttpService")
local CS = game:GetService("CollectionService")
local model = game:GetService("ServerStorage").Maps:FindFirstChild("Map_Lastwatch__importing")
assert(model and model:GetAttribute("KN_Import"), "import shell missing")
local SHAPE = { Block = Enum.PartType.Block, Ball = Enum.PartType.Ball, Cylinder = Enum.PartType.Cylinder }
local rows = HttpService:JSONDecode([==[[["Cliff_17","Block",20,15.418,9,142.768,8.209,-116.46,0,85.351,0,"#34323A","Rock",0,"Decor",[],{}],["Cliff_18","Block",20,17.979,9,141.92,9.489,-95.585,0,91.603,0,"#34323A","Rock",0,"Decor",[],{}],["Cliff_19","Block",20,15.64,9,140.219,8.32,-77.533,0,91.143,0,"#3C3A3F","Rock",0,"Decor",[],{}],["Cliff_23","Block",20,14.384,9,142.202,7.692,-0.283,0,93.028,0,"#3C3A3F","Rock",0,"Decor",[],{}],["Cliff_24","Block",20,9.813,9,142.628,5.406,20.503,0,95.321,0,"#45424A","Rock",0,"Decor",[],{}],["Cliff_25","Block",20,13.782,9,141.713,7.391,38.259,0,93.385,0,"#34323A","Rock",0,"Decor",[],{}],["Cliff_26","Block",20,14.102,9,143.889,7.551,58.312,0,93.886,0,"#45424A","Rock",0,"Decor",[],{}],["Cliff_27","Block",20,16.575,9,141.556,8.788,77.458,0,87.379,0,"#45424A","Rock",0,"Decor",[],{}],["Cliff_28","Block",20,14.59,9,140.176,7.795,98.334,0,90.376,0,"#3C3A3F","Rock",0,"Decor",[],{}],["Cliff_29","Block",20,17.298,9,141.118,9.149,118.129,0,92.72,0,"#3C3A3F","Rock",0,"Decor",[],{}],["Cliff_30","Block",20,12.559,9,142.551,6.779,135.369,0,95.524,0,"#34323A","Rock",0,"Decor",[],{}],["Cliff_31","Block",20,10.693,9,-136.958,5.847,141.281,0,-0.738,0,"#45424A","Rock",0,"Decor",[],{}],["Cliff_32","Block",20,14.485,9,-117.905,7.742,141.215,0,-5.135,0,"#45424A","Rock",0,"Decor",[],{}],["Cliff_33","Block",20,16.768,9,-97.502,8.884,141.272,0,5.371,0,"#34323A","Rock",0,"Decor",[],{}],["Cliff_34","Block",20,10.198,9,-76.827,5.599,143.852,0,-0.002,0,"#3C3A3F","Rock",0,"Decor",[],{}],["Cliff_35","Block",20,14.938,9,-60.43,7.969,142.011,0,4.018,0,"#3C3A3F","Rock",0,"Decor",[],{}],["Cliff_36","Block",20,11.651,9,-40.196,6.325,142.182,0,1.989,0,"#3C3A3F","Rock",0,"Decor",[],{}],["Cliff_37","Block",20,9.904,9,-20.37,5.452,142.451,0,2.464,0,"#34323A","Rock",0,"Decor",[],{}],["Cliff_38","Block",20,13.857,9,-0.654,7.429,143.859,0,-0.842,0,"#34323A","Rock",0,"Decor",[],{}],["Cliff_42","Block",20,17.42,9,79.802,9.21,142.435,0,4.768,0,"#34323A","Rock",0,"Decor",[],{}],["Cliff_43","Block",20,15.448,9,98.939,8.224,140.196,0,2.286,0,"#45424A","Rock",0,"Decor",[],{}],["Cliff_44","Block",20,9.966,9,118.791,5.483,143.773,0,-3.798,0,"#34323A","Rock",0,"Decor",[],{}],["Cliff_45","Block",20,12.085,9,137.848,6.543,141.025,0,2.574,0,"#34323A","Rock",0,"Decor",[],{}],["Cliff_46","Block",20,17.321,9,-143.285,9.161,-136.519,0,92.32,0,"#34323A","Rock",0,"Decor",[],{}],["Cliff_47","Block",20,12.116,9,-142.778,6.558,-115.67,0,88.792,0,"#3C3A3F","Rock",0,"Decor",[],{}],["Cliff_48","Block",20,17.079,9,-141.572,9.039,-97.024,0,92.389,0,"#3C3A3F","Rock",0,"Decor",[],{}],["Cliff_49","Block",20,14.362,9,-142.856,7.681,-79.683,0,85.224,0,"#3C3A3F","Rock",0,"Decor",[],{}],["Cliff_50","Block",20,12.546,9,-142.358,6.773,-59.772,0,85.05,0,"#45424A","Rock",0,"Decor",[],{}],["Cliff_51","Block",20,10.711,9,-142.313,5.855,-39.838,0,85.436,0,"#3C3A3F","Rock",0,"Decor",[],{}],["Cliff_52","Block",20,15.639,9,-140.545,8.32,-20.655,0,87.74,0,"#45424A","Rock",0,"Decor",[],{}],["Cliff_53","Block",20,13.37,9,-140.071,7.185,1.206,0,89.222,0,"#3C3A3F","Rock",0,"Decor",[],{}],["Cliff_57","Block",20,13.429,9,-140.206,7.215,77.792,0,90.399,0,"#34323A","Rock",0,"Decor",[],{}],["Cliff_58","Block",20,13.709,9,-140.349,7.354,98.876,0,92.051,0,"#34323A","Rock",0,"Decor",[],{}],["Cliff_59","Block",20,16.243,9,-141.275,8.622,117.932,0,89.983,0,"#45424A","Rock",0,"Decor",[],{}],["Cliff_60","Block",20,13.609,9,-140.82,7.305,136.911,0,87.157,0,"#34323A","Rock",0,"Decor",[],{}],["Bound_North","Block",300,20,4,0,10.5,-148,0,0,0,"#CAD7DB","Concrete",1,"Bounds",[],{}],["Bound_South","Block",300,20,4,0,10.5,148,0,0,0,"#CAD7DB","Concrete",1,"Bounds",[],{}],["Bound_West","Block",4,20,300,-148,10.5,0,0,0,0,"#CAD7DB","Concrete",1,"Bounds",[],{}],["Bound_East","Block",4,20,300,148,10.5,0,0,0,0,"#CAD7DB","Concrete",1,"Bounds",[],{}]]]==])
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
