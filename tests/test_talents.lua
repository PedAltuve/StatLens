local S = require("wow_stubs")

local function load()
	S.reset()
	local ns = {}
	S.loadAddonFile("Core.lua", ns)
	S.loadAddonFile("Data/Shaman.lua", ns)
	S.loadAddonFile("Data/Druid.lua", ns)
	S.loadAddonFile("Data/Warrior.lua", ns)
	S.loadAddonFile("Data/Priest.lua", ns)
	S.loadAddonFile("Data/Paladin.lua", ns)
	S.loadAddonFile("Data/Mage.lua", ns)
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

local STATS = { defense = 1, block = 1, hit = 1, spellHit = 1, health = 1, spirit = 1, int = 1, stam = 1, agi = 1, str = 1, ap = 1, sp = 1, heal = 1, meleeCrit = 1,
	spellCrit = 1, dodge = 1, parry = 1, armor = 1,
	rangedAp = 1, rangedCrit = 1 }
local OPS = { pct = 1, flat = 1, fromStat = 1, perLevel = 1, enables = 1 }
local KINDS = { stat = 1, conditional = 1, utility = 1 }

T.test("data integrity (all classes)", function()
	local ns = load()
	local expected = { SHAMAN = 50, DRUID = 52, WARRIOR = 52, PRIEST = 52, PALADIN = 50, MAGE = 55 }
	local classes = 0
	for class, d in pairs(ns.Data) do
		classes = classes + 1
		T.truthy(d.tree, class .. " tree")
		T.eq(#d.talents, expected[class], class .. " talent count")
		local seen, names = {}, {}
		for _, t in ipairs(d.talents) do
			local id = class .. "/" .. tostring(t.key)
			T.truthy(t.key and t.name and t.maxRank and t.kind and t.explain, "fields: " .. id)
			T.truthy(KINDS[t.kind], "kind " .. id)
			T.truthy(not seen[t.key], "unique key " .. id)
			T.truthy(not names[t.name], "unique name " .. id)
			seen[t.key], names[t.name] = true, true
			for _, e in ipairs(t.effects or {}) do
				T.truthy(STATS[e.stat], "stat " .. id)
				T.truthy(OPS[e.op], "op " .. id)
				if e.op ~= "enables" then T.eq(#e.perRank, t.maxRank, "perRank len " .. id) end
				if e.op == "fromStat" then T.truthy(STATS[e.source], "source " .. id) end
				if e.forms then T.truthy(type(e.forms) == "table" and #e.forms > 0, "forms " .. id) end
			end
			if t.kind == "stat" then T.truthy(t.effects and #t.effects > 0, "effects " .. id) end
		end
	end
	T.eq(classes, 6)
	T.eq(ns.Data.SHAMAN.tree, "Enhancement"); T.eq(ns.Data.DRUID.tree, "Feral Combat")
end)

T.test("Read with DRUID (incl. off-tree talent)", function()
	local ns = load()
	_G.UnitClass = function() return "Druid", "DRUID" end
	local spells = { [1] = "Heart of the Wild", [2] = "Nature's Majesty", [3] = "Bogus Talent" }
	local nodes = {
		[1] = { ID = 1, entryIDs = { 1 }, currentRank = 5 },
		[2] = { ID = 2, entryIDs = { 2 }, currentRank = 2 },
		[3] = { ID = 3, entryIDs = { 3 }, currentRank = 1 },
	}
	_G.C_ClassTalents = { GetActiveConfigID = function() return 9 end }
	_G.C_Spell = { GetSpellName = function(id) return spells[id] end }
	_G.C_Traits = {
		GetConfigInfo = function() return { treeIDs = { 7, 8 } } end,
		GetTreeNodes = function(tree) return tree == 7 and { 1, 3 } or { 2 } end,
		GetNodeInfo = function(_, id) return nodes[id] end,
		GetEntryInfo = function(_, e) return { definitionID = e } end,
		GetDefinitionInfo = function(d) return { spellID = d } end,
	}
	local r = ns.Talents.Read()
	T.truthy(r.ok)
	T.eq(r.ranks.heartOfTheWild, 5); T.eq(r.ranks.naturesMajesty, 2)
	T.eq(r.ranks.ferocity, 0)
	T.eq(r.unmatched[1], "Bogus Talent")
	T.eq(ns.Talents.ByName("Nature's Majesty").tree, "Balance")
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

T.test("a throwing OnChange callback does not block others", function()
	local ns = load()
	fakeClient()
	local got
	ns.Talents.OnChange(function() error("bad") end)
	ns.Talents.OnChange(function(res) got = res end)
	local ok = pcall(S.fire, "PLAYER_LOGIN")
	T.truthy(ok, "no error escapes")
	T.truthy(got, "later callback ran")
end)

T.test("shaman: 50 unique talents across three trees", function()
	local ns = load()
	local d = ns.Data.SHAMAN
	T.eq(#d.talents, 50)
	local names, trees = {}, {}
	for _, t in ipairs(d.talents) do
		T.truthy(not names[t.name], "unique name " .. t.name)
		names[t.name] = true
		trees[t.tree or "Enhancement"] = (trees[t.tree or "Enhancement"] or 0) + 1
	end
	T.eq(trees["Enhancement"], 18); T.eq(trees["Elemental Combat"], 16); T.eq(trees["Restoration"], 16)
end)

T.test("Read matches Elemental and Restoration talents by name", function()
	local ns = load()
	local spells = { [1] = "Concussion", [2] = "Riptide", [3] = "Tidal Focus" }
	local nodes = {
		[1] = { ID = 1, entryIDs = { 1 }, currentRank = 4 },
		[2] = { ID = 2, entryIDs = { 2 }, currentRank = 1 },
		[3] = { ID = 3, entryIDs = { 3 }, currentRank = 5 },
	}
	_G.C_ClassTalents = { GetActiveConfigID = function() return 9 end }
	_G.C_Spell = { GetSpellName = function(id) return spells[id] end }
	_G.C_Traits = {
		GetConfigInfo = function() return { treeIDs = { 7 } } end,
		GetTreeNodes = function() return { 1, 2, 3 } end,
		GetNodeInfo = function(_, id) return nodes[id] end,
		GetEntryInfo = function(_, e) return { definitionID = e } end,
		GetDefinitionInfo = function(d) return { spellID = d } end,
	}
	local r = ns.Talents.Read()
	T.eq(r.ranks.concussion, 4); T.eq(r.ranks.riptide, 1); T.eq(r.ranks.tidalFocus, 5)
	T.eq(#r.unmatched, 0, "nothing unmatched")
	T.eq(ns.Talents.ByName("Riptide").tree, "Restoration")
	T.eq(ns.Talents.ByName("Concussion").tree, "Elemental Combat")
end)

T.test("druid: 52 unique talents across three trees", function()
	local ns = load()
	local d = ns.Data.DRUID
	T.eq(#d.talents, 52)
	local names, trees = {}, {}
	for _, t in ipairs(d.talents) do
		T.truthy(not names[t.name], "unique name " .. t.name)
		names[t.name] = true
		local tree = t.tree or "Feral Combat"
		trees[tree] = (trees[tree] or 0) + 1
	end
	T.eq(trees["Feral Combat"], 20); T.eq(trees["Balance"], 16); T.eq(trees["Restoration"], 16)
end)

T.test("Read matches Balance and Restoration druid talents", function()
	local ns = load()
	_G.UnitClass = function() return "Druid", "DRUID" end
	local spells = { [1] = "Moonfury", [2] = "Wild Growth", [3] = "Living Spirit" }
	local nodes = {
		[1] = { ID = 1, entryIDs = { 1 }, currentRank = 5 },
		[2] = { ID = 2, entryIDs = { 2 }, currentRank = 1 },
		[3] = { ID = 3, entryIDs = { 3 }, currentRank = 3 },
	}
	_G.C_ClassTalents = { GetActiveConfigID = function() return 9 end }
	_G.C_Spell = { GetSpellName = function(id) return spells[id] end }
	_G.C_Traits = {
		GetConfigInfo = function() return { treeIDs = { 7 } } end,
		GetTreeNodes = function() return { 1, 2, 3 } end,
		GetNodeInfo = function(_, id) return nodes[id] end,
		GetEntryInfo = function(_, e) return { definitionID = e } end,
		GetDefinitionInfo = function(d) return { spellID = d } end,
	}
	local r = ns.Talents.Read()
	T.eq(r.ranks.moonfury, 5); T.eq(r.ranks.wildGrowth, 1); T.eq(r.ranks.livingSpirit, 3)
	T.eq(#r.unmatched, 0)
	T.eq(ns.Talents.ByName("Moonfury").tree, "Balance")
	T.eq(ns.Talents.ByName("Wild Growth").tree, "Restoration")
end)

T.test("warrior: 52 unique talents, 17/17/18 split", function()
	local ns = load()
	local d = ns.Data.WARRIOR
	T.eq(d.tree, "Arms"); T.eq(#d.talents, 52)
	local names, trees = {}, {}
	for _, t in ipairs(d.talents) do
		T.truthy(not names[t.name], "unique name " .. t.name)
		names[t.name] = true
		local tree = t.tree or "Arms"
		trees[tree] = (trees[tree] or 0) + 1
		for _, e in ipairs(t.effects or {}) do
			if e.weapons then T.truthy(#e.weapons > 0, "weapons " .. t.key) end
		end
	end
	T.eq(trees.Arms, 17); T.eq(trees.Fury, 17); T.eq(trees.Protection, 18)
end)

T.test("Read matches one warrior talent per tree", function()
	local ns = load()
	_G.UnitClass = function() return "Warrior", "WARRIOR" end
	local spells = { [1] = "Deflection", [2] = "Cruelty", [3] = "Anticipation" }
	local nodes = {
		[1] = { ID = 1, entryIDs = { 1 }, currentRank = 5 },
		[2] = { ID = 2, entryIDs = { 2 }, currentRank = 4 },
		[3] = { ID = 3, entryIDs = { 3 }, currentRank = 3 },
	}
	_G.C_ClassTalents = { GetActiveConfigID = function() return 9 end }
	_G.C_Spell = { GetSpellName = function(id) return spells[id] end }
	_G.C_Traits = {
		GetConfigInfo = function() return { treeIDs = { 7 } } end,
		GetTreeNodes = function() return { 1, 2, 3 } end,
		GetNodeInfo = function(_, id) return nodes[id] end,
		GetEntryInfo = function(_, e) return { definitionID = e } end,
		GetDefinitionInfo = function(d) return { spellID = d } end,
	}
	local r = ns.Talents.Read()
	T.eq(r.ranks.deflection, 5); T.eq(r.ranks.cruelty, 4); T.eq(r.ranks.anticipation, 3)
	T.eq(#r.unmatched, 0)
	T.eq(ns.Talents.ByName("Cruelty").tree, "Fury")
	T.eq(ns.Talents.ByName("Anticipation").tree, "Protection")
end)

T.test("priest: 52 unique talents, 18/17/17 split", function()
	local ns = load()
	local d = ns.Data.PRIEST
	T.eq(d.tree, "Discipline"); T.eq(#d.talents, 52)
	local names, trees = {}, {}
	for _, t in ipairs(d.talents) do
		T.truthy(not names[t.name], "unique name " .. t.name)
		names[t.name] = true
		local tree = t.tree or "Discipline"
		trees[tree] = (trees[tree] or 0) + 1
	end
	T.eq(trees.Discipline, 18); T.eq(trees.Holy, 17); T.eq(trees["Shadow Magic"], 17)
end)

T.test("Read matches one priest talent per tree", function()
	local ns = load()
	_G.UnitClass = function() return "Priest", "PRIEST" end
	local spells = { [1] = "Mental Strength", [2] = "Spiritual Guidance", [3] = "Shadowform" }
	local nodes = {
		[1] = { ID = 1, entryIDs = { 1 }, currentRank = 5 },
		[2] = { ID = 2, entryIDs = { 2 }, currentRank = 3 },
		[3] = { ID = 3, entryIDs = { 3 }, currentRank = 1 },
	}
	_G.C_ClassTalents = { GetActiveConfigID = function() return 9 end }
	_G.C_Spell = { GetSpellName = function(id) return spells[id] end }
	_G.C_Traits = {
		GetConfigInfo = function() return { treeIDs = { 7 } } end,
		GetTreeNodes = function() return { 1, 2, 3 } end,
		GetNodeInfo = function(_, id) return nodes[id] end,
		GetEntryInfo = function(_, e) return { definitionID = e } end,
		GetDefinitionInfo = function(d) return { spellID = d } end,
	}
	local r = ns.Talents.Read()
	T.eq(r.ranks.mentalStrength, 5); T.eq(r.ranks.spiritualGuidance, 3); T.eq(r.ranks.shadowform, 1)
	T.eq(#r.unmatched, 0)
	T.eq(ns.Talents.ByName("Spiritual Guidance").tree, "Holy")
	T.eq(ns.Talents.ByName("Shadowform").tree, "Shadow Magic")
	T.eq(ns.Talents.ByName("Improved Power Word: Shield").key, "improvedPowerWordShield")
end)

T.test("paladin: 50 unique talents, 17/16/17 split", function()
	local ns = load()
	local d = ns.Data.PALADIN
	T.eq(d.tree, "Holy"); T.eq(#d.talents, 50)
	local names, trees = {}, {}
	for _, t in ipairs(d.talents) do
		T.truthy(not names[t.name], "unique name " .. t.name)
		names[t.name] = true
		local tree = t.tree or "Holy"
		trees[tree] = (trees[tree] or 0) + 1
	end
	T.eq(trees.Holy, 17); T.eq(trees.Protection, 16); T.eq(trees.Retribution, 17)
end)

T.test("Read matches one paladin talent per tree", function()
	local ns = load()
	_G.UnitClass = function() return "Paladin", "PALADIN" end
	local spells = { [1] = "Divine Intellect", [2] = "Sacred Duty", [3] = "Champion of the Light" }
	local nodes = {
		[1] = { ID = 1, entryIDs = { 1 }, currentRank = 5 },
		[2] = { ID = 2, entryIDs = { 2 }, currentRank = 2 },
		[3] = { ID = 3, entryIDs = { 3 }, currentRank = 3 },
	}
	_G.C_ClassTalents = { GetActiveConfigID = function() return 9 end }
	_G.C_Spell = { GetSpellName = function(id) return spells[id] end }
	_G.C_Traits = {
		GetConfigInfo = function() return { treeIDs = { 7 } } end,
		GetTreeNodes = function() return { 1, 2, 3 } end,
		GetNodeInfo = function(_, id) return nodes[id] end,
		GetEntryInfo = function(_, e) return { definitionID = e } end,
		GetDefinitionInfo = function(d) return { spellID = d } end,
	}
	local r = ns.Talents.Read()
	T.eq(r.ranks.divineIntellect, 5); T.eq(r.ranks.sacredDuty, 2); T.eq(r.ranks.championOfTheLight, 3)
	T.eq(#r.unmatched, 0)
	T.eq(ns.Talents.ByName("Sacred Duty").tree, "Protection")
	T.eq(ns.Talents.ByName("Champion of the Light").tree, "Retribution")
end)

T.test("mage: 55 unique talents, 19/17/19 split", function()
	local ns = load()
	local d = ns.Data.MAGE
	T.eq(d.tree, "Arcane"); T.eq(#d.talents, 55)
	local names, trees = {}, {}
	for _, t in ipairs(d.talents) do
		T.truthy(not names[t.name], "unique name " .. t.name)
		names[t.name] = true
		local tree = t.tree or "Arcane"
		trees[tree] = (trees[tree] or 0) + 1
	end
	T.eq(trees.Arcane, 19); T.eq(trees.Fire, 17); T.eq(trees.Frost, 19)
end)

T.test("Read matches one mage talent per tree", function()
	local ns = load()
	_G.UnitClass = function() return "Mage", "MAGE" end
	local spells = { [1] = "Arcane Mind", [2] = "Critical Mass", [3] = "Shatter" }
	local nodes = {
		[1] = { ID = 1, entryIDs = { 1 }, currentRank = 5 },
		[2] = { ID = 2, entryIDs = { 2 }, currentRank = 3 },
		[3] = { ID = 3, entryIDs = { 3 }, currentRank = 2 },
	}
	_G.C_ClassTalents = { GetActiveConfigID = function() return 9 end }
	_G.C_Spell = { GetSpellName = function(id) return spells[id] end }
	_G.C_Traits = {
		GetConfigInfo = function() return { treeIDs = { 7 } } end,
		GetTreeNodes = function() return { 1, 2, 3 } end,
		GetNodeInfo = function(_, id) return nodes[id] end,
		GetEntryInfo = function(_, e) return { definitionID = e } end,
		GetDefinitionInfo = function(d) return { spellID = d } end,
	}
	local r = ns.Talents.Read()
	T.eq(r.ranks.arcaneMind, 5); T.eq(r.ranks.criticalMass, 3); T.eq(r.ranks.shatter, 2)
	T.eq(#r.unmatched, 0)
	T.eq(ns.Talents.ByName("Critical Mass").tree, "Fire")
	T.eq(ns.Talents.ByName("Shatter").tree, "Frost")
end)
