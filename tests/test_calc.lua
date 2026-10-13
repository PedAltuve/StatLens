local S = require("wow_stubs")

local function load()
	S.reset()
	local ns = {}
	S.loadAddonFile("Core.lua", ns)
	S.loadAddonFile("Data/Shaman.lua", ns)
	S.loadAddonFile("Calc.lua", ns)
	return ns, ns.Data.SHAMAN
end

local function vals(t)
	local v = { int = 341, stam = 200, ap = 500, sp = 300, meleeCrit = 10, spellCrit = 8, dodge = 6, parry = 5 }
	for k, x in pairs(t or {}) do v[k] = x end
	return v
end

local function part(b, stat, key)
	for _, p in ipairs(b.stats[stat].parts) do if p.key == key then return p end end
end

T.test("pct inversion and fromStat", function()
	local ns, d = load()
	local b = ns.Calc.Breakdown(vals(), { ancestralKnowledge = 5, mentalDexterity = 3, mentalQuickness = 2 }, d)
	T.near(part(b, "int", "ancestralKnowledge").amount, 341 - 341 / 1.1, 1e-9, "AK amount")
	T.near(part(b, "int", "ancestralKnowledge").amount, 31.0, 0.05)
	T.eq(part(b, "ap", "mentalDexterity").amount, 341, "MD 100% of int")
	T.near(part(b, "sp", "mentalQuickness").amount, 102.3, 1e-9, "MQ 30%")
	local ak = b.talents.ancestralKnowledge
	T.eq(ak.rank, 5)
	T.near(ak.contributions.int, 31.0, 0.05)
	T.eq(#ak.chained.ap, 1); T.eq(ak.chained.ap[1].via, "mentalDexterity")
	T.near(ak.chained.ap[1].amount, 31.0, 0.05, "AK chained ap")
	T.near(ak.chained.sp[1].amount, 9.3, 0.05, "AK chained sp")
	T.eq(ak.chained.sp[1].via, "mentalQuickness")
	T.near(b.stats.ap.talentTotal, 341, 1e-9, "chained not double counted")
	T.near(b.stats.int.talentTotal, 31.0, 0.05)
	T.eq(b.stats.int.total, 341)
end)

T.test("flat, pct stam, enables", function()
	local ns, d = load()
	local b = ns.Calc.Breakdown(vals(), { thunderingStrikes = 3, toughness = 5, anticipation = 2, spiritWeapons = 1 }, d)
	T.eq(b.talents.thunderingStrikes.contributions.meleeCrit, 3)
	T.eq(b.talents.thunderingStrikes.contributions.spellCrit, 3)
	T.near(b.talents.toughness.contributions.stam, 200 - 200 / 1.1, 1e-9)
	T.eq(b.talents.anticipation.contributions.dodge, 4)
	T.eq(part(b, "parry", "spiritWeapons").op, "enables")
	T.eq(b.talents.spiritWeapons.contributions.parry, 5, "full current total")
end)

T.test("nil stat skipped; rank 0 and non-stat ignored", function()
	local ns, d = load()
	local v = vals()
	v.ap = nil
	local b = ns.Calc.Breakdown(v, { mentalDexterity = 3, flurry = 5, toughness = 0 }, d)
	T.eq(b.stats.ap, nil, "ap skipped")
	T.eq(b.talents.mentalDexterity == nil or next(b.talents.mentalDexterity.contributions) == nil, true)
	T.eq(b.talents.flurry, nil, "conditional ignored")
	T.eq(b.talents.toughness, nil, "rank 0 ignored")
end)

T.test("NextPoint", function()
	local ns, d = load()
	local v = vals({ int = 341 })
	local ranks = { ancestralKnowledge = 2, mentalDexterity = 3, mentalQuickness = 0 }
	local n = ns.Calc.NextPoint(v, ranks, d, "ancestralKnowledge")
	T.eq(n.rank, 2); T.eq(n.nextRank, 3)
	local base = 341 / 1.04
	T.near(n.deltas.int, base * 0.02, 1e-9, "AK delta")
	T.near(n.deltas.ap, base * 0.02 * 1.0, 1e-9, "chained into ap delta")
	T.eq(n.chained.ap[1].via, "mentalDexterity")
	T.near(n.chained.ap[1].amount, base * 0.02, 1e-9)

	local m = ns.Calc.NextPoint(v, { mentalDexterity = 1 }, d, "mentalDexterity")
	T.near(m.deltas.ap, 341 * 0.33, 1e-9, "MD 0.33->0.66")

	local f = ns.Calc.NextPoint(v, { anticipation = 1 }, d, "anticipation")
	T.eq(f.deltas.dodge, 2)

	T.eq(ns.Calc.NextPoint(v, { ancestralKnowledge = 5 }, d, "ancestralKnowledge"), nil, "maxed")
	T.eq(ns.Calc.NextPoint(v, {}, d, "flurry"), nil, "conditional")
	T.eq(ns.Calc.NextPoint(v, {}, d, "nope"), nil, "unknown")
	T.eq(ns.Calc.NextPoint(v, {}, d, "spiritWeapons").deltas.parry, "enables")
end)

-- Form-gated effects, perLevel, heal (synthetic class data)
local function synth(talents) return { talents = talents } end
local function T1(key, effects, maxRank)
	return { key = key, name = key, maxRank = maxRank or 3, kind = "stat", effects = effects, explain = "x" }
end

T.test("pct with forms: active vs inactive", function()
	local ns = load()
	local d = synth({ T1("fp", { { stat = "agi", op = "pct", forms = { "cat" }, perRank = { 0.03, 0.06, 0.09 } } }) })
	local b = ns.Calc.Breakdown({ agi = 200, form = "cat" }, { fp = 3 }, d)
	T.near(b.stats.agi.parts[1].amount, 200 - 200 / 1.09, 1e-9, "active inverted")
	T.near(b.stats.agi.talentTotal, 200 - 200 / 1.09, 1e-9)
	T.eq(b.stats.agi.parts[1].inactive, nil); T.eq(b.stats.agi.parts[1].forms[1], "cat")

	b = ns.Calc.Breakdown({ agi = 200, form = "bear" }, { fp = 3 }, d)
	local p = b.stats.agi.parts[1]
	T.eq(p.inactive, true); T.near(p.amount, 18, 1e-9, "total x p, not inverted")
	T.eq(p.forms[1], "cat")
	T.eq(b.stats.agi.talentTotal, 0, "inactive not in talentTotal")
	T.eq(b.talents.fp.contributions.agi, nil)
	T.near(b.talents.fp.inactive.agi, 18, 1e-9)
end)

T.test("shared pct base only over active effects", function()
	local ns = load()
	local d = synth({
		T1("a", { { stat = "stam", op = "pct", perRank = { 0.05, 0.10, 0.15 } } }),
		T1("b", { { stat = "stam", op = "pct", forms = { "cat" }, perRank = { 0.1, 0.2, 0.3 } } }),
	})
	local b = ns.Calc.Breakdown({ stam = 105, form = "bear" }, { a = 1, b = 1 }, d)
	T.near(b.talents.a.contributions.stam, 5, 1e-9, "base 105/1.05")
	T.near(b.talents.b.inactive.stam, 10.5, 1e-9)
	T.near(b.stats.stam.talentTotal, 5, 1e-9)
end)

T.test("perLevel active and inactive", function()
	local ns = load()
	local d = synth({ T1("pl", { { stat = "ap", op = "perLevel", forms = { "cat" }, perRank = { 0.5, 1.0, 1.5 } } }) })
	local b = ns.Calc.Breakdown({ ap = 100, level = 25, form = "cat" }, { pl = 3 }, d)
	T.near(b.stats.ap.parts[1].amount, 37.5, 1e-9); T.near(b.stats.ap.talentTotal, 37.5, 1e-9)
	T.eq(b.stats.ap.parts[1].op, "perLevel")

	b = ns.Calc.Breakdown({ ap = 100, level = 25 }, { pl = 3 }, d)
	T.eq(b.stats.ap.parts[1].inactive, true); T.near(b.stats.ap.parts[1].amount, 37.5, 1e-9)
	T.eq(b.stats.ap.talentTotal, 0)

	b = ns.Calc.Breakdown({ ap = 100, form = "cat" }, { pl = 3 }, d)
	T.eq(b.stats.ap, nil, "no level -> skipped")
end)

T.test("flat with forms", function()
	local ns = load()
	local d = synth({ T1("fc", { { stat = "meleeCrit", op = "flat", forms = { "cat" }, perRank = { 1, 2, 3 } } }) })
	local b = ns.Calc.Breakdown({ meleeCrit = 10, form = "cat" }, { fc = 2 }, d)
	T.eq(b.talents.fc.contributions.meleeCrit, 2); T.eq(b.stats.meleeCrit.talentTotal, 2)
	b = ns.Calc.Breakdown({ meleeCrit = 10, form = "bear" }, { fc = 2 }, d)
	T.eq(b.talents.fc.inactive.meleeCrit, 2); T.eq(b.stats.meleeCrit.talentTotal, 0)
	T.eq(b.talents.fc.contributions.meleeCrit, nil)
end)

T.test("inactive fromStat and inactive pct do not chain", function()
	local ns = load()
	local d = synth({
		T1("pct", { { stat = "int", op = "pct", perRank = { 0.1, 0.2, 0.3 } } }),
		T1("src", { { stat = "ap", op = "fromStat", source = "int", forms = { "cat" }, perRank = { 0.5, 1, 1.5 } } }),
	})
	local b = ns.Calc.Breakdown({ int = 110, ap = 50, form = "cat" }, { pct = 1, src = 2 }, d)
	T.eq(#b.talents.pct.chained.ap, 1, "active chain")
	b = ns.Calc.Breakdown({ int = 110, ap = 50, form = "bear" }, { pct = 1, src = 2 }, d)
	T.eq(b.talents.pct.chained.ap, nil, "inactive fromStat: no chain")
	T.eq(b.talents.src.inactive.ap, 110, "hypothetical ratio x source")
	T.eq(b.stats.ap.talentTotal, 0)

	d = synth({
		T1("pct", { { stat = "int", op = "pct", forms = { "cat" }, perRank = { 0.1, 0.2, 0.3 } } }),
		T1("src", { { stat = "ap", op = "fromStat", source = "int", perRank = { 0.5, 1, 1.5 } } }),
	})
	b = ns.Calc.Breakdown({ int = 110, ap = 50, form = "bear" }, { pct = 1, src = 2 }, d)
	T.eq(b.talents.pct.chained.ap, nil, "inactive pct: no chain")
end)

T.test("NextPoint inactiveDeltas and perLevel", function()
	local ns = load()
	local d = synth({
		T1("fp", { { stat = "agi", op = "pct", forms = { "cat" }, perRank = { 0.03, 0.06, 0.09 } } }),
		T1("pl", { { stat = "ap", op = "perLevel", perRank = { 0.5, 1.0, 1.5 } } }),
		T1("fl", { { stat = "meleeCrit", op = "flat", forms = { "cat" }, perRank = { 1, 2, 3 } } }),
	})
	local v = { agi = 200, ap = 100, meleeCrit = 10, level = 25, form = "bear" }
	local n = ns.Calc.NextPoint(v, { fp = 1 }, d, "fp")
	T.near(n.inactiveDeltas.agi, 6, 1e-9, "total x (p2-p1)")
	T.eq(n.deltas.agi, nil); T.eq(n.inactiveForms.agi[1], "cat")
	v.form = "cat"
	n = ns.Calc.NextPoint(v, { fp = 1 }, d, "fp")
	T.near(n.deltas.agi, 200 / 1.03 * 0.03, 1e-9, "active as before"); T.eq(n.inactiveDeltas.agi, nil)
	n = ns.Calc.NextPoint(v, { pl = 1 }, d, "pl")
	T.near(n.deltas.ap, 12.5, 1e-9, "perLevel delta x level")
	v.form = nil
	n = ns.Calc.NextPoint(v, { fl = 0 }, d, "fl")
	T.eq(n.inactiveDeltas.meleeCrit, 1); T.eq(n.deltas.meleeCrit, nil)
end)

T.test("Mental Quickness feeds heal and AK chains into it", function()
	local ns, d = load()
	local b = ns.Calc.Breakdown(vals({ heal = 250 }), { ancestralKnowledge = 5, mentalQuickness = 2 }, d)
	T.near(part(b, "heal", "mentalQuickness").amount, 102.3, 1e-9)
	T.near(part(b, "sp", "mentalQuickness").amount, 102.3, 1e-9)
	local found
	for _, link in ipairs(b.talents.ancestralKnowledge.chained.heal or {}) do
		if link.via == "mentalQuickness" then found = link.amount end
	end
	T.near(found, 9.3, 0.05, "AK chained heal")
	b = ns.Calc.Breakdown(vals(), { mentalQuickness = 2 }, d)
	T.eq(b.stats.heal, nil, "heal missing -> skipped")
end)
