local S = require("wow_stubs")

local function load()
	S.reset()
	local ns = {}
	for _, f in ipairs({ "Core.lua", "Data/Paladin.lua", "Calc.lua", "Format.lua" }) do S.loadAddonFile(f, ns) end
	return ns, ns.Data.PALADIN
end

local function texts(ns, d, v, ranks)
	local out = {}
	for i, l in ipairs(ns.Format.Lines(ns.Calc.Breakdown(v, ranks, d), ranks, d)) do out[i] = l.text end
	return out
end

T.test("Divine Intellect feeds Champion of the Light", function()
	local ns, d = load()
	local ranks = { divineIntellect = 5, championOfTheLight = 5 }
	local v = { int = 110, sp = 100 }
	local b = ns.Calc.Breakdown(v, ranks, d)
	T.near(b.talents.divineIntellect.contributions.int, 10, 1e-9)
	T.near(b.talents.championOfTheLight.contributions.sp, 66, 1e-9)
	local got = texts(ns, d, v, ranks)
	T.eq(got[1], "Intellect 110 (talents +10)")
	T.eq(got[2], "Divine Intellect 5/5: +10")
	T.eq(got[3], "Spell Power 100 (talents +66)")
	T.eq(got[4], "Champion of the Light 5/5: +66 (60% of Intellect)")
	T.eq(got[5], "incl. +6 from Divine Intellect")
end)

-- Complete live roster: catches removals, additions, rank changes and tree moves.
local live = {
	Holy = {
		spiritualFocus = { "Spiritual Focus", 5 }, divineStrength = { "Divine Strength", 5 },
		healingLight = { "Healing Light", 3 }, reverence = { "Reverence", 2 },
		improvedSeals = { "Improved Seals", 5 }, purifyingPower = { "Purifying Power", 2 },
		divineFavor = { "Divine Favor", 1 }, illumination = { "Illumination", 5 },
		holyConduit = { "Holy Conduit", 2 }, divinePrecision = { "Divine Precision", 2 },
		infusionOfLight = { "Infusion of Light", 2 }, oathOfLight = { "Oath of Light", 1 },
		consecratedGround = { "Consecrated Ground", 2 }, holyShock = { "Holy Shock", 1 },
		boundlessLight = { "Boundless Light", 2 }, holyPower = { "Holy Power", 5 },
		lightsVigil = { "Light's Vigil", 1 },
	},
	Protection = {
		divineIntellect = { "Divine Intellect", 5 }, redoubt = { "Redoubt", 5 },
		precision = { "Precision", 3 }, guardiansFavor = { "Guardian's Favor", 2 },
		sacredDuty = { "Sacred Duty", 2 }, templarsBulwark = { "Templar's Bulwark", 1 },
		improvedHammerOfJustice = { "Improved Hammer of Justice", 3 }, shieldSpecialization = { "Shield Specialization", 2 },
		toughness = { "Toughness", 5 }, swiftJudgement = { "Swift Judgement", 1 },
		improvedRighteousFury = { "Improved Righteous Fury", 3 }, anticipation = { "Anticipation", 5 },
		stoicism = { "Stoicism", 2 }, holyShield = { "Holy Shield", 1 },
		reckoning = { "Reckoning", 5 }, ironCreed = { "Iron Creed", 3 }, shieldsworn = { "Shieldsworn", 1 },
	},
	Retribution = {
		deflection = { "Deflection", 5 }, benediction = { "Benediction", 5 },
		improvedJudgement = { "Improved Judgement", 2 }, conviction = { "Conviction", 3 },
		sanctifiedJudgement = { "Sanctified Judgement", 3 }, vindication = { "Vindication", 3 },
		unyieldingFaith = { "Unyielding Faith", 2 }, sealOfCommand = { "Seal of Command", 1 },
		pursuitOfJustice = { "Pursuit of Justice", 2 }, eyeForAnEye = { "Eye for an Eye", 2 },
		sacredArbiter = { "Sacred Arbiter", 1 }, twoHandedWeaponSpecialization = { "Two-Handed Weapon Specialization", 3 },
		turnEvil = { "Turn Evil", 2 }, repentance = { "Repentance", 1 }, vengeance = { "Vengeance", 3 },
		championOfTheLight = { "Champion of the Light", 5 }, unsealedWrath = { "Unsealed Wrath", 1 },
	},
}

local function sortedKeys(t)
	local keys = {}
	for k in pairs(t) do keys[#keys + 1] = k end
	table.sort(keys)
	return keys
end

for _, tree in ipairs(sortedKeys(live)) do
	local roster = live[tree]
	for _, key in ipairs(sortedKeys(roster)) do
		local expected = roster[key]
		local tree, key, expected = tree, key, expected
		T.test("Paladin live roster: " .. expected[1], function()
			local _, d = load()
			local found
			for _, talent in ipairs(d.talents) do
				if talent.key == key then found = talent end
			end
			T.eq(found ~= nil, true)
			if not found then return end
			T.eq(found.name, expected[1])
			T.eq(found.maxRank, expected[2])
			T.eq(found.tree or d.tree, tree)
		end)
	end
end

for _, key in ipairs({ "voiceOfTruth", "improvedSealOfFury", "oneHandedWeaponSpecialization", "instrumentOfLaw", "twistOfLight" }) do
	local key = key
	T.test("Removed Paladin talent: " .. key, function()
		local _, d = load()
		for _, talent in ipairs(d.talents) do T.eq(talent.key == key, false) end
	end)
end

T.test("Paladin has exactly 17 talents per tree", function()
	local _, d = load()
	local counts = {}
	for _, talent in ipairs(d.talents) do
		local tree = talent.tree or d.tree
		counts[tree] = (counts[tree] or 0) + 1
	end
	T.eq(#d.talents, 51)
	for tree in pairs(live) do T.eq(counts[tree], 17) end
end)

for rank = 1, 5 do
	local rank = rank
	T.test("Champion of the Light live rank " .. rank, function()
		local ns, d = load()
		local b = ns.Calc.Breakdown({ int = 100, sp = 100 }, { championOfTheLight = rank }, d)
		T.near(b.talents.championOfTheLight.contributions.sp, rank * 12, 1e-9)
	end)
end

for rank = 1, 3 do
	local rank = rank
	T.test("Conviction grants all crit at live rank " .. rank, function()
		local ns, d = load()
		local b = ns.Calc.Breakdown({ meleeCrit = 10, spellCrit = 10 }, { conviction = rank }, d)
		T.eq(b.talents.conviction.contributions.meleeCrit, rank * 2)
		T.eq(b.talents.conviction.contributions.spellCrit, rank * 2)
	end)
end

T.test("Conditional Paladin bonuses never leak into sheet stats", function()
	local ns, d = load()
	local keys = { "redoubt", "divinePrecision", "shieldSpecialization", "holyPower", "sacredDuty",
		"oathOfLight", "boundlessLight", "stoicism", "shieldsworn", "turnEvil", "unsealedWrath" }
	local ranks = {}
	for _, key in ipairs(keys) do ranks[key] = 1 end
	local b = ns.Calc.Breakdown({ stam = 100, block = 5, spellHit = 5, spellCrit = 5 }, ranks, d)
	for _, key in ipairs(keys) do T.eq(b.talents[key], nil) end
	for _, talent in ipairs(d.talents) do
		for _, key in ipairs(keys) do
			if talent.key == key then
				T.eq(talent.kind == "stat", false)
				T.eq(talent.effects, nil)
			end
		end
	end
end)

T.test("Toughness inferred marker renders", function()
	local ns, d = load()
	local got = texts(ns, d, { armor = 1100 }, { toughness = 5 })
	T.eq(got[1], "Armor 1100 (talents +100)")
	T.eq(got[2], "Toughness* 5/5: +100")
	T.eq(got[#got], "* rank value inferred, verify in game")
end)

T.test("Precision gives hit and spell hit", function()
	local ns, d = load()
	local b = ns.Calc.Breakdown({ hit = 4, spellHit = 5 }, { precision = 3 }, d)
	T.eq(b.talents.precision.contributions.hit, 3); T.eq(b.talents.precision.contributions.spellHit, 3)
	T.eq(texts(ns, d, { hit = 4, spellHit = 5 }, { precision = 3 })[1], "Melee Hit 4.0% (talents +3.0%)")
end)

T.test("Sacred Duty does not grant Stamina; Anticipation mirrors Warrior", function()
	local ns, d = load()
	local b = ns.Calc.Breakdown({ stam = 208, defense = 300, dodge = 5, parry = 5, block = 5 }, { sacredDuty = 2, anticipation = 5 }, d)
	T.eq(b.talents.sacredDuty, nil)
	T.eq(b.stats.stam, nil)
	T.eq(b.talents.anticipation.contributions.defense, 20)
	T.near(b.talents.anticipation.contributions.block, 0.8, 1e-9)
end)

T.test("Holy Power does not grant sheet spell crit", function()
	local ns, d = load()
	local ranks = { holyPower = 5 }
	local v = { spellCrit = 9 }
	T.eq(ns.Calc.Breakdown(v, ranks, d).talents.holyPower, nil)
	local got = texts(ns, d, v, ranks)
	T.eq(got[1], "Conditional talents")
	T.eq(got[2], "Holy Power 5/5: Increases the critical strike healing bonus of your Holy spells by 10% per rank.")
end)

T.test("Anticipation 5/5: defense and every avoidance stat", function()
	local ns, d = load()
	local c = ns.Calc.Breakdown({ defense = 300, dodge = 5, parry = 5, block = 5 }, { anticipation = 5 }, d).talents.anticipation.contributions
	T.eq(c.defense, 20)
	T.near(c.dodge, 0.8, 1e-9); T.near(c.parry, 0.8, 1e-9); T.near(c.block, 0.8, 1e-9)
end)
