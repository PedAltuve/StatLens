local ADDON, ns = ...

-- Build 1.60.1.70755. Source: https://wowforevertalents.com/shaman/
-- Percent values are fractions (0.02 = 2%); flat crit/dodge values are percentage points.
ns.Data = ns.Data or {}

ns.Data.SHAMAN = {
	tree = "Enhancement",
	talents = {
		{
			key = "earthsGrasp", name = "Earth's Grasp", maxRank = 2, kind = "utility",
			explain = "Increases Stoneclaw Totem health by 25% and Earthbind Totem radius by 10% per rank.",
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
			explain = "Improves Stoneskin and Windwall damage reduction by 10% and reduces Grounding Totem cooldown by 1 sec per rank.",
		},
		{
			key = "mentalDexterity", name = "Mental Dexterity", maxRank = 3, kind = "stat",
			effects = { { stat = "ap", op = "fromStat", source = "int", perRank = { 0.50, 1.00, 1.50 } } },
			explain = "Grants attack power equal to 50%/100%/150% of your Intellect.",
		},
		{
			key = "improvedGhostWolf", name = "Improved Ghost Wolf", maxRank = 2, kind = "utility",
			explain = "Reduces Ghost Wolf cast time by 1/3 sec and allows its use indoors.",
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
			explain = "After a melee critical strike, your next 3 swings are 6% faster per rank.",
		},
		{
			key = "stormstrike", name = "Stormstrike", maxRank = 1, kind = "conditional",
			explain = "Instantly strikes for 150% weapon damage and boosts your next Lightning Bolt, Chain Lightning or Earth Shock against the target by 20% for 12 sec.",
		},
		{
			key = "spiritWeapons", name = "Spirit Weapons", maxRank = 1, kind = "stat",
			effects = { { stat = "parry", op = "enables" } },
			explain = "Lets you parry attacks; reduces attack threat by 30% without Rockbiter Weapon, or increases all threat by 30% with it.",
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
			explain = "Stormstrike has a 50%/100% chance to grant 50% mana regeneration while casting for 15 sec; dodging or parrying has a 50%/100% chance to reset its cooldown.",
		},
		{
			key = "maelstromWeapon", name = "Maelstrom Weapon", maxRank = 5, kind = "conditional",
			explain = "Stacks (up to 5) cut the cast time and mana cost of your next Lightning Bolt by 4% per rank each.",
		},
		{
			key = "rageOfTheFarseer", name = "Rage of the Farseer", maxRank = 1, kind = "conditional",
			explain = "Increases your attack speed by 30% for 25 sec (3 min cooldown).",
		},
		{
			key = "convection", name = "Convection", maxRank = 5, kind = "utility", tree = "Elemental Combat",
			explain = "Reduces the mana cost of your shocks, Lightning Bolt and Chain Lightning by 2% per rank.",
		},
		{
			key = "concussion", name = "Concussion", maxRank = 5, kind = "conditional", tree = "Elemental Combat",
			explain = "Increases the damage of Lightning Bolt, Chain Lightning and Earth Shock by 1% per rank.",
		},
		{
			key = "elementalWarding", name = "Elemental Warding", maxRank = 3, kind = "utility", tree = "Elemental Combat",
			explain = "Reduces damage taken from Fire, Frost and Nature effects by 3% at rank 1 and 10% at rank 3.",
		},
		{
			key = "reverberation", name = "Reverberation", maxRank = 5, kind = "utility", tree = "Elemental Combat",
			explain = "Reduces the cooldown of your shocks by 0.2 sec per rank.",
		},
		{
			key = "callOfFlame", name = "Call of Flame", maxRank = 3, kind = "conditional", tree = "Elemental Combat",
			explain = "Increases Fire Totem, Flame Shock and Fire Nova damage by 5% per rank, and Flame Shock duration by 3 sec per rank.",
		},
		{
			key = "elementalDevastation", name = "Elemental Devastation", maxRank = 3, kind = "conditional", tree = "Elemental Combat",
			explain = "Your direct damage spell crits grant +3% melee crit chance per rank for 10 sec.",
		},
		{
			key = "elementalFocus", name = "Elemental Focus", maxRank = 1, kind = "conditional", tree = "Elemental Combat",
			explain = "10% chance after a Fire, Frost or Nature damage spell to enter Clearcasting, making your next damage spell free.",
		},
		{
			key = "elementalAlacrity", name = "Elemental Alacrity", maxRank = 3, kind = "conditional", tree = "Elemental Combat",
			explain = "Reduces the cast time of Lightning Bolt and Chain Lightning by 0.17/0.33/0.5 sec.",
		},
		{
			key = "trialByFire", name = "Trial by Fire", maxRank = 2, kind = "conditional", tree = "Elemental Combat",
			explain = "Increases Fire Nova damage by 10%, reduces its cooldown by 2 sec, and increases Magma Totem duration by 10 sec per rank.",
		},
		{
			key = "eyeOfTheStorm", name = "Eye of the Storm", maxRank = 3, kind = "conditional", tree = "Elemental Combat",
			explain = "Gives Lightning Bolt and Chain Lightning a 23%/47%/70% chance to avoid pushback from damage.",
		},
		{
			key = "callOfThunder", name = "Call of Thunder", maxRank = 1, kind = "conditional", tree = "Elemental Combat",
			explain = "Effect text is not in the client yet.",
		},
		{
			key = "elementalReach", name = "Elemental Reach", maxRank = 2, kind = "utility", tree = "Elemental Combat",
			explain = "Increases the range of Lightning Bolt, Chain Lightning and Fire Nova by 3 yd per rank.",
		},
		{
			key = "lightningOverload", name = "Lightning Overload", maxRank = 3, kind = "conditional", tree = "Elemental Combat",
			explain = "Lightning Bolt and Chain Lightning have a 10%/20%/30% chance to cast a free second spell for half damage and no threat.",
		},
		{
			key = "earthbound", name = "Earthbound", maxRank = 1, kind = "utility", tree = "Elemental Combat",
			explain = "Your Earthbind Totem immobilizes nearby targets for 5 sec when cast.",
		},
		{
			key = "elementalFury", name = "Elemental Fury", maxRank = 5, kind = "conditional", tree = "Elemental Combat",
			explain = "Increases the critical strike damage bonus of Searing and Magma Totems and your Fire, Frost and Nature spells by 20% per rank.",
		},
		{
			key = "lightningMastery", name = "Lightning Mastery", maxRank = 1, kind = "conditional", tree = "Elemental Combat",
			explain = "Requires Call of Thunder. Reduces Lightning Bolt cast time by 0.5 sec and removes Chain Lightning's cooldown for 15 sec.",
		},
		{
			key = "improvedHealingWave", name = "Improved Healing Wave", maxRank = 5, kind = "conditional", tree = "Restoration",
			explain = "Reduces the cast time of Healing Wave by 0.1 sec per rank.",
		},
		{
			key = "totemicFocus", name = "Totemic Focus", maxRank = 5, kind = "utility", tree = "Restoration",
			explain = "Reduces the mana cost of your totems and of spells that summon or move them by 5% per rank.",
		},
		{
			key = "mindfulness", name = "Mindfulness", maxRank = 3, kind = "conditional", tree = "Restoration",
			explain = "Allows 17% of your mana regeneration to continue while casting at rank 1 and 50% at rank 3.",
		},
		{
			key = "naturalGrace", name = "Natural Grace", maxRank = 3, kind = "utility", tree = "Restoration",
			explain = "Reduces the threat generated by your spells by 5% per rank.",
		},
		{
			key = "tidalFocus", name = "Tidal Focus", maxRank = 5, kind = "stat", tree = "Restoration",
			effects = {
				{ stat = "hit", op = "flat", perRank = { 1, 2, 3, 4, 5 } },
				{ stat = "spellHit", op = "flat", perRank = { 1, 2, 3, 4, 5 } },
			},
			explain = "Improves your chance to hit by 1% per rank and reduces the mana cost of healing spells by 1% per rank.",
		},
		{
			key = "improvedReincarnation", name = "Improved Reincarnation", maxRank = 2, kind = "stat", tree = "Restoration",
			effects = { { stat = "health", op = "pct", perRank = { 0.02, 0.04 } } },
			explain = "Increases your maximum health by 2% per rank, reduces the Reincarnation cooldown by 10 min per rank and adds 10% per rank to the health and mana you return with.",
		},
		{
			key = "ancestralHealing", name = "Ancestral Healing", maxRank = 3, kind = "conditional", tree = "Restoration",
			explain = "Increases your target's armor by 8% at rank 1 and 25% at rank 3 for 15 sec after one of your healing spells crits.",
		},
		{
			key = "healingFocus", name = "Healing Focus", maxRank = 3, kind = "conditional", tree = "Restoration",
			explain = "Gives a 23% chance at rank 1 (70% at rank 3) to avoid interruption by damage while casting a healing spell.",
		},
		{
			key = "waterShield", name = "Water Shield", maxRank = 1, kind = "utility", tree = "Restoration",
			explain = "Grants Water Shield: 3 globes that restore 2% of your maximum mana when you are hit or any of your spells crits; only one globe activates every few seconds.",
		},
		{
			key = "tidalMastery", name = "Tidal Mastery", maxRank = 5, kind = "conditional", tree = "Restoration",
			explain = "Increases the critical effect chance of your healing spells by 1% per rank.",
		},
		{
			key = "restorativeTotems", name = "Restorative Totems", maxRank = 5, kind = "conditional", tree = "Restoration",
			explain = "Increases the effect of Mana Spring Totem by 5% per rank and Healing Stream Totem by 10% per rank.",
		},
		{
			key = "manaTideTotem", name = "Mana Tide Totem", maxRank = 1, kind = "utility", tree = "Restoration",
			explain = "Grants Mana Tide Totem: restores 88 mana every 3 sec to nearby group members for 12 sec (5 min cooldown).",
		},
		{
			key = "healingWay", name = "Healing Way", maxRank = 3, kind = "conditional", tree = "Restoration",
			explain = "Increases the amount healed by Healing Wave by 8% at rank 1 and 25% at rank 3.",
		},
		{
			key = "naturesSwiftness", name = "Nature's Swiftness", maxRank = 1, kind = "utility", tree = "Restoration",
			explain = "Grants Nature's Swiftness: your next Nature spell with a cast time under 10 sec becomes instant (3 min cooldown).",
		},
		{
			key = "purification", name = "Purification", maxRank = 5, kind = "conditional", tree = "Restoration",
			explain = "Increases the effectiveness of your healing spells by 2% per rank.",
		},
		{
			key = "riptide", name = "Riptide", maxRank = 1, kind = "utility", tree = "Restoration",
			explain = "Heals a friendly target for 445 over 15 sec and boosts Chain Heal casts directly on that target by 25%.",
		},
	},
}
