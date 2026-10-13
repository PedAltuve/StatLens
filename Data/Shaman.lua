local ADDON, ns = ...

-- Build 1.60.1.70338. Source: https://wowforevertalents.com/shaman/
-- Percent values are fractions (0.02 = 2%); flat crit/dodge values are percentage points.
ns.Data = ns.Data or {}

ns.Data.SHAMAN = {
	tree = "Enhancement",
	talents = {
		{
			key = "earthsGrasp", name = "Earth's Grasp", maxRank = 2, kind = "utility",
			explain = "Improves your Stoneclaw Totem.",
		},
		{
			key = "thunderingStrikes", name = "Thundering Strikes", maxRank = 5, kind = "stat",
			effects = {
				{ stat = "meleeCrit", op = "flat", perRank = { 1, 2, 3, 4, 5 } },
				{ stat = "spellCrit", op = "flat", perRank = { 1, 2, 3, 4, 5 } },
			},
			explain = "Increases your critical strike chance by 1% per rank with all spells and attacks.",
		},
		{
			key = "ancestralKnowledge", name = "Ancestral Knowledge", maxRank = 5, kind = "stat",
			effects = { { stat = "int", op = "pct", perRank = { 0.02, 0.04, 0.06, 0.08, 0.10 } } },
			explain = "Increases your Intellect by 2% per rank.",
		},
		{
			key = "guardianTotems", name = "Guardian Totems", maxRank = 2, kind = "utility",
			explain = "Improves your Stoneskin and Windwall Totems.",
		},
		{
			key = "mentalDexterity", name = "Mental Dexterity", maxRank = 3, kind = "stat",
			effects = { { stat = "ap", op = "fromStat", source = "int", perRank = { 0.33, 0.66, 1.00 } } },
			explain = "Grants attack power equal to a share of your Intellect (33%/66%/100%).",
			inferred = { rank = true },
		},
		{
			key = "improvedGhostWolf", name = "Improved Ghost Wolf", maxRank = 2, kind = "utility",
			explain = "Improves Ghost Wolf form.",
		},
		{
			key = "improvedLightningShield", name = "Improved Lightning Shield", maxRank = 3, kind = "conditional",
			explain = "Increases the damage of your Lightning Shield orbs by 5% per rank.",
		},
		{
			key = "elementalWeapons", name = "Elemental Weapons", maxRank = 3, kind = "conditional",
			explain = "Boosts weapon imbues: Rockbiter attack power +7/13/20%, Windfury +13/27/40%, Flametongue and Frostbrand +5/10/15%.",
			inferred = { rank = true },
		},
		{
			key = "shamanisticFocus", name = "Shamanistic Focus", maxRank = 1, kind = "utility",
			explain = "Reduces the mana cost of your shocks and Lightning Shield by 45%.",
		},
		{
			key = "anticipation", name = "Anticipation", maxRank = 3, kind = "stat",
			effects = { { stat = "dodge", op = "flat", perRank = { 2, 4, 6 } } },
			explain = "Increases your dodge chance by 2% per rank.",
		},
		{
			key = "toughness", name = "Toughness", maxRank = 5, kind = "stat",
			effects = { { stat = "stam", op = "pct", perRank = { 0.02, 0.04, 0.06, 0.08, 0.10 } } },
			explain = "Increases your Stamina by 2% per rank.",
		},
		{
			key = "flurry", name = "Flurry", maxRank = 5, kind = "conditional",
			explain = "After a melee critical strike, your next 3 swings are 5% faster per rank.",
		},
		{
			key = "stormstrike", name = "Stormstrike", maxRank = 1, kind = "conditional",
			explain = "Your next Lightning Bolt, Chain Lightning or Earth Shock deals 20% more damage for 12 sec.",
		},
		{
			key = "spiritWeapons", name = "Spirit Weapons", maxRank = 1, kind = "stat",
			effects = { { stat = "parry", op = "enables" } },
			explain = "Lets you parry attacks and reduces the threat you generate.",
		},
		{
			key = "mentalQuickness", name = "Mental Quickness", maxRank = 2, kind = "stat",
			effects = {
				{ stat = "sp", op = "fromStat", source = "int", perRank = { 0.15, 0.30 } },
				{ stat = "heal", op = "fromStat", source = "int", perRank = { 0.15, 0.30 } },
			},
			explain = "Grants spell damage and healing equal to 15% per rank of your Intellect.",
		},
		{
			key = "improvedStormstrike", name = "Improved Stormstrike", maxRank = 2, kind = "conditional",
			explain = "Stormstrike has a 50%/100% chance to grant mana regeneration while casting for 15 sec, and resets its cooldown when you dodge or parry.",
		},
		{
			key = "maelstromWeapon", name = "Maelstrom Weapon", maxRank = 5, kind = "conditional",
			explain = "Stacks (up to 5) cut the cast time and mana cost of your next Lightning Bolt by 4% per rank each.",
		},
		{
			key = "rageOfTheFarseer", name = "Rage of the Farseer", maxRank = 1, kind = "conditional",
			explain = "Increases your attack speed by 30% for 25 sec (3 min cooldown).",
		},
	},
}
