local S = require("wow_stubs")

local function load()
	S.reset()
	local ns = {}
	for _, f in ipairs({ "Core.lua", "Data/Mage.lua", "Calc.lua", "Format.lua" }) do S.loadAddonFile(f, ns) end
	return ns, ns.Data.MAGE
end

local function texts(ns, d, v, ranks)
	local out = {}
	for i, l in ipairs(ns.Format.Lines(ns.Calc.Breakdown(v, ranks, d), ranks, d)) do out[i] = l.text end
	return out
end

T.test("Arcane Mind feeds Arcane Resilience armor", function()
	local ns, d = load()
	local ranks = { arcaneMind = 5, arcaneResilience = 2 }
	local v = { int = 110, armor = 300 }
	local b = ns.Calc.Breakdown(v, ranks, d)
	T.near(b.talents.arcaneMind.contributions.int, 10, 1e-9)
	T.near(b.talents.arcaneResilience.contributions.armor, 55, 1e-9)
	local got = texts(ns, d, v, ranks)
	T.eq(got[1], "Intellect 110 (talents +10)")
	T.eq(got[2], "Arcane Mind 5/5: +10")
	T.eq(got[3], "Armor 300 (talents +55)")
	T.eq(got[4], "Arcane Resilience 2/3: +55 (50% of Intellect)")
	T.eq(got[5], "incl. +5 from Arcane Mind")
end)

-- LIVE build 1.60.1.70755: names and ranks, grouped by in-game tree.
local liveTrees = {
	Arcane = {
		["Wand Specialization"] = 2, ["Improved Channeling"] = 5, ["Arcane Resilience"] = 3,
		["Arcane Subtlety"] = 2, ["Magic Absorption"] = 2, ["Arcane Concentration"] = 5,
		["Missile Barrage"] = 2, ["Arcane Geometry"] = 2, ["Arcane Impact"] = 3,
		["Arcane Blast"] = 1, ["Arcane Shielding"] = 2, ["Improved Counterspell"] = 2,
		["Arcane Meditation"] = 3, ["Arcane Wrath"] = 1, ["Presence of Mind"] = 1,
		["Arcane Mind"] = 5, ["Arcane Instability"] = 3, ["Arcane Power"] = 1,
	},
	Fire = {
		["Incineration"] = 5, ["Accelerant"] = 5, ["Ignite"] = 5, ["Flame Throwing"] = 2,
		["Impact"] = 3, ["Burning Soul"] = 3, ["Improved Flamestrike"] = 3, ["Pyroblast"] = 1,
		["Improved Fire Blast"] = 2, ["Improved Scorch"] = 3, ["Improved Fire Ward"] = 2,
		["Heating Up"] = 1, ["Master of Elements"] = 3, ["Critical Mass"] = 3,
		["Blast Wave"] = 1, ["Fire Power"] = 3, ["Combustion"] = 1,
	},
	Frost = {
		["Frost Warding"] = 2, ["Improved Frostbolt"] = 5, ["Precision"] = 3,
		["Ice Shards"] = 5, ["Frostbite"] = 3, ["Improved Frost Nova"] = 2, ["Permafrost"] = 3,
		["Frost Channeling"] = 3, ["Improved Blizzard"] = 3, ["Ice Lance"] = 1,
		["Arctic Reach"] = 2, ["Ice Block"] = 1, ["Shatter"] = 3, ["Improved Cone of Cold"] = 3,
		["Cold Snap"] = 1, ["Fingers of Frost"] = 2, ["Winter's Chill"] = 5, ["Ice Barrier"] = 1,
	},
}

T.test("Mage names, ranks and trees match LIVE 70755", function()
	local _, d = load()
	local found, counts = {}, { Arcane = 0, Fire = 0, Frost = 0 }
	for _, talent in ipairs(d.talents) do
		local tree = talent.tree or d.tree
		T.eq(found[talent.name], nil, "unique name " .. talent.name)
		found[talent.name] = true
		counts[tree] = counts[tree] + 1
		T.eq(talent.maxRank, liveTrees[tree][talent.name], tree .. ": " .. talent.name)
	end
	for _, talents in pairs(liveTrees) do
		for name in pairs(talents) do T.truthy(found[name], "LIVE talent present: " .. name) end
	end
	T.eq(counts.Arcane, 18)
	T.eq(counts.Fire, 17)
	T.eq(counts.Frost, 18)
	T.eq(#d.talents, 53)
end)

T.test("Removed Mage keys are absent and replacement keys match names", function()
	local _, d = load()
	local byKey = {}
	for _, talent in ipairs(d.talents) do byKey[talent.key] = talent end
	for _, key in ipairs({ "arcaneFocus", "improvedFireball", "piercingIce", "elementalPrecision" }) do
		T.eq(byKey[key], nil, "removed key " .. key)
	end
	T.truthy(byKey.accelerant, "accelerant key")
	T.truthy(byKey.precision, "precision key")
	if byKey.accelerant then
		T.eq(byKey.accelerant.name, "Accelerant")
		T.eq(byKey.accelerant.kind, "utility")
		T.eq(byKey.accelerant.effects, nil)
	end
	if byKey.precision then
		T.eq(byKey.precision.name, "Precision")
		T.eq(byKey.precision.kind, "stat")
	end
end)

T.test("Arcane Resilience models every LIVE armor rank", function()
	local ns, d = load()
	for rank, fraction in ipairs({ 0.25, 0.50, 0.75 }) do
		local b = ns.Calc.Breakdown({ int = 100, armor = 300 }, { arcaneResilience = rank }, d)
		T.near(b.talents.arcaneResilience.contributions.armor, 100 * fraction, 1e-9)
	end
	local ranks = { arcaneMind = 5, arcaneResilience = 3 }
	local b = ns.Calc.Breakdown({ int = 110, armor = 300 }, ranks, d)
	T.near(b.talents.arcaneResilience.contributions.armor, 82.5, 1e-9)
	local got = texts(ns, d, { int = 110, armor = 300 }, ranks)
	T.eq(got[4], "Arcane Resilience 3/3: +83 (75% of Intellect)")
end)

T.test("Precision adds generic spell hit at every rank, not crit or melee hit", function()
	local ns, d = load()
	for rank = 1, 3 do
		local b = ns.Calc.Breakdown({ spellHit = 10, meleeHit = 5, spellCrit = 8 }, { precision = rank }, d)
		local talent = b.talents.precision
		T.truthy(talent, "Precision contributes at rank " .. rank)
		if talent then
			T.eq(talent.contributions.spellHit, 2 * rank)
			T.eq(talent.contributions.meleeHit, nil)
			T.eq(talent.contributions.spellCrit, nil)
		end
	end
	local b = ns.Calc.Breakdown({ spellHit = 10 }, { precision = 0 }, d)
	T.eq(b.talents.precision, nil)
end)

T.test("Spell-specific Mage crit remains conditional at new max ranks", function()
	local ns, d = load()
	local b = ns.Calc.Breakdown({ spellCrit = 8 }, { incineration = 5, criticalMass = 3 }, d)
	T.eq(b.talents.incineration, nil)
	T.eq(b.talents.criticalMass, nil)
end)

T.test("Mage explanations describe LIVE 70755 effects", function()
	local _, d = load()
	local byKey = {}
	for _, talent in ipairs(d.talents) do byKey[talent.key] = talent end
	local fragments = {
		arcaneResilience = { "25% / 50% / 75%" },
		precision = { "all spells", "2% per rank" },
		accelerant = { "Fireball, Frostfire Bolt and Arcane Wrath", "0.1 sec per rank" },
		arcaneBlast = { "12%", "100%", "18 sec", "4 times" },
		missileBarrage = { "Arcane Wrath, Fireball, Frostbolt and Frostfire Bolt" },
		magicAbsorption = { "once per sec" },
		burningSoul = { "23/47/70%" },
		improvedScorch = { "33/67/100%" },
		heatingUp = { "Non-periodic", "20 sec", "additional stack" },
		firePower = { "mixed-school" },
		combustion = { "non-periodic" },
		frostWarding = { "negate", "Ice Barrier and Frost Ward", "absorption by 10% per rank" },
		iceLance = { "300%" },
		arcticReach = { "Ice Lance" },
		fingersOfFrost = { "15 sec" },
		wintersChill = { "Fingers of Frost", "20%", "7%", "5 times" },
		iceBarrier = { "448", "10% of Frost Spell Power", "15%", "1 min", "additional 5%" },
	}
	for key, parts in pairs(fragments) do
		for _, part in ipairs(parts) do
			T.truthy(byKey[key] and byKey[key].explain:find(part, 1, true), key .. " explains " .. part)
		end
	end
end)

T.test("Arcane Instability gives melee and spell crit", function()
	local ns, d = load()
	local b = ns.Calc.Breakdown({ meleeCrit = 5, spellCrit = 8 }, { arcaneInstability = 3 }, d)
	T.eq(b.talents.arcaneInstability.contributions.meleeCrit, 3)
	T.eq(b.talents.arcaneInstability.contributions.spellCrit, 3)
end)

T.test("Magic Absorption is explained, not measured", function()
	local ns, d = load()
	local t
	for _, x in ipairs(d.talents) do if x.key == "magicAbsorption" then t = x end end
	T.eq(t.kind, "conditional")
	T.eq(t.effects, nil)
	T.truthy(t.explain:find("resistances"), "explain mentions resistances")
	local b = ns.Calc.Breakdown({ int = 100 }, { magicAbsorption = 2 }, d)
	T.eq(b.talents.magicAbsorption, nil)
end)

T.test("no explanation names Frost Blast after the 4 November hotfix", function()
	local _, d = load()
	for _, t in ipairs(d.talents) do
		T.eq(t.explain:find("Frost Blast", 1, true), nil, t.key .. " explain names Frost Blast")
	end
end)
