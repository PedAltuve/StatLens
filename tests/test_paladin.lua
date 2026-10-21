local S = require("wow_stubs")

local function load()
	S.reset()
	local ns = {}
	for _, f in ipairs({ "Core.lua", "Data/Paladin.lua", "Calc.lua", "Format.lua" }) do S.loadAddonFile(f, ns) end
	return ns, ns.Data.PALADIN
end

local function texts(ns, d, v, ranks)
	local out = {}
	for i, l in ipairs(ns.Format.Lines(ns.Calc.Breakdown(v, ranks, d), ranks, d)) do out[i] = l.text end
	return out
end

T.test("Divine Intellect feeds Champion of the Light", function()
	local ns, d = load()
	local ranks = { divineIntellect = 5, championOfTheLight = 3 }
	local v = { int = 110, sp = 100 }
	local b = ns.Calc.Breakdown(v, ranks, d)
	T.near(b.talents.divineIntellect.contributions.int, 10, 1e-9)
	T.near(b.talents.championOfTheLight.contributions.sp, 33, 1e-9)
	local got = texts(ns, d, v, ranks)
	T.eq(got[1], "Intellect 110 (talents +10)")
	T.eq(got[2], "Divine Intellect 5/5: +10")
	T.eq(got[3], "Spell Power 100 (talents +33)")
	T.eq(got[4], "Champion of the Light 3/3: +33 (30% of Intellect)")
	T.eq(got[5], "incl. +3 from Divine Intellect")
end)

T.test("Toughness inferred marker renders", function()
	local ns, d = load()
	local got = texts(ns, d, { armor = 1100 }, { toughness = 5 })
	T.eq(got[1], "Armor 1100 (talents +100)")
	T.eq(got[2], "Toughness* 5/5: +100")
	T.eq(got[#got], "* rank value inferred, verify in game")
end)

T.test("Precision gives hit and spell hit", function()
	local ns, d = load()
	local b = ns.Calc.Breakdown({ hit = 4, spellHit = 5 }, { precision = 3 }, d)
	T.eq(b.talents.precision.contributions.hit, 3); T.eq(b.talents.precision.contributions.spellHit, 3)
	T.eq(texts(ns, d, { hit = 4, spellHit = 5 }, { precision = 3 })[1], "Melee Hit 4.0% (talents +3.0%)")
end)

T.test("Sacred Duty inverts Stamina; Anticipation mirrors Warrior", function()
	local ns, d = load()
	local b = ns.Calc.Breakdown({ stam = 208, defense = 300, dodge = 5, parry = 5, block = 5 }, { sacredDuty = 2, anticipation = 5 }, d)
	T.near(b.talents.sacredDuty.contributions.stam, 8, 1e-9, "208 - 208/1.04")
	T.eq(b.talents.anticipation.contributions.defense, 20)
	T.near(b.talents.anticipation.contributions.block, 0.8, 1e-9)
end)

T.test("Holy Power gives spell crit", function()
	local ns, d = load()
	local ranks = { holyPower = 5 }
	local v = { spellCrit = 9 }
	T.eq(ns.Calc.Breakdown(v, ranks, d).talents.holyPower.contributions.spellCrit, 5)
	local got = texts(ns, d, v, ranks)
	T.eq(got[1], "Spell Crit 9.0% (talents +5.0%)")
	T.eq(got[2], "Holy Power 5/5: +5.0%")
end)

T.test("Anticipation 5/5: defense and every avoidance stat", function()
	local ns, d = load()
	local c = ns.Calc.Breakdown({ defense = 300, dodge = 5, parry = 5, block = 5 }, { anticipation = 5 }, d).talents.anticipation.contributions
	T.eq(c.defense, 20)
	T.near(c.dodge, 0.8, 1e-9); T.near(c.parry, 0.8, 1e-9); T.near(c.block, 0.8, 1e-9)
end)
