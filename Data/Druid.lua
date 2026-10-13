local ADDON, ns = ...

-- Build 1.60.1.70338. Source: https://wowforevertalents.com/druid/
-- Percent values are fractions (0.02 = 2%); flat crit/dodge values are percentage points.
-- `forms` gates an effect to those shapeshift forms (see ns.Stats.FORMS).
ns.Data = ns.Data or {}

ns.Data.DRUID = {
	tree = "Feral Combat",
	talents = {
		{
			key = "ferocity", name = "Ferocity", maxRank = 5, kind = "utility",
			explain = "Reduces the Rage or Energy cost of Maul, Primal Bite, Swipe, Claw and Rake by 1 per rank.",
		},
		{
			key = "heartOfTheWild", name = "Heart of the Wild", maxRank = 5, kind = "stat",
			effects = {
				{ stat = "int", op = "pct", perRank = { 0.02, 0.04, 0.06, 0.08, 0.10 } },
				{ stat = "stam", op = "pct", forms = { "bear" }, perRank = { 0.04, 0.08, 0.12, 0.16, 0.20 } },
				{ stat = "str", op = "pct", forms = { "cat" }, perRank = { 0.02, 0.04, 0.06, 0.08, 0.10 } },
			},
			explain = "Increases Intellect by 2% per rank, Stamina by 4% per rank in Bear Form and Strength by 2% per rank in Cat Form.",
		},
		{
			key = "feralSwiftness", name = "Feral Swiftness", maxRank = 2, kind = "stat",
			effects = { { stat = "dodge", op = "flat", perRank = { 2, 4 } } },
			explain = "Increases your dodge chance by 2% per rank and your Cat Form movement speed by 15% per rank.",
		},
		{
			key = "feralInstinct", name = "Feral Instinct", maxRank = 3, kind = "conditional",
			explain = "Increases the damage of Swipe by 10% per rank and improves your Prowl detection.",
		},
		{
			key = "brutalImpact", name = "Brutal Impact", maxRank = 2, kind = "utility",
			explain = "Improves your Bash and Pounce stuns.",
		},
		{
			key = "thickHide", name = "Thick Hide", maxRank = 3, kind = "stat",
			effects = {
				{ stat = "armor", op = "perLevel", forms = { "bear", "cat", "moonkin" }, perRank = { 1, 2, 3 } },
			},
			explain = "Adds base armor per character level in Bear, Cat and Moonkin forms; the defense skill bonus and form armor multipliers are not included.",
			inferred = { rank = true },
		},
		{
			key = "shreddingAttacks", name = "Shredding Attacks", maxRank = 3, kind = "utility",
			explain = "Improves your Shred and Lacerate.",
		},
		{
			key = "savageFury", name = "Savage Fury", maxRank = 2, kind = "conditional",
			explain = "Increases the damage of Claw, Rake, Shred, Maul and Swipe by 5% per rank.",
		},
		{
			key = "feralCharge", name = "Feral Charge", maxRank = 1, kind = "utility",
			explain = "Grants the Feral Charge ability.",
		},
		{
			key = "sharpenedClaws", name = "Sharpened Claws", maxRank = 2, kind = "stat",
			effects = { { stat = "meleeCrit", op = "flat", forms = { "bear", "cat" }, perRank = { 3, 6 } } },
			explain = "Increases your melee critical strike chance by 3% per rank while in Bear or Cat Form.",
		},
		{
			key = "shiftingPower", name = "Shifting Power", maxRank = 1, kind = "utility",
			explain = "Improves shapeshifting.",
		},
		{
			key = "primalBite", name = "Primal Bite", maxRank = 1, kind = "utility",
			explain = "Grants the Primal Bite ability.",
		},
		{
			key = "predatoryStrikes", name = "Predatory Strikes", maxRank = 3, kind = "stat",
			effects = { { stat = "ap", op = "perLevel", forms = { "cat", "bear" }, perRank = { 0.5, 1.0, 1.5 } } },
			explain = "Increases your attack power by 0.5 per character level per rank while in Cat or Bear Form.",
		},
		{
			key = "bloodFrenzy", name = "Blood Frenzy", maxRank = 2, kind = "conditional",
			explain = "Improves your attacks against bleeding targets.",
		},
		{
			key = "improvedShiftingPower", name = "Improved Shifting Power", maxRank = 2, kind = "utility",
			explain = "Further improves shapeshifting.",
		},
		{
			key = "leaderOfThePack", name = "Leader of the Pack", maxRank = 1, kind = "stat",
			effects = { { stat = "meleeCrit", op = "flat", forms = { "cat", "bear" }, perRank = { 3 } } },
			explain = "Increases the melee critical strike chance of you and your party by 3% while in Cat or Bear Form.",
		},
		{
			key = "naturalInstinct", name = "Natural Instinct", maxRank = 2, kind = "stat",
			effects = { { stat = "heal", op = "fromStat", source = "int", perRank = { 0.12, 0.25 } } },
			explain = "Grants healing power equal to 12%/25% of your Intellect and increases melee critical strike damage by 10%/20%.",
		},
		{
			key = "naturalReaction", name = "Natural Reaction", maxRank = 5, kind = "stat",
			effects = { { stat = "dodge", op = "flat", perRank = { 1, 2, 3, 4, 5 } } },
			explain = "Increases your dodge chance by 1% per rank; dodging has a 20% chance per rank to grant 5 Rage.",
		},
		{
			key = "rendAndTear", name = "Rend and Tear", maxRank = 5, kind = "conditional",
			explain = "Increases your melee damage against bleeding targets by 2% per rank.",
		},
		{
			key = "berserk", name = "Berserk", maxRank = 1, kind = "conditional",
			explain = "Grants the Berserk ability.",
		},
		{
			key = "naturesMajesty", name = "Nature's Majesty", maxRank = 2, kind = "stat", tree = "Balance",
			effects = {
				{ stat = "meleeCrit", op = "flat", perRank = { 2, 4 } },
				{ stat = "spellCrit", op = "flat", perRank = { 2, 4 } },
			},
			explain = "Increases your critical strike chance with all spells and attacks by 2% per rank.",
		},
	},
}
