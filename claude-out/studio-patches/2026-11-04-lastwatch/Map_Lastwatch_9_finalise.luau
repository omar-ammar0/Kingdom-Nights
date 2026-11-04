-- kn-asset/1 import Map_Lastwatch v1: finalise (only if every count matches)
local CS = game:GetService("CollectionService")
local maps = game:GetService("ServerStorage").Maps
local m = maps:FindFirstChild("Map_Lastwatch__importing")
assert(m and m:GetAttribute("KN_Import"))
local count = { BuildSlot = 0, EnemySpawn = 0, LaneNode = 0 }
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
local summary = `parts={parts}/339 BuildSlot={count.BuildSlot}/16 EnemySpawn={count.EnemySpawn}/4 LaneNode={count.LaneNode}/24 unanchored={bad}`
if parts ~= 339 or count.BuildSlot ~= 16 or count.EnemySpawn ~= 4
	or count.LaneNode ~= 24 or bad ~= 0 then
	return "NOT finalised - " .. summary
end
local old = maps:FindFirstChild("Map_Lastwatch")
if old then
	assert(old:GetAttribute("KN_Import"), "refusing to replace a non-imported map")
	old:Destroy()
end
m.WorldPivot = CFrame.new()
m.Name = "Map_Lastwatch"
return "FINALISED Map_Lastwatch v1 - " .. summary
