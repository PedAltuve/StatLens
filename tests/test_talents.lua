local S = require("wow_stubs")

local function load()
	S.reset()
	local ns = {}
	S.loadAddonFile("Core.lua", ns)
	S.loadAddonFile("Data/Shaman.lua", ns)
	S.loadAddonFile("Talents.lua", ns)
	return ns
end

-- Fake tree: spellID -> name, nodes keyed by nodeID.
local function fakeClient()
	local spells = { [100] = "Thundering Strikes", [101] = "Placeholder", [102] = "Bogus Talent", [103] = "Flurry" }
	local defs = {
		[1] = { spellID = 100 },
		[2] = { spellID = 101, overrideName = "Toughness" },
		[3] = { spellID = 102 },
		[4] = { spellID = 103, overrideName = "" },
	}
	local nodes = {
		[1] = { ID = 1, entryIDs = { 1 }, currentRank = 3 },
		[2] = { ID = 2, entryIDs = { 2 }, ranksPurchased = 2 },
		[3] = { ID = 3, entryIDs = { 3 }, currentRank = 1 },
		[4] = { ID = 4, entryIDs = { 4 }, currentRank = 0, ranksPurchased = 0 },
		[5] = { ID = 0 },
	}
	_G.C_ClassTalents = { GetActiveConfigID = function() return 9 end }
	_G.C_Spell = { GetSpellName = function(id) return spells[id] end }
	_G.C_Traits = {
		GetConfigInfo = function(c) if c == 9 then return { treeIDs = { 7 } } end end,
		GetTreeNodes = function() return { 1, 2, 3, 4, 5, 6 } end,
		GetNodeInfo = function(_, id)
			if id == 6 then error("boom") end
			return nodes[id]
		end,
		GetEntryInfo = function(_, e) return { definitionID = e } end,
		GetDefinitionInfo = function(d) return defs[d] end,
	}
end

T.test("data integrity", function()
	local ns = load()
	local d = ns.Data.SHAMAN
	T.eq(d.tree, "Enhancement")
	T.eq(#d.talents, 18, "talent count")
	local seen = {}
	for _, t in ipairs(d.talents) do
		T.truthy(t.key and t.name and t.maxRank and t.kind and t.explain, "fields: " .. tostring(t.key))
		T.truthy(not seen[t.key], "unique key " .. tostring(t.key))
		seen[t.key] = true
		for _, e in ipairs(t.effects or {}) do
			if e.perRank then T.eq(#e.perRank, t.maxRank, "perRank len " .. t.key) end
		end
		if t.kind == "stat" then T.truthy(t.effects and #t.effects > 0, "effects " .. t.key) end
	end
end)

T.test("Read walks the tree", function()
	local ns = load()
	fakeClient()
	local r = ns.Talents.Read()
	T.truthy(r.ok, "ok")
	T.eq(r.ranks.thunderingStrikes or r.ranks[ns.Talents.ByName("Thundering Strikes").key], 3, "currentRank")
	T.eq(r.ranks[ns.Talents.ByName("Toughness").key], 2, "overrideName + ranksPurchased")
	T.eq(r.ranks[ns.Talents.ByName("Flurry").key], 0, "empty override falls back to spell name, rank 0")
	T.eq(r.spellIDs[ns.Talents.ByName("Thundering Strikes").key], 100)
	T.eq(#r.unmatched, 1); T.eq(r.unmatched[1], "Bogus Talent")
	local miss = {}
	for _, n in ipairs(r.missing) do miss[n] = true end
	T.truthy(miss["Earth's Grasp"], "missing listed")
	T.truthy(not miss["Toughness"], "found not missing")
	T.eq(ns.Talents.last, r, "cached")
	T.eq(ns.Talents.BySpellID(100).name, "Thundering Strikes", "BySpellID")
	T.eq(ns.Talents.BySpellID(999), nil)
end)

T.test("Read without C_ClassTalents is ok=false", function()
	local ns = load()
	local okCall, r = pcall(ns.Talents.Read)
	T.truthy(okCall, "no error")
	T.eq(r.ok, false)
end)

T.test("events refresh and fire callbacks", function()
	local ns = load()
	fakeClient()
	local got
	ns.Talents.OnChange(function(res) got = res end)
	S.fire("TRAIT_CONFIG_UPDATED")
	T.truthy(got and got.ok, "callback fired")
	T.eq(ns.Talents.last, got)
end)

T.test("/sl talents prints summary", function()
	local ns = load()
	fakeClient()
	SlashCmdList.STATLENS("talents")
	local all = table.concat(S.chat, "\n")
	T.truthy(all:find("Thundering Strikes 3/5", 1, true), "rank line")
	T.truthy(all:find("missing:", 1, true), "missing")
	T.truthy(all:find("unmatched (client talents not in data):", 1, true), "unmatched")
	T.truthy(all:find("Bogus Talent", 1, true))
end)
