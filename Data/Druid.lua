local ADDON, ns = ...

-- Build 1.60.1.70755. Source: https://wowforevertalents.com/druid/
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
			key = "heartOfTheWild", name = "Heart of the Wild", maxRank = 5, kind = "stat", tree = "Restoration",
			effects = {
				{ stat = "int", op = "pct", perRank = { 0.02, 0.04, 0.06, 0.08, 0.10 } },
				{ stat = "stam", op = "pct", forms = { "bear" }, perRank = { 0.04, 0.08, 0.12, 0.16, 0.20 } },
				{ stat = "str", op = "pct", forms = { "cat" }, perRank = { 0.02, 0.04, 0.06, 0.08, 0.10 } },
			},
			explain = "Increases Intellect by 2% per rank, Stamina by 4% per rank in Bear or Dire Bear Form and Strength by 2% per rank in Cat Form.",
		},
		{
			key = "feralSwiftness", name = "Feral Swiftness", maxRank = 2, kind = "stat",
			effects = { { stat = "dodge", op = "flat", perRank = { 2, 4 } } },
			explain = "Increases your dodge chance by 2% per rank and your Cat Form movement speed by 15% per rank.",
		},
		{
			key = "feralInstinct", name = "Feral Instinct", maxRank = 3, kind = "conditional",
			explain = "Increases the damage of Swipe by 10% per rank and makes you harder to detect while Prowling as if 1 level higher per rank.",
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
			explain = "Adds 1 base Armor per level per rank in Bear, Dire Bear, Cat or Moonkin Form, plus 0.67/1.33/2 base Armor per defense skill above five times your level. Form multipliers can increase this armor; only the per-level base armor is modeled here.",
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
			explain = "Increases your melee critical strike chance by 3% per rank while in Bear, Dire Bear or Cat Form.",
		},
		{
			key = "shiftingPower", name = "Shifting Power", maxRank = 1, kind = "utility",
			explain = "Instantly converts 55% of Base Mana into 40 Energy; effects that reduce shapeshifting costs also reduce this cost.",
		},
		{
			key = "primalBite", name = "Primal Bite", maxRank = 1, kind = "utility",
			explain = "Grants the Primal Bite ability.",
		},
		{
			key = "predatoryStrikes", name = "Predatory Strikes", maxRank = 3, kind = "stat",
			effects = { { stat = "ap", op = "perLevel", forms = { "cat", "bear" }, perRank = { 0.5, 1.0, 1.5 } } },
			explain = "Increases your attack power by 0.5 per character level per rank while in Cat, Bear or Dire Bear Form.",
		},
		{
			key = "bloodFrenzy", name = "Blood Frenzy", maxRank = 2, kind = "conditional",
			explain = "Critical strikes in Bear or Dire Bear Form have a 50% chance per rank to grant 5 extra Rage; non-periodic Cat ability crits that generate Combo Points have the same chance to add an extra Combo Point.",
		},
		{
			key = "predatoryDiscipline", name = "Predatory Discipline", maxRank = 1, kind = "utility",
			explain = "Ferocious Bite no longer converts extra Energy into damage, but still deals extra damage based on excess Energy.",
		},
		{
			key = "leaderOfThePack", name = "Leader of the Pack", maxRank = 1, kind = "stat",
			effects = {
				{ stat = "meleeCrit", op = "flat", forms = { "cat", "bear" }, perRank = { 3 } },
				{ stat = "spellCrit", op = "flat", forms = { "cat", "bear" }, perRank = { 3 } },
			},
			explain = "Increases the critical strike chance of party or raid members within 45 yards by 3% while in Cat, Bear or Dire Bear Form.",
		},
		{
			key = "naturalInstinct", name = "Natural Instinct", maxRank = 2, kind = "stat",
			effects = { { stat = "heal", op = "fromStat", source = "int", perRank = { 0.12, 0.25 } } },
			explain = "Increases spell healing by 12%/25% of your Intellect and the critical strike damage bonus of melee abilities by 10%/20%.",
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
			key = "lacerate", name = "Lacerate", maxRank = 1, kind = "utility",
			explain = "Grants Lacerate: causes a high-threat bleed over 15 sec plus weapon damage per existing application, stacking up to 5 times.",
		},
		{
			key = "naturesMajesty", name = "Nature's Majesty", maxRank = 2, kind = "stat", tree = "Balance",
			effects = {
				{ stat = "meleeCrit", op = "flat", perRank = { 2, 4 } },
				{ stat = "spellCrit", op = "flat", perRank = { 2, 4 } },
			},
			explain = "Increases your critical strike chance with all spells and attacks by 2% per rank.",
		},
		{
			key = "improvedWrath", name = "Improved Wrath", maxRank = 5, kind = "conditional", tree = "Balance",
			explain = "Reduces the cast time of Wrath by 0.1 sec per rank and its mana cost by 10% per rank.",
		},
		{
			key = "genesis", name = "Genesis", maxRank = 5, kind = "conditional", tree = "Balance",
			explain = "Increases the periodic damage and healing of your spells and abilities by 2% per rank.",
		},
		{
			key = "moonglow", name = "Moonglow", maxRank = 3, kind = "utility", tree = "Balance",
			explain = "Reduces the mana cost of your damaging spells by 8% at rank 1 and 25% at rank 3.",
		},
		{
			key = "improvedMoonfire", name = "Improved Moonfire", maxRank = 2, kind = "conditional", tree = "Balance",
			explain = "Increases the damage and critical strike chance of Moonfire by 5% per rank.",
		},
		{
			key = "naturesReach", name = "Nature's Reach", maxRank = 2, kind = "stat", tree = "Balance",
			effects = {
				{ stat = "hit", op = "flat", perRank = { 2, 4 } },
				{ stat = "spellHit", op = "flat", perRank = { 2, 4 } },
			},
			explain = "Improves your chance to hit by 2% per rank and increases the range of offensive Balance spells by 10% per rank.",
		},
		{
			key = "improvedEntanglingRoots", name = "Improved Entangling Roots", maxRank = 3, kind = "conditional", tree = "Balance",
			explain = "Increases Entangling Roots damage by 25% per rank, and its victims can take that much more damage without breaking free.",
		},
		{
			key = "naturesSplendor", name = "Nature's Splendor", maxRank = 1, kind = "utility", tree = "Balance",
			explain = "Increases the duration of Moonfire and Rejuvenation by 3 sec, Regrowth by 6 sec and Insect Swarm by 2 sec.",
		},
		{
			key = "insectSwarm", name = "Insect Swarm", maxRank = 1, kind = "conditional", tree = "Balance",
			explain = "Grants Insect Swarm: reduces the target's chance to hit by 2% and deals Nature damage over 12 sec.",
		},
		{
			key = "vengeance", name = "Vengeance", maxRank = 5, kind = "conditional", tree = "Balance",
			explain = "Increases the critical strike damage bonus of your Arcane and Nature spells by 20% per rank.",
		},
		{
			key = "improvedStarfire", name = "Improved Starfire", maxRank = 5, kind = "conditional", tree = "Balance",
			explain = "Reduces the cast time of Starfire by 0.1 sec per rank and gives it a 3% chance per rank to stun for 3 sec.",
		},
		{
			key = "overgrowth", name = "Overgrowth", maxRank = 2, kind = "utility", tree = "Balance",
			explain = "Increases the maximum number of targets affected by Entangling Roots by 1 per rank.",
		},
		{
			key = "naturesGrace", name = "Nature's Grace", maxRank = 1, kind = "conditional", tree = "Balance",
			explain = "Non-periodic spell crits increase your spellcasting speed and reduce your global cooldown by 10% for 3 sec.",
		},
		{
			key = "eclipse", name = "Eclipse", maxRank = 3, kind = "conditional", tree = "Balance",
			explain = "Wrath reduces the cast time of your next 2 Starfire casts by 0.17 sec at rank 1 and 0.5 sec at rank 3 (up to 4 charges, 15 sec).",
		},
		{
			key = "moonfury", name = "Moonfury", maxRank = 5, kind = "conditional", tree = "Balance",
			explain = "Increases the damage of your Arcane and Nature spells by 2% per rank.",
		},
		{
			key = "moonkinForm", name = "Moonkin Form", maxRank = 1, kind = "stat", tree = "Balance",
			effects = {
				{ stat = "meleeCrit", op = "flat", forms = { "moonkin" }, perRank = { 3 } },
				{ stat = "spellCrit", op = "flat", forms = { "moonkin" }, perRank = { 3 } },
			},
			explain = "In Moonkin Form, party or raid members within 45 yards gain 3% critical strike chance; also +360% armor from items, +100% Omen of Clarity trigger chance, Polymorph protection, and no healing spells. Shapeshifting frees you from Polymorph and movement impairing effects.",
		},
		{
			key = "naturesFocus", name = "Nature's Focus", maxRank = 5, kind = "utility", tree = "Restoration",
			explain = "Gives a 14% chance per rank to avoid interruption by damage while casting Arcane and Nature spells.",
		},
		{
			key = "furor", name = "Furor", maxRank = 5, kind = "utility",
			explain = "Gives a 20% chance per rank to gain 10 Rage on entering Bear or Dire Bear Form. Entering Cat Form restores 20% per rank of your previous Cat Energy plus 2 Energy per rank per second spent outside Bear or Dire Bear Form, capped at 20 Energy per rank.",
		},
		{
			key = "naturalist", name = "Naturalist", maxRank = 5, kind = "conditional", tree = "Restoration",
			explain = "Reduces the cast time of Healing Touch and Wild Growth by 0.1 sec per rank and increases all damage you deal by 2% per rank.",
		},
		{
			key = "subtlety", name = "Subtlety", maxRank = 3, kind = "utility", tree = "Restoration",
			explain = "Reduces the threat generated by your Nature and Arcane spells by 10% per rank.",
		},
		{
			key = "naturalShapeshifter", name = "Natural Shapeshifter", maxRank = 3, kind = "utility", tree = "Restoration",
			explain = "Reduces the mana cost of all shapeshifting by 10% per rank.",
		},
		{
			key = "reflection", name = "Reflection", maxRank = 3, kind = "conditional", tree = "Restoration",
			explain = "Allows 17% of your mana regeneration to continue while casting at rank 1 and 50% at rank 3.",
		},
		{
			key = "giftOfNature", name = "Gift of Nature", maxRank = 5, kind = "conditional", tree = "Restoration",
			explain = "Increases the effect of all your healing spells by 2% per rank.",
		},
		{
			key = "bloom", name = "Bloom", maxRank = 1, kind = "conditional", tree = "Restoration",
			explain = "When Rejuvenation or Regrowth expires naturally, heals the target for 100% of your Spirit; if dispelled, heals for 50% instead.",
		},
		{
			key = "tranquilSpirit", name = "Tranquil Spirit", maxRank = 5, kind = "conditional", tree = "Restoration",
			explain = "Reduces the mana cost of Healing Touch and Tranquility by 2% per rank.",
		},
		{
			key = "improvedRejuvenation", name = "Improved Rejuvenation", maxRank = 3, kind = "conditional", tree = "Restoration",
			explain = "Increases the effect of Rejuvenation by 5% per rank.",
		},
		{
			key = "swiftmend", name = "Swiftmend", maxRank = 1, kind = "utility", tree = "Restoration",
			explain = "Grants Swiftmend: consumes your active Rejuvenation or Regrowth to instantly heal for its full periodic duration.",
		},
		{
			key = "naturesSwiftness", name = "Nature's Swiftness", maxRank = 1, kind = "utility", tree = "Restoration",
			explain = "Grants Nature's Swiftness: your next Nature spell becomes instant.",
		},
		{
			key = "livingSpirit", name = "Living Spirit", maxRank = 3, kind = "stat", tree = "Restoration",
			effects = { { stat = "spirit", op = "pct", perRank = { 0.05, 0.10, 0.15 } } },
			explain = "Increases your Spirit by 5% per rank.",
		},
		{
			key = "improvedTranquility", name = "Improved Tranquility", maxRank = 2, kind = "utility", tree = "Restoration",
			explain = "Reduces the threat of Tranquility by 50% per rank and its cooldown by 30% per rank.",
		},
		{
			key = "improvedRegrowth", name = "Improved Regrowth", maxRank = 5, kind = "conditional", tree = "Restoration",
			explain = "Increases the critical effect chance of Regrowth by 10% per rank.",
		},
		{
			key = "wildGrowth", name = "Wild Growth", maxRank = 1, kind = "utility", tree = "Restoration",
			explain = "Grants Wild Growth: heals the target and party members within 43.5 yards over 7 sec, healing quickly at first and slowing over time.",
		},
	},
}
