-- kn-asset/1 import Map_Lastwatch v1: step 0, shell
local maps = game:GetService("ServerStorage"):WaitForChild("Maps")
local final = maps:FindFirstChild("Map_Lastwatch")
if final and not final:GetAttribute("KN_Import") then
	error("Map_Lastwatch exists and was NOT made by the importer - refusing to touch it")
end
local stale = maps:FindFirstChild("Map_Lastwatch__importing")
if stale then
	assert(stale:GetAttribute("KN_Import"), "stale shell without KN_Import - refusing")
	stale:Destroy()
end
local m = Instance.new("Model")
m.Name = "Map_Lastwatch__importing"
m.ModelStreamingMode = Enum.ModelStreamingMode.Persistent
m:SetAttribute("KN_Import", "kn-asset/1")
m:SetAttribute("KN_Version", 1)
m:SetAttribute("KN_Author", "Claude")
for _, f in { "Slots", "Spawns", "Lanes", "Decor", "Bounds" } do
	local folder = Instance.new("Folder")
	folder.Name = f
	folder.Parent = m
end
m.Parent = maps
return "shell ready"
