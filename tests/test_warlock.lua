local S = require("wow_stubs")

local function load()
	S.reset()
	local ns = {}
	for _, f in ipairs({ "Core.lua", "Data/Warlock.lua", "Calc.lua", "Format.lua" }) do S.loadAddonFile(f, ns) end
	return ns, ns.Data.WARLOCK
end

local function texts(ns, d, v, ranks)
	local out = {}
	for i, l in ipairs(ns.Format.Lines(ns.Calc.Breakdown(v, ranks, d), ranks, d)) do out[i] = l.kind .. "|" .. l.text end
	return out
end

T.test("Suppression gives hit and spell hit", function()
	local ns, d = load()
	local ranks = { suppression = 3 }
	local v = { hit = 4, spellHit = 5 }
	local b = ns.Calc.Breakdown(v, ranks, d)
	T.eq(b.talents.suppression.contributions.hit, 3)
	T.eq(b.talents.suppression.contributions.spellHit, 3)
	local got = texts(ns, d, v, ranks)
	T.eq(got[1], "stat|Melee Hit 4.0% (talents +3.0%)")
	T.eq(got[2], "part|Suppression 3/5: +3.0%")
	T.eq(got[3], "stat|Spell Hit 5.0% (talents +3.0%)")
	T.eq(got[4], "part|Suppression 3/5: +3.0%")
end)

T.test("Demonic Embrace inverts stamina", function()
	local ns, d = load()
	local b = ns.Calc.Breakdown({ stam = 115 }, { demonicEmbrace = 5 }, d)
	T.near(b.talents.demonicEmbrace.contributions.stam, 15, 1e-9)
end)

T.test("Demonic Knowledge: active with a pet, grey without", function()
	local ns, d = load()
	local ranks = { demonicKnowledge = 3 }
	local v = { sp = 200, level = 30, pet = true }
	local b = ns.Calc.Breakdown(v, ranks, d)
	T.near(b.talents.demonicKnowledge.contributions.sp, 30, 1e-9)
	local got = texts(ns, d, v, ranks)
	T.eq(got[1], "stat|Spell Power 200 (talents +30)")
	T.eq(got[2], "part|Demonic Knowledge* 3/3: +30 (100% of level)")
	T.eq(got[#got], "note|* rank value inferred, verify in game")

	v.pet = false
	b = ns.Calc.Breakdown(v, ranks, d)
	T.eq(b.talents.demonicKnowledge.contributions.sp, nil)
	T.near(b.talents.demonicKnowledge.inactive.sp, 30, 1e-9)
	got = texts(ns, d, v, ranks)
	T.eq(got[1], "stat|Spell Power 200")
	T.eq(got[2], "inactive|Demonic Knowledge* 3/3: +30 with a pet active")
end)

T.test("Fel Vitality is explained, not measured", function()
	local ns, d = load()
	local t
	for _, x in ipairs(d.talents) do if x.key == "felVitality" then t = x end end
	T.eq(t.kind, "conditional")
	T.eq(t.effects, nil)
	T.truthy(t.explain:find("not tracked"), "explain says mana is not tracked")
	local b = ns.Calc.Breakdown({ int = 100 }, { felVitality = 3 }, d)
	T.eq(b.talents.felVitality, nil)
end)
