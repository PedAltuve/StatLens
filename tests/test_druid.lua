local S = require("wow_stubs")

local function load()
	S.reset()
	local ns = {}
	for _, f in ipairs({ "Core.lua", "Data/Shaman.lua", "Data/Druid.lua", "Calc.lua", "Format.lua" }) do
		S.loadAddonFile(f, ns)
	end
	return ns, ns.Data.DRUID
end

local RANKS = { heartOfTheWild = 5, sharpenedClaws = 2, predatoryStrikes = 3, feralSwiftness = 2 }

local function values(form)
	return { int = 50, str = 110, stam = 200, ap = 300, meleeCrit = 20, dodge = 10, level = 25, form = form }
end

local function lines(form)
	local ns, d = load()
	return ns.Format.Lines(ns.Calc.Breakdown(values(form), RANKS, d), RANKS, d)
end

local function dump(ls)
	local out = {}
	for i, l in ipairs(ls) do out[i] = ("%d|%s|%s"):format(l.indent, l.kind, l.text) end
	return out
end

local function expect(actual, expected)
	T.eq(#actual, #expected, "line count")
	for i = 1, math.max(#actual, #expected) do T.eq(actual[i], expected[i], "line " .. i) end
end

T.test("druid data spot checks", function()
	local ns, d = load()
	local byKey = {}
	for _, t in ipairs(d.talents) do byKey[t.key] = t end
	T.eq(byKey.thickHide.inferred.rank, true)
	T.eq(byKey.thickHide.effects[1].op, "perLevel")
	T.eq(byKey.heartOfTheWild.effects[2].forms[1], "bear")
	T.eq(byKey.leaderOfThePack.effects[1].perRank[1], 3)
	T.eq(byKey.naturalInstinct.effects[1].stat, "heal")
	T.eq(byKey.naturesMajesty.tree, "Balance")
	T.eq(byKey.berserk.kind, "conditional")
end)

T.test("panel lines, cat form", function()
	expect(dump(lines("cat")), {
		"0|stat|Strength 110 (talents +10)",
		"1|part|Heart of the Wild 5/5: +10",
		"0|stat|Stamina 200",
		"1|inactive|Heart of the Wild 5/5: +40 in Bear Form",
		"0|stat|Intellect 50 (talents +5)",
		"1|part|Heart of the Wild 5/5: +5",
		"0|stat|Attack Power 300 (talents +38)",
		"1|part|Predatory Strikes 3/3: +38 (150% of level)",
		"0|stat|Melee Crit 20.0% (talents +6.0%)",
		"1|part|Sharpened Claws 2/2: +6.0%",
		"0|stat|Dodge 10.0% (talents +4.0%)",
		"1|part|Feral Swiftness 2/2: +4.0%",
	})
end)

T.test("panel lines, bear form flips str to inactive", function()
	local got = dump(lines("bear"))
	T.eq(got[1], "0|stat|Strength 110")
	T.eq(got[2], "1|inactive|Heart of the Wild 5/5: +11 in Cat Form")
	T.eq(got[3], "0|stat|Stamina 200 (talents +33)")
	T.eq(got[4], "1|part|Heart of the Wild 5/5: +33")
	T.eq(got[8], "1|part|Predatory Strikes 3/3: +38 (150% of level)", "cat or bear still active")
end)

T.test("panel lines, no form: all form effects inactive", function()
	local got = dump(lines(nil))
	T.eq(got[1], "0|stat|Strength 110")
	T.eq(got[2], "1|inactive|Heart of the Wild 5/5: +11 in Cat Form")
	T.eq(got[3], "0|stat|Stamina 200")
	T.eq(got[4], "1|inactive|Heart of the Wild 5/5: +40 in Bear Form")
	T.eq(got[7], "0|stat|Attack Power 300")
	T.eq(got[8], "1|inactive|Predatory Strikes 3/3: +38 in Cat or Bear Form")
	T.eq(got[9], "0|stat|Melee Crit 20.0%")
	T.eq(got[10], "1|inactive|Sharpened Claws 2/2: +6.0% in Bear or Cat Form")
	T.eq(got[11], "0|stat|Dodge 10.0% (talents +4.0%)", "unconditional dodge stays active")
end)

T.test("armor perLevel text and inferred marker", function()
	local ns, d = load()
	local ranks = { thickHide = 2 }
	local v = { armor = 1000, level = 25, form = "bear" }
	local got = dump(ns.Format.Lines(ns.Calc.Breakdown(v, ranks, d), ranks, d))
	T.eq(got[1], "0|stat|Armor 1000 (talents +50)")
	T.eq(got[2], "1|part|Thick Hide* 2/3: +50 (2 per level)")
	T.eq(got[3], "0|note|* rank value inferred, verify in game")
end)

T.test("TooltipLines with inactive contributions and next point", function()
	local ns, d = load()
	local ranks = { heartOfTheWild = 4 }
	local v = values("cat")
	local entry
	for _, t in ipairs(d.talents) do if t.key == "heartOfTheWild" then entry = t end end
	local l = ns.Format.TooltipLines(entry, 4, ns.Calc.Breakdown(v, ranks, d), ns.Calc.NextPoint(v, ranks, d, "heartOfTheWild"))
	local t = {}
	for i, x in ipairs(l) do t[i] = x.text end
	T.eq(t[1], "StatLens")
	T.eq(t[2], "Now: +8 Strength")
	T.eq(t[3], "Now: +4 Intellect")
	T.eq(t[4], "In Bear Form: +32 Stamina")
	T.near(l[4].r, 0.6, 1e-9); T.near(l[4].g, 0.6, 1e-9)
	T.eq(t[5], "Next point (5/5): +2 Strength")
	T.eq(t[6], "Next point (5/5): +1 Intellect")
	T.eq(t[7], "Next point (5/5): +8 Stamina in Bear Form")
	T.near(l[7].r, 0.6, 1e-9)
	T.eq(#t, 7)
end)

T.test("StatTooltipLines inactive and perLevel", function()
	local ns, d = load()
	local G, W, D, E = "|cffffd100", "|cffffffff", "|cff999999", "|r"
	local b = ns.Calc.Breakdown(values("cat"), RANKS, d)
	local stam = ns.Format.StatTooltipLines("stam", b, d, RANKS)
	T.eq(#stam, 1)
	T.eq(stam[1], D .. "In Bear Form: +40 (Heart of the Wild 5/5)" .. E)
	local ap = ns.Format.StatTooltipLines("ap", b, d, RANKS)
	T.eq(ap[1], G .. "Talents add " .. E .. W .. "+38" .. E .. D .. " (Predatory Strikes 3/3)" .. E)
	local none = ns.Calc.Breakdown(values(nil), RANKS, d)
	T.eq(ns.Format.StatTooltipLines("ap", none, d, RANKS)[1], D .. "In Cat or Bear Form: +38 (Predatory Strikes 3/3)" .. E)
	T.eq(#ns.Format.StatTooltipLines("ap", none, d, RANKS), 1, "no active lines when inactive")
end)
