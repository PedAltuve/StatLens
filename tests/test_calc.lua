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
