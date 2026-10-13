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
