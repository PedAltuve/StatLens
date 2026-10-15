local S = require("wow_stubs")

local function load()
	S.reset()
	local ns = {}
	for _, f in ipairs({ "Core.lua", "Data/Warrior.lua", "Calc.lua", "Format.lua" }) do S.loadAddonFile(f, ns) end
	return ns, ns.Data.WARRIOR
end

local function texts(ns, d, v, ranks)
	local out = {}
	for i, l in ipairs(ns.Format.Lines(ns.Calc.Breakdown(v, ranks, d), ranks, d)) do out[i] = l.kind .. "|" .. l.text end
	return out
end

T.test("Weaponmaster: active with axe, inactive with sword", function()
	local ns, d = load()
	local ranks = { weaponmaster = 5 }
	local v = { meleeCrit = 15, mainHand = "axe" }
	local b = ns.Calc.Breakdown(v, ranks, d)
	T.eq(b.talents.weaponmaster.contributions.meleeCrit, 5)
	local got = texts(ns, d, v, ranks)
	T.eq(got[1], "stat|Melee Crit 15.0% (talents +5.0%)")
	T.eq(got[2], "part|Weaponmaster 5/5: +5.0%")

	v.mainHand = "sword"
	b = ns.Calc.Breakdown(v, ranks, d)
	T.eq(b.talents.weaponmaster.inactive.meleeCrit, 5)
	got = texts(ns, d, v, ranks)
	T.eq(got[1], "stat|Melee Crit 15.0%")
	T.eq(got[2], "inactive|Weaponmaster 5/5: +5.0% with an Axe or Polearm")
end)

T.test("Shield Specialization: needs a shield", function()
	local ns, d = load()
	local ranks = { shieldSpecialization = 5 }
	local b = ns.Calc.Breakdown({ block = 10, offHand = "shield" }, ranks, d)
	T.eq(b.talents.shieldSpecialization.contributions.block, 5)
	b = ns.Calc.Breakdown({ block = 10, offHand = "offhand" }, ranks, d)
	T.eq(b.talents.shieldSpecialization.inactive.block, 5)
	T.eq(b.stats.block.talentTotal, 0)
	local got = texts(ns, d, { block = 10 }, ranks)
	T.eq(got[2], "inactive|Shield Specialization 5/5: +5.0% with a shield")
end)

T.test("Anticipation: defense plus derived dodge/parry/block", function()
	local ns, d = load()
	local ranks = { anticipation = 5 }
	local v = { defense = 300, dodge = 5, parry = 6, block = 7 }
	local b = ns.Calc.Breakdown(v, ranks, d)
	local c = b.talents.anticipation.contributions
	T.eq(c.defense, 20)
	T.near(c.dodge, 0.8, 1e-9); T.near(c.parry, 0.8, 1e-9); T.near(c.block, 0.8, 1e-9)
	local entry
	for _, t in ipairs(d.talents) do if t.key == "anticipation" then entry = t end end
	T.eq(entry.inferred.rank, true)
	T.eq(entry.maxRank, 5)
end)

T.test("Cruelty and Deflection are flat", function()
	local ns, d = load()
	local b = ns.Calc.Breakdown({ meleeCrit = 12, parry = 8 }, { cruelty = 4, deflection = 3 }, d)
	T.eq(b.talents.cruelty.contributions.meleeCrit, 4)
	T.eq(b.talents.deflection.contributions.parry, 3)
end)
