local S = require("wow_stubs")

local function load()
	S.reset()
	local ns = {}
	for _, f in ipairs({ "Core.lua", "Data/Rogue.lua", "Calc.lua", "Format.lua" }) do S.loadAddonFile(f, ns) end
	return ns, ns.Data.ROGUE
end

local function texts(ns, d, v, ranks)
	local out = {}
	for i, l in ipairs(ns.Format.Lines(ns.Calc.Breakdown(v, ranks, d), ranks, d)) do out[i] = l.kind .. "|" .. l.text end
	return out
end

T.test("Malice gives melee and ranged crit", function()
	local ns, d = load()
	local ranks = { malice = 3 }
	local v = { meleeCrit = 8, rangedCrit = 9 }
	local b = ns.Calc.Breakdown(v, ranks, d)
	T.eq(b.talents.malice.contributions.meleeCrit, 3)
	T.eq(b.talents.malice.contributions.rangedCrit, 3)
	local got = texts(ns, d, v, ranks)
	T.eq(got[1], "stat|Melee Crit 8.0% (talents +3.0%)")
	T.eq(got[2], "part|Malice 3/5: +3.0%")
	T.eq(got[3], "stat|Ranged Crit 9.0% (talents +3.0%)")
	T.eq(got[4], "part|Malice 3/5: +3.0%")
end)

T.test("Hack and Slash: active with dagger, inactive with sword", function()
	local ns, d = load()
	local ranks = { hackAndSlash = 5 }
	local v = { meleeCrit = 15, mainHand = "dagger" }
	local b = ns.Calc.Breakdown(v, ranks, d)
	T.eq(b.talents.hackAndSlash.contributions.meleeCrit, 5)
	local got = texts(ns, d, v, ranks)
	T.eq(got[1], "stat|Melee Crit 15.0% (talents +5.0%)")
	T.eq(got[2], "part|Hack and Slash 5/5: +5.0%")

	v.mainHand = "fist"
	b = ns.Calc.Breakdown(v, ranks, d)
	T.eq(b.talents.hackAndSlash.contributions.meleeCrit, 5, "fist weapon counts")

	v.mainHand = "sword"
	b = ns.Calc.Breakdown(v, ranks, d)
	T.eq(b.talents.hackAndSlash.inactive.meleeCrit, 5)
	got = texts(ns, d, v, ranks)
	T.eq(got[1], "stat|Melee Crit 15.0%")
	T.eq(got[2], "inactive|Hack and Slash 5/5: +5.0% with a Dagger or Fist Weapon")
end)

T.test("Deflection gives parry", function()
	local ns, d = load()
	local b = ns.Calc.Breakdown({ parry = 11 }, { deflection = 3 }, d)
	T.eq(b.talents.deflection.contributions.parry, 6)
	T.eq(texts(ns, d, { parry = 11 }, { deflection = 3 })[1], "stat|Parry 11.0% (talents +6.0%)")
end)

T.test("Lightning Reflexes gives dodge", function()
	local ns, d = load()
	local b = ns.Calc.Breakdown({ dodge = 10 }, { lightningReflexes = 5 }, d)
	T.eq(b.talents.lightningReflexes.contributions.dodge, 5)
	T.eq(texts(ns, d, { dodge = 10 }, { lightningReflexes = 5 })[1], "stat|Dodge 10.0% (talents +5.0%)")
end)

T.test("Precision gives melee hit", function()
	local ns, d = load()
	local ranks = { precision = 3 }
	local v = { hit = 5 }
	T.eq(ns.Calc.Breakdown(v, ranks, d).talents.precision.contributions.hit, 3)
	local got = texts(ns, d, v, ranks)
	T.eq(got[1], "stat|Melee Hit 5.0% (talents +3.0%)")
	T.eq(got[2], "part|Precision 3/3: +3.0%")
end)
