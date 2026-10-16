local S = require("wow_stubs")

local function load()
	S.reset()
	local ns = {}
	for _, f in ipairs({ "Core.lua", "Data/Priest.lua", "Calc.lua", "Format.lua" }) do S.loadAddonFile(f, ns) end
	return ns, ns.Data.PRIEST
end

local function entry(d, key)
	for _, t in ipairs(d.talents) do if t.key == key then return t end end
end

T.test("Mental Strength inverts Intellect", function()
	local ns, d = load()
	local b = ns.Calc.Breakdown({ int = 110 }, { mentalStrength = 5 }, d)
	T.near(b.talents.mentalStrength.contributions.int, 10, 1e-9, "110 - 110/1.1")
end)

T.test("Spiritual Guidance: heal and sp from Spirit, inferred marker", function()
	local ns, d = load()
	local ranks = { spiritualGuidance = 5 }
	local v = { spirit = 200, heal = 400, sp = 300 }
	local b = ns.Calc.Breakdown(v, ranks, d)
	T.near(b.talents.spiritualGuidance.contributions.heal, 50, 1e-9)
	T.near(b.talents.spiritualGuidance.contributions.sp, 16, 1e-9)
	T.eq(entry(d, "spiritualGuidance").inferred.rank, true)
	local texts = {}
	for i, l in ipairs(ns.Format.Lines(b, ranks, d)) do texts[i] = l.text end
	local all = table.concat(texts, "\n")
	T.truthy(all:find("Spiritual Guidance* 5/5: +16 (8% of Spirit)", 1, true), all)
	T.truthy(all:find("Spiritual Guidance* 5/5: +50 (25% of Spirit)", 1, true), all)
	T.eq(texts[#texts], "* rank value inferred, verify in game")
end)

T.test("Holy Specialization is conditional with no stat effect", function()
	local ns, d = load()
	local hs = entry(d, "holySpecialization")
	T.eq(hs.kind, "conditional"); T.eq(hs.effects, nil); T.eq(hs.tree, "Holy")
	local ranks = { holySpecialization = 3 }
	local b = ns.Calc.Breakdown({ spellCrit = 5 }, ranks, d)
	T.eq(b.talents.holySpecialization, nil, "no contribution")
	local lines = ns.Format.Lines(b, ranks, d)
	T.eq(lines[1].text, "Conditional talents")
	T.eq(lines[2].text, "Holy Specialization 3/5: " .. hs.explain)
	local tl = ns.Format.TooltipLines(hs, 3, b, nil)
	T.eq(tl[2].text, "Not shown on character sheet: " .. hs.explain)
end)
