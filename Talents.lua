local ADDON, ns = ...

ns.Data = ns.Data or {}
local Talents = { last = nil }
ns.Talents = Talents

local callbacks = {}

-- Call fn(...) under pcall and return its first result, or nil on error / non-function.
local function try(fn, ...)
	if type(fn) ~= "function" then return nil end
	local ok, res = pcall(fn, ...)
	if ok then return res end
end

local function classData()
	local class = select(2, UnitClass("player"))
	return class and ns.Data[class]
end

local function entryName(configID, entryID)
	local entry = try(C_Traits.GetEntryInfo, configID, entryID)
	local def = entry and entry.definitionID and try(C_Traits.GetDefinitionInfo, entry.definitionID)
	if not def then return nil end
	local name = def.overrideName
	if type(name) ~= "string" or name == "" then
		name = def.spellID and try(C_Spell and C_Spell.GetSpellName, def.spellID)
	end
	return name, def.spellID
end

function Talents.Read()
	local result = { ranks = {}, spellIDs = {}, unmatched = {}, missing = {}, ok = false }
	local data = classData()
	if not data then
		Talents.last = result
		return result
	end

	local byName = {}
	for _, t in ipairs(data.talents) do
		result.ranks[t.key] = 0
		byName[t.name] = t
	end

	local configID = C_ClassTalents and try(C_ClassTalents.GetActiveConfigID)
	local info = configID and C_Traits and try(C_Traits.GetConfigInfo, configID)
	if type(info) ~= "table" or type(info.treeIDs) ~= "table" then
		Talents.last = result
		return result
	end

	local found = {}
	for _, treeID in ipairs(info.treeIDs) do
		for _, nodeID in ipairs(try(C_Traits.GetTreeNodes, treeID) or {}) do
			local node = try(C_Traits.GetNodeInfo, configID, nodeID)
			if node and node.ID and node.ID ~= 0 then
				local rank = node.currentRank or node.ranksPurchased or 0
				local firstName, matched
				for _, entryID in ipairs(node.entryIDs or {}) do
					local name, spellID = entryName(configID, entryID)
					firstName = firstName or name
					local t = name and byName[name]
					if t then
						result.ranks[t.key] = rank
						result.spellIDs[t.key] = spellID
						found[t.key] = true
						matched = true
						break
					end
				end
				if not matched and firstName then
					result.unmatched[#result.unmatched + 1] = firstName
				end
			end
		end
	end

	for _, t in ipairs(data.talents) do
		if not found[t.key] then result.missing[#result.missing + 1] = t.name end
	end

	result.ok = true
	Talents.last = result
	return result
end

function Talents.ByName(name)
	local data = classData()
	if not data then return nil end
	for _, t in ipairs(data.talents) do
		if t.name == name then return t end
	end
end

function Talents.BySpellID(spellID)
	local data, last = classData(), Talents.last
	if not (data and last) then return nil end
	for _, t in ipairs(data.talents) do
		if last.spellIDs[t.key] == spellID then return t end
	end
end

function Talents.OnChange(fn)
	callbacks[#callbacks + 1] = fn
end

function Talents.Refresh()
	local result = Talents.Read()
	for i = 1, #callbacks do callbacks[i](result) end
	return result
end

for _, event in ipairs({ "TRAIT_CONFIG_UPDATED", "PLAYER_TALENT_UPDATE", "CHARACTER_POINTS_CHANGED", "PLAYER_LOGIN" }) do
	ns.On(event, Talents.Refresh)
end

ns.commands.talents = function()
	local r = Talents.Read()
	local data = classData()
	if not data then return ns.Print("no talent data for this class") end
	if not r.ok then return ns.Print("could not read talents (C_Traits unavailable)") end
	local parts = {}
	for _, t in ipairs(data.talents) do
		local rank = r.ranks[t.key]
		if rank > 0 then parts[#parts + 1] = ("%s %d/%d"):format(t.name, rank, t.maxRank) end
	end
	ns.Print(#parts > 0 and table.concat(parts, ", ") or "no talents allocated")
	ns.Print("missing: " .. (#r.missing > 0 and table.concat(r.missing, ", ") or "none"))
	ns.Print("unmatched (client talents not in data): " .. (#r.unmatched > 0 and table.concat(r.unmatched, ", ") or "none"))
end
