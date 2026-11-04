--!strict
-- Studio COMMAND BAR script (server context, game NOT running). Do not parent this anywhere.
-- Paste the whole file into View → Command Bar and press Enter.
-- Covers spec §31.1 "Config integrity" + the slice 5 publish-gate checks (QA-slice5.md §5):
--   * every EnemyId in every wave table exists, Endless boss/milestone ids exist
--   * every UpgradeChoices id exists in Config.Upgrades
--   * every Damage profile covers every tag any enemy uses; every DamageProfile reference exists
--   * shop: weapons/champions have numeric UnlockCost / UnlockLevel, DefaultWeapon exists
--   * maps: Model instance exists, numbers are numbers, campaign maps have HeroLevelCap
--   * character/building Model names resolve to an Instance (ServerStorage or ReplicatedStorage)
--   * Config.Places manifests: every listed Service / Controller module exists (proves slice 4 survived)
--   * Monetize ids set (FAIL while any is 0 — expected until Omar's Creator Hub ids are in)
--   * Codes upper-case + numeric, Events numeric, BloodMoon.ForcedMutator names a real mutator
-- Output: one line per problem prefixed FAIL / WARN, then a summary. Clean run = "0 FAIL".
-- WARN = look at it; FAIL = must be fixed before publish (or explicitly waived by Omar in QA-slice5.md §7).

local RS = game:GetService("ReplicatedStorage")
local SS = game:GetService("ServerStorage")
local SSS = game:GetService("ServerScriptService")
local SP = game:GetService("StarterPlayer")

local Config = require(RS.Shared.Config) :: any

local fails, warns = 0, 0
local function FAIL(...: any) fails += 1; print("FAIL", ...) end
local function WARN(...: any) warns += 1; print("WARN", ...) end
local function isnum(v: any): boolean return typeof(v) == "number" and v == v end

local function section(name: string, fn: () -> ())
	local ok, err = pcall(fn)
	if not ok then FAIL(`section {name} crashed: {err}`) end
end

local function findAnywhere(name: string): Instance?
	return SS:FindFirstChild(name, true) or RS:FindFirstChild(name, true)
end

-- 1. Waves → enemies
section("waves", function()
	for mapId, map in Config.Maps do
		for _, night in (map.Nights or {}) do
			for i, e in (night.Entries or {}) do
				if not Config.Enemies[e.EnemyId] then
					FAIL(`map {mapId} night {night.Night} entry {i}: EnemyId "{tostring(e.EnemyId)}" not in Config.Enemies`)
				end
				if not isnum(e.Count) or e.Count < 1 then WARN(`map {mapId} night {night.Night} entry {i}: Count {tostring(e.Count)}`) end
				if not isnum(e.SpawnIndex) or e.SpawnIndex < 1 then WARN(`map {mapId} night {night.Night} entry {i}: SpawnIndex {tostring(e.SpawnIndex)}`) end
			end
		end
	end
end)

-- 2. Endless ids (walk the table; any field named EnemyId / *BossId / *EliteId must be an enemy)
section("endless", function()
	local function walk(t: any, path: string)
		for k, v in t do
			local key = tostring(k)
			if typeof(v) == "table" then
				walk(v, `{path}.{key}`)
			elseif typeof(v) == "string" and (key == "EnemyId" or key:match("BossId$") or key:match("EliteId$") or key:match("Boss$")) then
				if not Config.Enemies[v] then FAIL(`Config.Endless{path}.{key} = "{v}" not in Config.Enemies`) end
			end
		end
	end
	walk(Config.Endless, "")
	if not Config.Maps[Config.Endless.MapId] then FAIL(`Config.Endless.MapId "{Config.Endless.MapId}" has no Config.Maps entry`) end
end)

-- 3. UpgradeChoices → Config.Upgrades
section("upgrades", function()
	for bId, b in Config.Buildings do
		for lvl, L in (b.Levels or {}) do
			for _, uid in (L.UpgradeChoices or {}) do
				if not Config.Upgrades[uid] then FAIL(`building {bId} L{lvl}: UpgradeChoices "{uid}" not in Config.Upgrades`) end
			end
		end
	end
end)

-- 4. Damage profiles × tags
section("damage", function()
	local tags: { [string]: boolean } = { Boss = true }
	for _, e in Config.Enemies do
		for _, t in (e.Tags or {}) do tags[t] = true end
	end
	for profile, row in Config.Damage do
		for tag in tags do
			if not isnum(row[tag]) then FAIL(`Config.Damage.{profile} has no multiplier for tag "{tag}"`) end
		end
	end
	local function checkRef(owner: string, prof: any)
		if prof ~= nil and not Config.Damage[prof] then FAIL(`{owner}: DamageProfile "{tostring(prof)}" not in Config.Damage`) end
	end
	for id, w in Config.Weapons do checkRef(`weapon {id}`, w.DamageProfile) end
	for id, u in Config.Units do if typeof(u) == "table" then checkRef(`unit {id}`, u.DamageProfile) end end
	for id, h in Config.Heroes do checkRef(`hero {id}`, h.DamageProfile) end
	for id, b in Config.Buildings do
		for lvl, L in (b.Levels or {}) do checkRef(`building {id} L{lvl}`, L.DamageProfile) end
	end
end)

-- 5. Shop numbers
section("shop", function()
	local maxLevel = (Config.Progression and Config.Progression.MaxLevel) or 40
	for id, w in Config.Weapons do
		if not isnum(w.UnlockCost) then FAIL(`weapon {id}: UnlockCost not a number`) end
		if not isnum(w.UnlockLevel) or w.UnlockLevel < 1 or w.UnlockLevel > maxLevel then FAIL(`weapon {id}: UnlockLevel {tostring(w.UnlockLevel)} outside 1..{maxLevel}`) end
	end
	for id, c in Config.Champions do
		if not isnum(c.UnlockCost) then FAIL(`champion {id}: UnlockCost not a number`) end
		if not Config.Weapons[c.DefaultWeapon] then FAIL(`champion {id}: DefaultWeapon "{tostring(c.DefaultWeapon)}" not in Config.Weapons`) end
	end
	for id, h in Config.Heroes do
		if not isnum(h.ShardsToUnlock) then WARN(`hero {id}: ShardsToUnlock not a number`) end
	end
end)

-- 6. Maps
section("maps", function()
	local campaign: { [string]: boolean } = {}
	for _, id in ((Config.Matchmaking and Config.Matchmaking.CampaignMaps) or {}) do campaign[id] = true end
	for id, m in Config.Maps do
		if id == "graybox" then continue end
		if typeof(m.Model) ~= "string" or not findAnywhere(m.Model) then FAIL(`map {id}: Model "{tostring(m.Model)}" not found in ServerStorage/ReplicatedStorage`) end
		for _, f in { "StartGold", "UnlockLevel", "DifficultyMult" } do
			if not isnum(m[f]) then FAIL(`map {id}: {f} not a number`) end
		end
		if campaign[id] and not isnum(m.HeroLevelCap) then FAIL(`campaign map {id}: HeroLevelCap missing`) end
		if campaign[id] and (#(m.Nights or {}) == 0) then FAIL(`campaign map {id}: no Nights`) end
	end
	if Config.Maps.lastwatch and Config.Maps.lastwatch.Model ~= "Map_Lastwatch" then
		WARN(`lastwatch still uses stand-in model "{Config.Maps.lastwatch.Model}" (Map_Lastwatch not imported yet)`)
	end
end)

-- 7. Character / building models resolve. Models live at
-- ReplicatedStorage.Assets.<Folder>.<config id> (the Config `Model` field is not the lookup key).
section("models", function()
	local assets = RS:FindFirstChild("Assets")
	if not assets then FAIL("ReplicatedStorage.Assets missing") return end
	local function chk(folder: string, t: any)
		local f = assets:FindFirstChild(folder)
		for id, v in t do
			if typeof(v) == "table" and not (f and f:FindFirstChild(id)) then WARN(`{folder}.{id}: no model (graybox fallback)`) end
		end
	end
	chk("Enemies", Config.Enemies)
	chk("Units", Config.Units)
	chk("Heroes", Config.Heroes)
	chk("Buildings", Config.Buildings)
end)

-- 8. Place manifests → modules exist (this is the "did slice 4 survive" check)
section("places", function()
	for placeKind, manifest in (Config.Places or {}) do
		for _, name in (manifest.Services or {}) do
			local inst = SSS:FindFirstChild(name, true)
			if not inst or not inst:IsA("ModuleScript") then FAIL(`Config.Places.{placeKind}.Services: "{name}" is not a ModuleScript under ServerScriptService`) end
		end
		for _, name in (manifest.Controllers or {}) do
			local inst = SP:FindFirstChild(name, true)
			if not inst or not inst:IsA("ModuleScript") then FAIL(`Config.Places.{placeKind}.Controllers: "{name}" is not a ModuleScript under StarterPlayer`) end
		end
	end
	-- slice 4 expectations
	local function has(list: any, name: string): boolean
		for _, n in (list or {}) do if n == name then return true end end
		return false
	end
	local P = Config.Places or {}
	if not (P.Lobby and has(P.Lobby.Services, "CodeService")) then FAIL("slice 4: CodeService missing from Lobby manifest") end
	for _, kind in { "Lobby", "Match" } do
		if not (P[kind] and has(P[kind].Services, "EventService")) then FAIL(`slice 4: EventService missing from {kind} manifest`) end
		if not (P[kind] and has(P[kind].Controllers, "EventController")) then FAIL(`slice 4: EventController missing from {kind} manifest`) end
	end
end)

-- 9. Monetize
section("monetize", function()
	local M = Config.Monetize
	for kind, t in { Passes = M.Passes, Products = M.Products } do
		for key, def in (t or {}) do
			if (def.Id or 0) == 0 then FAIL(`Monetize.{kind}.{key}: Id is 0 (store shows COMING SOON)`) end
			if not isnum(def.R) then WARN(`Monetize.{kind}.{key}: R (Robux) not a number`) end
		end
	end
	local sp = M.Passes and M.Passes.stable_pass
	for _, mountId in ((sp and sp.Grants) or {}) do
		if not Config.Mounts[mountId] then FAIL(`stable_pass grants mount "{mountId}" not in Config.Mounts`) end
	end
	local cp = M.Passes and M.Passes.champion_pack
	for _, champId in ((cp and cp.Grants) or {}) do
		if not Config.Champions[champId] then FAIL(`champion_pack grants champion "{champId}" not in Config.Champions`) end
	end
end)

-- 10. Codes / Events / Mutators
section("codes_events", function()
	for code, def in (Config.Codes or {}) do
		if code ~= code:upper() or code:match("[^%w]") then FAIL(`code "{code}" must be upper-case alphanumeric (CodeService normalises input that way)`) end
		if not isnum(def.Expires) then FAIL(`code {code}: Expires not a number (0 = never)`) end
		if not isnum(def.Crowns) and not isnum(def.Shards) then FAIL(`code {code}: grants nothing`) end
		if def.Expires ~= 0 and def.Expires < os.time() then WARN(`code {code}: already expired`) end
	end
	local Ev = Config.Events or {}
	if not isnum(Ev.PollSeconds) or Ev.PollSeconds < 60 then WARN(`Events.PollSeconds {tostring(Ev.PollSeconds)} (DataStore read every poll per server)`) end
	local bm = Ev.BloodMoon
	if bm then
		if not isnum(bm.CrownMult) or not isnum(bm.ShardMult) then FAIL("Events.BloodMoon multipliers not numbers") end
		if bm.ForcedMutator and not (Config.Mutators or {})[bm.ForcedMutator] then FAIL(`Events.BloodMoon.ForcedMutator "{bm.ForcedMutator}" not in Config.Mutators`) end
		if bm.ForcedMutator then WARN("Events.BloodMoon.ForcedMutator is set but no mutator system exists (decision open with Omar; event ships as 2x rewards only)") end
	end
	for id, m in (Config.Mutators or {}) do
		if typeof(m.Display) ~= "string" or not isnum(m.Reward) then FAIL(`mutator {id}: Display/Reward malformed`) end
	end
end)

-- 11. Debug flag + place ids
section("flags", function()
	if Config.Debug and Config.Debug.EnablePerfTools == true then FAIL("Config.Debug.EnablePerfTools is TRUE (audit B1: must be false for a public publish)") end
	if Config.LobbyPlaceId == 0 or Config.MatchPlaceId == 0 then FAIL("LobbyPlaceId / MatchPlaceId still 0") end
end)

print(`── ConfigIntegrityCheck done: {fails} FAIL, {warns} WARN ──`)
