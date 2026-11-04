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

-- Independent roster from the live 1.60.1.70755 snapshot.
local liveTrees = {
	Assassination = {
		improvedGouge = { "Improved Gouge", 3 }, remorselessAttacks = { "Remorseless Attacks", 2 },
		malice = { "Malice", 5 }, ruthlessness = { "Ruthlessness", 3 },
		improvedExposeArmor = { "Improved Expose Armor", 2 }, improvedSliceAndDice = { "Improved Slice and Dice", 3 },
		vigor = { "Vigor", 2 }, bloodSplatter = { "Blood Splatter", 1 }, lethality = { "Lethality", 2 },
		vilePoisons = { "Vile Poisons", 5 }, coldBlood = { "Cold Blood", 1 }, improvedPoisons = { "Improved Poisons", 5 },
		relentlessStrikes = { "Relentless Strikes", 5 }, venom = { "Venom", 1 },
		improvedKidneyShot = { "Improved Kidney Shot", 2 }, sealFate = { "Seal Fate", 3 }, mutilate = { "Mutilate", 1 },
	},
	Combat = {
		coupDeGrace = { "Coup de Grace", 3 }, efficientStrikes = { "Efficient Strikes", 2 },
		lightningReflexes = { "Lightning Reflexes", 5 }, puncturingWounds = { "Puncturing Wounds", 3 },
		deflection = { "Deflection", 3 }, precision = { "Precision", 3 }, improvedSprint = { "Improved Sprint", 2 },
		endurance = { "Endurance", 2 }, riposte = { "Riposte", 1 }, composure = { "Composure", 2 },
		improvedKick = { "Improved Kick", 2 }, flawlessExecution = { "Flawless Execution", 1 },
		weaponExpertise = { "Weapon Expertise", 2 }, aggression = { "Aggression", 3 },
		dualWieldSpecialization = { "Dual Wield Specialization", 2 }, bladeFlurry = { "Blade Flurry", 1 },
		hackAndSlash = { "Hack and Slash", 5 }, flashOfSteel = { "Flash of Steel", 5 }, adrenalineRush = { "Adrenaline Rush", 1 },
	},
	Subtlety = {
		setup = { "Setup", 3 }, masterOfDeception = { "Master of Deception", 3 }, opportunity = { "Opportunity", 5 },
		dirtyDeeds = { "Dirty Deeds", 2 }, camouflage = { "Camouflage", 3 }, improvedAmbush = { "Improved Ambush", 3 },
		dirtyTricks = { "Dirty Tricks", 2 }, initiative = { "Initiative", 3 }, premeditation = { "Premeditation", 1 },
		serratedBlades = { "Serrated Blades", 3 }, elusiveness = { "Elusiveness", 2 }, ghostlyStrike = { "Ghostly Strike", 1 },
		quickGetaway = { "Quick Getaway", 2 }, heightenedSenses = { "Heightened Senses", 2 }, preparation = { "Preparation", 1 },
		hemorrhage = { "Hemorrhage", 1 }, bootKnife = { "Boot Knife", 5 }, deathMark = { "Death Mark", 1 },
	},
}

T.test("Rogue live roster matches every key, name, rank and tree", function()
	local _, d = load()
	local byKey, counts = {}, {}
	for _, talent in ipairs(d.talents) do
		T.eq(byKey[talent.key], nil, "unique key " .. talent.key)
		byKey[talent.key] = talent
		local tree = talent.tree or d.tree
		counts[tree] = (counts[tree] or 0) + 1
		T.truthy(liveTrees[tree] and liveTrees[tree][talent.key], "live talent " .. talent.key)
	end
	for tree, entries in pairs(liveTrees) do
		for key, expected in pairs(entries) do
			local talent = byKey[key]
			T.truthy(talent, "present " .. key)
			if talent then
				T.eq(talent.name, expected[1], key .. " name")
				T.eq(talent.maxRank, expected[2], key .. " maxRank")
				T.eq(talent.tree or d.tree, tree, key .. " tree")
			end
		end
	end
	T.eq(counts.Assassination, 17)
	T.eq(counts.Combat, 19)
	T.eq(counts.Subtlety, 18)
	T.eq(#d.talents, 54)
	for _, key in ipairs({ "murder", "improvedDistract", "quietus", "cutthroat", "thousandCuts", "improvedEviscerate", "improvedSinisterStrike" }) do
		T.eq(byKey[key], nil, "removed key " .. key)
	end
end)

T.test("Updated Rogue tooltips describe live ability values without sheet effects", function()
	local ns, d = load()
	local expected = {
		bloodSplatter = { "utility", "6 sec", "9 sec" },
		composure = { "utility", "Poised", "5 per rank" },
		flashOfSteel = { "utility", "Shank", "3 per rank", "0.4 sec per rank" },
		quickGetaway = { "utility", "by 1", "15% per rank", "3 sec" },
		bootKnife = { "conditional", "Shank", "20% chance per rank", "2 Combo Points" },
		deathMark = { "conditional", "12% per Combo Point", "twice", "6 sec", "Attack Power", "crit" },
		coupDeGrace = { "conditional", "7/13/20%", "Eviscerate", "Death Mark", "storage" },
		efficientStrikes = { "utility", "Sinister Strike and Hemorrhage", "3 at rank 1 and 5 at rank 2" },
		relentlessStrikes = { "conditional", "4% chance per rank per Combo Point", "25 Energy" },
		lethality = { "conditional", "10% per rank" },
		sealFate = { "conditional", "33/66/100%" },
		camouflage = { "utility", "5% per rank", "2 sec per rank" },
		opportunity = { "conditional", "4% per rank" },
		dualWieldSpecialization = { "conditional", "25% per rank" },
		flawlessExecution = { "utility", "15" },
		aggression = { "conditional", "Sinister Strike and Eviscerate", "5% per rank" },
		mutilate = { "conditional", "90% weapon damage plus 39.6", "each weapon", "20%", "2 Combo Points" },
		venom = { "conditional", "Shank", "30%", "20%", "6 sec" },
		ghostlyStrike = { "conditional", "15%", "next Ambush or Garrote", "within 7 sec", "not require Stealth" },
		hemorrhage = { "conditional", "15%", "Rupture and Garrote", "15 sec" },
		endurance = { "utility", "30% per rank" },
		setup = { "conditional", "15% chance per rank" },
		initiative = { "conditional", "33/67/100%" },
		premeditation = { "utility", "add to or use", "20 sec" },
	}
	local byKey = {}
	for _, talent in ipairs(d.talents) do byKey[talent.key] = talent end
	for key, spec in pairs(expected) do
		local talent = byKey[key]
		T.truthy(talent, key)
		if talent then
			T.eq(talent.kind, spec[1], key .. " kind")
			T.eq(talent.effects, nil, key .. " is not a sheet stat")
			for i = 2, #spec do
				T.truthy(talent.explain:find(spec[i], 1, true), key .. " explains " .. spec[i])
			end
		end
	end
end)

T.test("Rogue sheet-stat ranks remain unchanged at every rank", function()
	local ns, d = load()
	local specs = {
		{ "malice", "meleeCrit", { 1, 2, 3, 4, 5 } },
		{ "malice", "rangedCrit", { 1, 2, 3, 4, 5 } },
		{ "lightningReflexes", "dodge", { 1, 2, 3, 4, 5 } },
		{ "deflection", "parry", { 2, 4, 6 } },
		{ "precision", "hit", { 1, 2, 3 } },
		{ "hackAndSlash", "meleeCrit", { 1, 2, 3, 4, 5 } },
	}
	for _, spec in ipairs(specs) do
		for rank, value in ipairs(spec[3]) do
			local v = { meleeCrit = 20, rangedCrit = 20, dodge = 10, parry = 10, hit = 5, mainHand = "dagger" }
			local b = ns.Calc.Breakdown(v, { [spec[1]] = rank }, d)
			T.eq(b.talents[spec[1]].contributions[spec[2]], value, spec[1] .. " rank " .. rank)
		end
	end
end)

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
