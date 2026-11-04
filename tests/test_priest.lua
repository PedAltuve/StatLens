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

for rank, percent in ipairs({ 1, 3, 5, 6, 8 }) do
	T.test("Spiritual Guidance live Spirit scaling rank " .. rank, function()
		local ns, d = load()
		local ranks = { spiritualGuidance = rank }
		local b = ns.Calc.Breakdown({ spirit = 200, heal = 400, sp = 300 }, ranks, d)
		T.near(b.talents.spiritualGuidance.contributions.heal, rank * 10, 1e-9)
		T.near(b.talents.spiritualGuidance.contributions.sp, percent * 2, 1e-9)
		local texts = {}
		for i, l in ipairs(ns.Format.Lines(b, ranks, d)) do texts[i] = l.text end
		local all = table.concat(texts, "\n")
		T.truthy(all:find(("Spiritual Guidance %d/5: +%d (%d%% of Spirit)"):format(rank, percent * 2, percent), 1, true), all)
		T.truthy(all:find(("Spiritual Guidance %d/5: +%d (%d%% of Spirit)"):format(rank, rank * 10, rank * 5), 1, true), all)
		T.eq(all:find("inferred", 1, true), nil)
	end)
end

T.test("Spiritual Guidance has verified ranks, not inferred values", function()
	local _, d = load()
	local talent = entry(d, "spiritualGuidance")
	T.eq(talent.maxRank, 5)
	T.eq(talent.tree, "Holy")
	T.eq(talent.inferred, nil)
	T.eq(talent.explain:find("inferred", 1, true), nil)
end)

T.test("Holy Binding replaces Binding Heal with conditional self-healing", function()
	local ns, d = load()
	T.eq(entry(d, "bindingHeal"), nil)
	for _, talent in ipairs(d.talents) do T.truthy(talent.name ~= "Binding Heal") end
	local hb = entry(d, "holyBinding")
	T.truthy(hb, "Holy Binding exists")
	T.eq(hb.name, "Holy Binding")
	T.eq(hb.maxRank, 1)
	T.eq(hb.tree, "Holy")
	T.eq(hb.kind, "conditional")
	T.eq(hb.effects, nil)
	T.eq(hb.explain, "Flash Heal on another target also heals you for 50% as much, generating no threat.")
	local ranks = { holyBinding = 1 }
	local b = ns.Calc.Breakdown({ heal = 400 }, ranks, d)
	T.eq(b.talents.holyBinding, nil)
	local lines = ns.Format.Lines(b, ranks, d)
	T.eq(lines[2].text, "Holy Binding 1/1: " .. hb.explain)
end)

T.test("Priest explanations match live triggers and rank chances", function()
	local _, d = load()
	local expected = {
		renewedHope = "Flash Heal, Lesser Heal, Heal, Greater Heal and Penance gain 2% critical chance per rank on targets with Weakened Soul and shorten its remaining duration by 1 sec per rank.",
		blessedRecovery = "After a melee or ranged crit, or a single attack dealing more than 30% of your maximum health, heals 8% at rank 1 (25% at rank 3) of the damage over 6 sec; refreshes carry over remaining healing.",
		prayerOfMending = "Grants Prayer of Mending: heals when the target takes damage or receives non-periodic healing, then jumps to a party or raid member within 20 yards, up to 5 times; lasts 30 sec after each jump.",
		spiritTap = "20% chance per rank after killing a non-trivial target or when an enemy with your Vampiric Embrace dies to double your Spirit for 15 sec, with 50% of mana regeneration continuing while casting.",
		shadowWeaving = "Your Shadow damage spells have a 33/67/100% chance by rank to increase the Shadow damage the target takes from you by 2% for 15 sec, stacking up to 5 times.",
		silence = "Grants Silence: silences the target for 5 sec and interrupts its spellcasts for 3 sec.",
	}
	for key, explain in pairs(expected) do T.eq(entry(d, key).explain, explain, key) end
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
