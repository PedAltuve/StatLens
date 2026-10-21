local S = require("wow_stubs")

local function load()
	S.reset()
	local ns = {}
	S.loadAddonFile("Core.lua", ns)
	S.loadAddonFile("Data/Shaman.lua", ns)
	S.loadAddonFile("Calc.lua", ns)
	S.loadAddonFile("Format.lua", ns)
	return ns, ns.Data.SHAMAN
end

local values = { int = 341, stam = 200, ap = 500, sp = 300, meleeCrit = 10, spellCrit = 8, dodge = 6, parry = 5 }

local function texts(lines)
	local out = {}
	for i, l in ipairs(lines) do out[i] = l.text end
	return out
end

local function index(lines, text)
	for i, l in ipairs(lines) do if l.text == text then return i, l end end
end

T.test("Format.Lines realistic case", function()
	local ns, d = load()
	local ranks = { ancestralKnowledge = 5, mentalDexterity = 3, mentalQuickness = 2,
		thunderingStrikes = 3, spiritWeapons = 1, flurry = 5 }
	local lines = ns.Format.Lines(ns.Calc.Breakdown(values, ranks, d), ranks, d)

	local _, int = index(lines, "Intellect 341 (talents +31)")
	T.truthy(int, "int stat line"); T.eq(int.kind, "stat"); T.eq(int.indent, 0)
	local _, ak = index(lines, "Ancestral Knowledge 5/5: +31")
	T.truthy(ak, "pct part"); T.eq(ak.kind, "part"); T.eq(ak.indent, 1)

	local md, mdl = index(lines, "Mental Dexterity* 3/5: +341 (100% of Intellect)")
	if not md then md, mdl = index(lines, "Mental Dexterity* 3/3: +341 (100% of Intellect)") end
	T.truthy(md, "fromStat part with inferred star")
	local chain = lines[md + 1]
	T.eq(chain.text, "incl. +31 from Ancestral Knowledge"); T.eq(chain.kind, "chain"); T.eq(chain.indent, 2)
	T.truthy(index(lines, "Attack Power 500 (talents +341)"))
	T.truthy(index(lines, "Mental Quickness 2/2: +102 (30% of Intellect)"))
	T.truthy(index(lines, "incl. +9 from Ancestral Knowledge"))

	T.truthy(index(lines, "Melee Crit 10.0% (talents +3.0%)"), "crit one decimal")
	T.truthy(index(lines, "Thundering Strikes 3/5: +3.0%"))
	T.truthy(index(lines, "Spell Crit 8.0% (talents +3.0%)"))
	T.truthy(index(lines, "Spirit Weapons: enables Parry (5.0%)"), "enables line")
	T.truthy(index(lines, "Parry 5.0%"), "enables-only stat line has no talent total")
	T.eq(index(lines, "Stamina 200"), nil, "no parts, no line")

	local h = index(lines, "Conditional talents")
	T.truthy(h, "conditional header"); T.eq(lines[h].kind, "header")
	local f = lines[h + 1]
	T.eq(f.kind, "note")
	T.truthy(f.text:find("^Flurry 5/5: "), "flurry note")
	T.eq(lines[#lines].text, "* rank value inferred, verify in game")
	T.eq(lines[#lines].kind, "note")
end)

T.test("no footer or conditional section when not applicable", function()
	local ns, d = load()
	local ranks = { ancestralKnowledge = 5 }
	local lines = ns.Format.Lines(ns.Calc.Breakdown(values, ranks, d), ranks, d)
	T.eq(index(lines, "Conditional talents"), nil)
	T.eq(index(lines, "* rank value inferred, verify in game"), nil)
	T.eq(#lines, 2)
end)

T.test("empty case", function()
	local ns, d = load()
	local lines = ns.Format.Lines(ns.Calc.Breakdown(values, {}, d), {}, d)
	T.eq(#lines, 1)
	T.eq(lines[1].text, "No stat talents taken yet."); T.eq(lines[1].kind, "note")
end)

-- TooltipLines
local function tip(key, rank, vals)
	local ns, d = load()
	local ranks = { ancestralKnowledge = 2, mentalDexterity = 3, mentalQuickness = 0 }
	ranks[key] = rank
	local b = ns.Calc.Breakdown(vals or values, ranks, d)
	local np = ns.Calc.NextPoint(vals or values, ranks, d, key)
	local entry
	for _, t in ipairs(d.talents) do if t.key == key then entry = t end end
	return ns.Format.TooltipLines(entry, rank, b, np)
end

T.test("TooltipLines AK 2/5 with next point and chain", function()
	local lines = tip("ancestralKnowledge", 2)
	local t = texts(lines)
	T.eq(t[1], "StatLens"); T.near(lines[1].r, 1, 1e-9); T.near(lines[1].g, 0.82, 1e-9)
	T.eq(t[2], "Now: +13 Intellect")
	T.eq(t[3], "  incl. +13 Attack Power via Mental Dexterity")
	T.eq(t[4], "Next point (3/5): +7 Intellect")
	T.eq(t[5], "  incl. +7 Attack Power via Mental Dexterity")
	T.eq(#t, 5)
end)

T.test("TooltipLines maxed, inferred, enables, flat", function()
	local t = texts(tip("mentalDexterity", 3))
	T.eq(t[#t], "Maxed")
	t = texts(tip("mentalDexterity", 1))
	T.truthy(t[#t - 0]:find("(value inferred)", 1, true) or t[#t - 1]:find("(value inferred)", 1, true), "inferred marker")
	T.truthy(t[2]:find("^Now: %+%d+ Attack Power"))
	t = texts(tip("spiritWeapons", 0))
	T.eq(t[2], "Next point (1/1): enables Parry")
	t = texts(tip("spiritWeapons", 1))
	T.eq(t[2], "Now: enables Parry"); T.eq(t[3], "Maxed")
	t = texts(tip("thunderingStrikes", 2))
	T.eq(t[2], "Now: +2.0% Melee Crit"); T.eq(t[3], "Now: +2.0% Spell Crit")
	T.eq(t[4], "Next point (3/5): +1.0% Melee Crit")
end)

T.test("TooltipLines conditional and utility", function()
	local ns, d = load()
	local flurry, eg
	for _, t in ipairs(d.talents) do
		if t.key == "flurry" then flurry = t elseif t.key == "earthsGrasp" then eg = t end
	end
	local l = ns.Format.TooltipLines(flurry, 2, { stats = {}, talents = {} }, nil)
	T.eq(l[2].text, "Not shown on character sheet: " .. flurry.explain)
	T.near(l[2].r, 0.6, 1e-9)
	l = ns.Format.TooltipLines(eg, 0, { stats = {}, talents = {} }, nil)
	T.eq(l[2].text, "No stat effect.")
end)

-- StatTooltipLines
local G, W, D, E = "|cffffd100", "|cffffffff", "|cff999999", "|r"

T.test("StatTooltipLines", function()
	local ns, d = load()
	local v = { int = 72, stam = 200, ap = 200, meleeCrit = 10, parry = 5 }
	local ranks = { ancestralKnowledge = 1, mentalDexterity = 3, thunderingStrikes = 5, spiritWeapons = 1 }
	local b = ns.Calc.Breakdown(v, ranks, d)
	local L = function(stat) return ns.Format.StatTooltipLines(stat, b, d, ranks) end

	local int = L("int")
	T.eq(#int, 2)
	T.eq(int[1], G .. "Talents add " .. E .. W .. "+1" .. E .. D .. " (Ancestral Knowledge 1/5)" .. E)
	T.eq(int[2], G .. "Increases " .. E .. W .. "Attack Power" .. E .. G .. " by " .. E .. W .. "72" .. E
		.. D .. " (Mental Dexterity* 3/3)" .. E)

	local ap = L("ap")
	T.eq(#ap, 2)
	T.eq(ap[1], G .. "Includes " .. E .. W .. "+72" .. E .. G .. " from " .. E .. W .. "Intellect" .. E
		.. D .. " (Mental Dexterity* 3/3)" .. E)
	T.eq(ap[2], D .. "  incl. +1 via Ancestral Knowledge" .. E)

	local crit = L("meleeCrit")
	T.eq(crit[1], G .. "Talents add " .. E .. W .. "+5.0%" .. E .. D .. " (Thundering Strikes 5/5)" .. E)

	local parry = L("parry")
	T.eq(parry[1], G .. "Enabled by " .. E .. W .. "Spirit Weapons" .. E)

	T.eq(#L("stam"), 0, "nothing applies")
	T.eq(#L("str"), 0)
end)

T.test("heal and armor labels and order", function()
	local ns, d = load()
	local ranks = { mentalQuickness = 2 }
	local v = { int = 100, sp = 50, heal = 60 }
	local lines = ns.Format.Lines(ns.Calc.Breakdown(v, ranks, d), ranks, d)
	local sp, heal
	for i, l in ipairs(lines) do
		if l.text:find("^Spell Power") then sp = i end
		if l.text:find("^Spell Healing") then heal = i end
	end
	T.truthy(sp and heal and heal > sp, "Spell Healing after Spell Power")
	local tt = ns.Format.StatTooltipLines("int", ns.Calc.Breakdown(v, ranks, d), d, ranks)
	local joined = table.concat(tt, "\n")
	T.truthy(joined:find("Spell Healing", 1, true), "tooltip names heal")
end)

T.test("new stat labels, order and rendering", function()
	local ns = load()
	local d = { talents = {
		{ key = "a", name = "A", maxRank = 1, kind = "stat", explain = "x", effects = {
			{ stat = "health", op = "pct", perRank = { 0.1 } }, { stat = "spirit", op = "pct", perRank = { 0.1 } },
			{ stat = "hit", op = "flat", perRank = { 2 } }, { stat = "spellHit", op = "flat", perRank = { 2 } },
			{ stat = "stam", op = "pct", perRank = { 0.1 } }, { stat = "int", op = "pct", perRank = { 0.1 } } } },
	} }
	local v = { health = 1100, spirit = 110, hit = 3, spellHit = 4, stam = 110, int = 110 }
	local lines = ns.Format.Lines(ns.Calc.Breakdown(v, { a = 1 }, d), { a = 1 }, d)
	local heads = {}
	for _, l in ipairs(lines) do if l.kind == "stat" then heads[#heads + 1] = l.text end end
	T.eq(heads[1], "Health 1100 (talents +100)")
	T.eq(heads[2], "Stamina 110 (talents +10)")
	T.eq(heads[3], "Intellect 110 (talents +10)")
	T.eq(heads[4], "Spirit 110 (talents +10)")
	T.eq(heads[5], "Melee Hit 3.0% (talents +2.0%)")
	T.eq(heads[6], "Spell Hit 4.0% (talents +2.0%)")
end)

T.test("condition text for inactive parts", function()
	local ns = load()
	local d = { talents = {
		{ key = "wm", name = "Weaponmaster", maxRank = 1, kind = "stat", explain = "x",
			effects = { { stat = "meleeCrit", op = "flat", weapons = { "axe", "polearm" }, perRank = { 5 } } } },
		{ key = "sh", name = "Shield Thing", maxRank = 1, kind = "stat", explain = "x",
			effects = { { stat = "block", op = "flat", shield = true, perRank = { 3 } } } },
		{ key = "cb", name = "Combo", maxRank = 1, kind = "stat", explain = "x",
			effects = { { stat = "dodge", op = "flat", forms = { "cat" }, weapons = { "sword" }, perRank = { 2 } } } },
	} }
	local ranks = { wm = 1, sh = 1, cb = 1 }
	local v = { meleeCrit = 10, block = 5, dodge = 4, defense = 300, mainHand = "sword", offHand = "offhand" }
	local b = ns.Calc.Breakdown(v, ranks, d)
	local out = {}
	for _, l in ipairs(ns.Format.Lines(b, ranks, d)) do out[#out + 1] = l.kind .. "|" .. l.text end
	local all = table.concat(out, "\n")
	T.truthy(all:find("inactive|Weaponmaster 1/1: +5.0% with an Axe or Polearm", 1, true), all)
	T.truthy(all:find("inactive|Shield Thing 1/1: +3.0% with a shield", 1, true), all)
	T.truthy(all:find("inactive|Combo 1/1: +2.0% in Cat Form and with a Sword", 1, true), all)
	T.truthy(all:find("Block 5.0%", 1, true) and all:find("Dodge 4.0%", 1, true))
	local st = ns.Format.StatTooltipLines("meleeCrit", b, d, ranks)
	T.eq(st[1], "|cff999999With an Axe or Polearm: +5.0% (Weaponmaster 1/1)|r")
	local entry = d.talents[1]
	local tl = ns.Format.TooltipLines(entry, 1, b, nil)
	T.eq(tl[2].text, "With an Axe or Polearm: +5.0% Melee Crit")
end)

T.test("defense/block labels and order", function()
	local ns = load()
	local d = { talents = {
		{ key = "a", name = "A", maxRank = 1, kind = "stat", explain = "x", effects = {
			{ stat = "defense", op = "flat", perRank = { 5 } }, { stat = "block", op = "flat", perRank = { 2 } },
			{ stat = "dodge", op = "flat", perRank = { 1 } }, { stat = "parry", op = "flat", perRank = { 1 } } } },
	} }
	local v = { defense = 300, block = 5, dodge = 4, parry = 6 }
	local heads = {}
	for _, l in ipairs(ns.Format.Lines(ns.Calc.Breakdown(v, { a = 1 }, d), { a = 1 }, d)) do
		if l.kind == "stat" then heads[#heads + 1] = l.text end
	end
	T.eq(heads[1], "Defense 300 (talents +5)")
	T.eq(heads[2], "Dodge 4.0% (talents +1.0%)")
	T.eq(heads[3], "Parry 6.0% (talents +1.0%)")
	T.eq(heads[4], "Block 5.0% (talents +2.0%)")
end)

T.test("ranged stat labels, order and rendering", function()
	local ns = load()
	local d = { talents = {
		{ key = "a", name = "A", maxRank = 1, kind = "stat", explain = "x", effects = {
			{ stat = "rangedCrit", op = "flat", perRank = { 3 } }, { stat = "meleeCrit", op = "flat", perRank = { 1 } },
			{ stat = "rangedAp", op = "flat", perRank = { 50 } }, { stat = "ap", op = "flat", perRank = { 20 } },
			{ stat = "spellCrit", op = "flat", perRank = { 1 } }, { stat = "sp", op = "flat", perRank = { 5 } } } },
	} }
	local v = { rangedCrit = 7.5, meleeCrit = 5.4, rangedAp = 412.4, ap = 380, spellCrit = 2, sp = 10 }
	local heads = {}
	for _, l in ipairs(ns.Format.Lines(ns.Calc.Breakdown(v, { a = 1 }, d), { a = 1 }, d)) do
		if l.kind == "stat" then heads[#heads + 1] = l.text end
	end
	T.eq(heads[1], "Attack Power 380 (talents +20)")
	T.eq(heads[2], "Ranged Attack Power 412 (talents +50)")
	T.eq(heads[3], "Spell Power 10 (talents +5)")
	T.eq(heads[4], "Melee Crit 5.4% (talents +1.0%)")
	T.eq(heads[5], "Ranged Crit 7.5% (talents +3.0%)")
	T.eq(heads[6], "Spell Crit 2.0% (talents +1.0%)")
end)

T.test("pet condition text", function()
	local ns = load()
	local d = { talents = {
		{ key = "dk", name = "Demonic Thing", maxRank = 2, kind = "stat", explain = "x",
			effects = { { stat = "sp", op = "perLevel", pet = true, perRank = { 0.5, 1.0 } } } },
		{ key = "cp", name = "Cat Pet", maxRank = 1, kind = "stat", explain = "x",
			effects = { { stat = "dodge", op = "flat", forms = { "cat" }, pet = true, perRank = { 2 } } } },
	} }
	local v = { sp = 100, dodge = 4, level = 25, pet = true }
	local ranks = { dk = 2 }
	local b = ns.Calc.Breakdown(v, ranks, d)
	local lines = {}
	for _, l in ipairs(ns.Format.Lines(b, ranks, d)) do lines[#lines + 1] = l.kind .. "|" .. l.text end
	T.eq(lines[1], "stat|Spell Power 100 (talents +25)")
	T.eq(lines[2], "part|Demonic Thing 2/2: +25 (100% of level)")

	v.pet = false
	b = ns.Calc.Breakdown(v, ranks, d)
	lines = {}
	for _, l in ipairs(ns.Format.Lines(b, ranks, d)) do lines[#lines + 1] = l.kind .. "|" .. l.text end
	T.eq(lines[1], "stat|Spell Power 100")
	T.eq(lines[2], "inactive|Demonic Thing 2/2: +25 with a pet active")
	local st = ns.Format.StatTooltipLines("sp", b, d, ranks)
	T.eq(st[1], "|cff999999With a pet active: +25 (Demonic Thing 2/2)|r")
	local tl = ns.Format.TooltipLines(d.talents[1], 2, b, nil)
	T.eq(tl[2].text, "With a pet active: +25 Spell Power")

	local r1 = { dk = 1 }
	local b1 = ns.Calc.Breakdown(v, r1, d)
	local all = {}
	for _, l in ipairs(ns.Format.TooltipLines(d.talents[1], 1, b1, ns.Calc.NextPoint(v, r1, d, "dk"))) do all[#all + 1] = l.text end
	all = table.concat(all, "\n")
	T.truthy(all:find("Next point (2/2): +13 Spell Power with a pet active", 1, true), all)

	local rc = { cp = 1 }
	b = ns.Calc.Breakdown({ dodge = 4, form = "bear", pet = false }, rc, d)
	lines = {}
	for _, l in ipairs(ns.Format.Lines(b, rc, d)) do lines[#lines + 1] = l.kind .. "|" .. l.text end
	T.eq(lines[2], "inactive|Cat Pet 1/1: +2.0% in Cat Form and with a pet active")
end)

T.test("StatTooltipLines notes talents whose source stat is secret, keeps readable ones", function()
	local ns = load()
	local d = { talents = {
		{ key = "fromInt", name = "From Int", maxRank = 1, kind = "stat",
			effects = { { stat = "ap", op = "fromStat", source = "int", perRank = { 1 } } } },
		{ key = "fromStr", name = "From Str", maxRank = 1, kind = "stat",
			effects = { { stat = "ap", op = "fromStat", source = "str", perRank = { 1 } } } },
		{ key = "unranked", name = "Unranked", maxRank = 1, kind = "stat",
			effects = { { stat = "ap", op = "fromStat", source = "int", perRank = { 1 } } } },
	} }
	local ranks = { fromInt = 1, fromStr = 1 }
	local b = ns.Calc.Breakdown({ str = 50, ap = 300 }, ranks, d)
	local lines = ns.Format.StatTooltipLines("ap", b, d, ranks, { int = true })
	local all = table.concat(lines, "\n")
	T.truthy(all:find("From Str", 1, true), "readable contribution kept")
	T.truthy(all:find("From Int: not shown, Intellect unavailable right now", 1, true), "secret source noted")
	T.eq(all:find("Unranked", 1, true), nil, "unranked talent not noted")
	T.eq(#ns.Format.StatTooltipLines("ap", b, d, ranks), 1, "no note without secretStats")
end)
