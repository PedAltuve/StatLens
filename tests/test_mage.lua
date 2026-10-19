local S = require("wow_stubs")

local function load()
	S.reset()
	local ns = {}
	for _, f in ipairs({ "Core.lua", "Data/Mage.lua", "Calc.lua", "Format.lua" }) do S.loadAddonFile(f, ns) end
	return ns, ns.Data.MAGE
end

local function texts(ns, d, v, ranks)
	local out = {}
	for i, l in ipairs(ns.Format.Lines(ns.Calc.Breakdown(v, ranks, d), ranks, d)) do out[i] = l.text end
	return out
end

T.test("Arcane Mind feeds Arcane Resilience armor", function()
	local ns, d = load()
	local ranks = { arcaneMind = 5, arcaneResilience = 2 }
	local v = { int = 110, armor = 300 }
	local b = ns.Calc.Breakdown(v, ranks, d)
	T.near(b.talents.arcaneMind.contributions.int, 10, 1e-9)
	T.near(b.talents.arcaneResilience.contributions.armor, 55, 1e-9)
	local got = texts(ns, d, v, ranks)
	T.eq(got[1], "Intellect 110 (talents +10)")
	T.eq(got[2], "Arcane Mind 5/5: +10")
	T.eq(got[3], "Armor 300 (talents +55)")
	T.eq(got[4], "Arcane Resilience 2/2: +55 (50% of Intellect)")
	T.eq(got[5], "incl. +5 from Arcane Mind")
end)

T.test("Arcane Instability gives melee and spell crit", function()
	local ns, d = load()
	local b = ns.Calc.Breakdown({ meleeCrit = 5, spellCrit = 8 }, { arcaneInstability = 3 }, d)
	T.eq(b.talents.arcaneInstability.contributions.meleeCrit, 3)
	T.eq(b.talents.arcaneInstability.contributions.spellCrit, 3)
end)

T.test("Magic Absorption is explained, not measured", function()
	local ns, d = load()
	local t
	for _, x in ipairs(d.talents) do if x.key == "magicAbsorption" then t = x end end
	T.eq(t.kind, "conditional")
	T.eq(t.effects, nil)
	T.truthy(t.explain:find("resistances"), "explain mentions resistances")
	local b = ns.Calc.Breakdown({ int = 100 }, { magicAbsorption = 2 }, d)
	T.eq(b.talents.magicAbsorption, nil)
end)
