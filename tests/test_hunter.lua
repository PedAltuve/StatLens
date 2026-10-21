local S = require("wow_stubs")

local function load()
	S.reset()
	local ns = {}
	for _, f in ipairs({ "Core.lua", "Data/Hunter.lua", "Calc.lua", "Format.lua" }) do S.loadAddonFile(f, ns) end
	return ns, ns.Data.HUNTER
end

local function texts(ns, d, v, ranks)
	local out = {}
	for i, l in ipairs(ns.Format.Lines(ns.Calc.Breakdown(v, ranks, d), ranks, d)) do out[i] = l.text end
	return out
end

T.test("Careful Aim adds melee and ranged AP from Intellect", function()
	local ns, d = load()
	local ranks = { carefulAim = 5 }
	local v = { int = 60, ap = 300, rangedAp = 400 }
	local b = ns.Calc.Breakdown(v, ranks, d)
	T.near(b.talents.carefulAim.contributions.ap, 60, 1e-9)
	T.near(b.talents.carefulAim.contributions.rangedAp, 60, 1e-9)
	local got = texts(ns, d, v, ranks)
	T.eq(got[1], "Attack Power 300 (talents +60)")
	T.eq(got[2], "Careful Aim 5/5: +60 (100% of Intellect)")
	T.eq(got[3], "Ranged Attack Power 400 (talents +60)")
	T.eq(got[4], "Careful Aim 5/5: +60 (100% of Intellect)")
end)

T.test("Lethal Attacks gives melee and ranged crit", function()
	local ns, d = load()
	local ranks = { lethalAttacks = 3 }
	local v = { meleeCrit = 8, rangedCrit = 9 }
	local b = ns.Calc.Breakdown(v, ranks, d)
	T.eq(b.talents.lethalAttacks.contributions.meleeCrit, 3)
	T.eq(b.talents.lethalAttacks.contributions.rangedCrit, 3)
	local got = texts(ns, d, v, ranks)
	T.eq(got[1], "Melee Crit 8.0% (talents +3.0%)")
	T.eq(got[2], "Lethal Attacks 3/5: +3.0%")
	T.eq(got[3], "Ranged Crit 9.0% (talents +3.0%)")
	T.eq(got[4], "Lethal Attacks 3/5: +3.0%")
end)

T.test("Lightning Reflexes inverts agility", function()
	local ns, d = load()
	local b = ns.Calc.Breakdown({ agi = 110 }, { lightningReflexes = 5 }, d)
	T.near(b.talents.lightningReflexes.contributions.agi, 10, 1e-9)
end)

T.test("Survivalist inverts health", function()
	local ns, d = load()
	local b = ns.Calc.Breakdown({ health = 1100 }, { survivalist = 5 }, d)
	T.near(b.talents.survivalist.contributions.health, 100, 1e-9)
end)

T.test("Savage Strikes is explained, not measured", function()
	local ns, d = load()
	local t
	for _, x in ipairs(d.talents) do if x.key == "savageStrikes" then t = x end end
	T.eq(t.kind, "conditional")
	T.eq(t.effects, nil)
	T.truthy(t.explain:find("melee abilities"), "explain mentions melee abilities")
	local b = ns.Calc.Breakdown({ meleeCrit = 10 }, { savageStrikes = 2 }, d)
	T.eq(b.talents.savageStrikes, nil)
end)
