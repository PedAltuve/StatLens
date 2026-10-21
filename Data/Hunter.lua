local ADDON, ns = ...

-- Source: Forever talent tooltips (see odd/sources/hunter-trees.txt).
-- Percent values are fractions; flat hit/crit/parry values are percentage points.
-- Pet, aspect, shot and melee-ability-only bonuses are conditional: the sheet does not show them.
ns.Data = ns.Data or {}

ns.Data.HUNTER = {
	tree = "Beast Mastery",
	talents = {
		{
			key = "deadlyAspects", name = "Deadly Aspects", maxRank = 5, kind = "conditional",
			explain = "With Aspect of the Hawk, Auto Shot has a 2% chance per rank to increase ranged attack speed by 30% for 12 sec; with Aspect of the Beast, melee auto attacks do the same for melee attack speed.",
		},
		{
			key = "enduranceTraining", name = "Endurance Training", maxRank = 5, kind = "utility",
			explain = "Increases your pet's Health and Armor by 3% per rank.",
		},
		{
			key = "focusedFire", name = "Focused Fire", maxRank = 2, kind = "conditional",
			explain = "Increases all damage you and your pet deal by 1% per rank while your pet is active.",
		},
		{
			key = "improvedAspectOfTheMonkey", name = "Improved Aspect of the Monkey", maxRank = 3, kind = "conditional",
			explain = "Increases the Dodge bonus of Aspect of the Monkey by 2% per rank, and your pet gains 50% of its effect.",
		},
		{
			key = "pathfinding", name = "Pathfinding", maxRank = 2, kind = "utility",
			explain = "Increases the speed bonus of Aspect of the Cheetah and Aspect of the Pack by 3% per rank.",
		},
		{
			key = "improvedRevivePet", name = "Improved Revive Pet", maxRank = 2, kind = "utility",
			explain = "Reduces Revive Pet's cast time by 3 sec and mana cost by 20% per rank, and your pet returns with 15% more health per rank.",
		},
		{
			key = "bestialSwiftness", name = "Bestial Swiftness", maxRank = 1, kind = "utility",
			explain = "Increases your pet's movement speed by 30%.",
		},
		{
			key = "unleashedFury", name = "Unleashed Fury", maxRank = 5, kind = "conditional",
			explain = "Increases the damage done by your pets and hawks by 3% per rank.",
		},
		{
			key = "improvedMendPet", name = "Improved Mend Pet", maxRank = 2, kind = "utility",
			explain = "Gives Mend Pet a 15/50% chance to cleanse 1 Curse, Disease, Magic or Poison effect per heal and reduces its mana cost by 10% per rank.",
		},
		{
			key = "ferocity", name = "Ferocity", maxRank = 5, kind = "conditional",
			explain = "Increases the critical strike chance of your pets and hawks by 2% per rank.",
		},
		{
			key = "summonHawk", name = "Summon Hawk", maxRank = 1, kind = "utility",
			explain = "Grants Summon Hawk: a hawk dive-bombs your target and keeps attacking for 18 sec (up to 2 hawks, shares a cooldown with Arcane Shot).",
		},
		{
			key = "spiritBond", name = "Spirit Bond", maxRank = 2, kind = "conditional",
			explain = "While your pet is active, you and your pet regenerate 1% of total health every 10 sec at rank 1 and every 5 sec at rank 2.",
		},
		{
			key = "intimidation", name = "Intimidation", maxRank = 1, kind = "utility",
			explain = "Grants Intimidation: your pet's next successful attack stuns the target for 3 sec with 100% increased crit chance (1 min cooldown).",
		},
		{
			key = "bestialDiscipline", name = "Bestial Discipline", maxRank = 2, kind = "conditional",
			explain = "Increases your pet's Focus regeneration by 10% per rank and lets 25% of your mana regeneration per rank continue while casting.",
		},
		{
			key = "frenzy", name = "Frenzy", maxRank = 5, kind = "conditional",
			explain = "Gives your pet a 20% chance per rank to gain 30% attack speed for 8 sec after a critical strike.",
		},
		{
			key = "bestialWrath", name = "Bestial Wrath", maxRank = 1, kind = "conditional",
			explain = "Sends your pet into a rage, causing 50% additional damage for 18 sec; it cannot be stopped unless killed (2 min cooldown).",
		},
		{
			key = "hawkEye", name = "Hawk Eye", maxRank = 3, kind = "utility", tree = "Marksmanship",
			explain = "Increases the range of your ranged weapons by 2 yards per rank.",
		},
		{
			key = "improvedConcussiveShot", name = "Improved Concussive Shot", maxRank = 5, kind = "conditional", tree = "Marksmanship",
			explain = "Gives Concussive Shot a 4% chance per rank to stun the target for 3 sec.",
		},
		{
			key = "lethalAttacks", name = "Lethal Attacks", maxRank = 5, kind = "stat", tree = "Marksmanship",
			effects = {
				{ stat = "meleeCrit", op = "flat", perRank = { 1, 2, 3, 4, 5 } },
				{ stat = "rangedCrit", op = "flat", perRank = { 1, 2, 3, 4, 5 } },
			},
			explain = "Increases your critical strike chance with all attacks by 1% per rank.",
		},
		{
			key = "improvedStings", name = "Improved Stings", maxRank = 3, kind = "conditional", tree = "Marksmanship",
			explain = "Increases Serpent Sting damage (up to 20%), reduces Viper Sting's cooldown by 2 sec per rank and extends Scorpid Sting by 15 sec per rank.",
		},
		{
			key = "efficiency", name = "Efficiency", maxRank = 5, kind = "utility", tree = "Marksmanship",
			explain = "Reduces the mana cost of your Shots, Stings and melee abilities by 3% per rank.",
		},
		{
			key = "carefulAim", name = "Careful Aim", maxRank = 5, kind = "stat", tree = "Marksmanship",
			effects = {
				{ stat = "ap", op = "fromStat", source = "int", perRank = { 0.20, 0.40, 0.60, 0.80, 1.00 } },
				{ stat = "rangedAp", op = "fromStat", source = "int", perRank = { 0.20, 0.40, 0.60, 0.80, 1.00 } },
			},
			explain = "Increases your Attack Power by 20% of your Intellect per rank.",
		},
		{
			key = "rapidKilling", name = "Rapid Killing", maxRank = 2, kind = "conditional", tree = "Marksmanship",
			explain = "Reduces Rapid Fire's cooldown by 1 min per rank; killing an enemy (or it dying with your Serpent Sting) increases your next Shot's damage by 10% per rank.",
		},
		{
			key = "improvedArcaneShot", name = "Improved Arcane Shot", maxRank = 5, kind = "utility", tree = "Marksmanship",
			explain = "Reduces Arcane Shot's cooldown by 0.3 sec per rank (not abilities sharing its cooldown).",
		},
		{
			key = "loneWolf", name = "Lone Wolf", maxRank = 1, kind = "conditional", tree = "Marksmanship",
			explain = "You deal 20% more damage with all attacks while you have no active pet.",
		},
		{
			key = "trueshotAura", name = "Trueshot Aura", maxRank = 1, kind = "conditional", tree = "Marksmanship",
			explain = "Grants Trueshot Aura: increases the Ranged Attack Power of party or raid members within 45 yds by 30 (already included in the sheet while active).",
		},
		{
			key = "mortalShots", name = "Mortal Shots", maxRank = 5, kind = "conditional", tree = "Marksmanship",
			explain = "Increases the critical strike damage bonus of all ranged abilities by 6% per rank.",
		},
		{
			key = "improvedSerpentSting", name = "Improved Serpent Sting", maxRank = 5, kind = "conditional", tree = "Marksmanship",
			explain = "Increases the damage done by Serpent Sting by 2% per rank.",
		},
		{
			key = "rapidRecuperation", name = "Rapid Recuperation", maxRank = 2, kind = "conditional", tree = "Marksmanship",
			explain = "Serpent Sting lets 25% of your mana regeneration per rank continue while casting for 15 sec, doubled when Rapid Killing is consumed.",
		},
		{
			key = "barrage", name = "Barrage", maxRank = 3, kind = "conditional", tree = "Marksmanship",
			explain = "Increases the damage of Multi-Shot, Aimed Shot and Volley by 3/6/10%.",
		},
		{
			key = "scatterShot", name = "Scatter Shot", maxRank = 1, kind = "utility", tree = "Marksmanship",
			explain = "Grants Scatter Shot: a short-range shot for 50% weapon damage that disorients the target for 4 sec (30 sec cooldown).",
		},
		{
			key = "rangedWeaponSpecialization", name = "Ranged Weapon Specialization", maxRank = 5, kind = "conditional", tree = "Marksmanship",
			explain = "Increases the damage you deal with ranged weapons by 1% per rank.",
		},
		{
			key = "sniperShot", name = "Sniper Shot", maxRank = 1, kind = "utility", tree = "Marksmanship",
			explain = "Grants Sniper Shot: a long-range shot that also increases the range of your next 3 Shots by 10 yards for 10 sec.",
		},
		{
			key = "improvedTracking", name = "Improved Tracking", maxRank = 5, kind = "conditional", tree = "Survival",
			explain = "While tracking a creature type, increases all damage you deal to that type by 1% per rank.",
		},
		{
			key = "deflection", name = "Deflection", maxRank = 5, kind = "stat", tree = "Survival",
			effects = { { stat = "parry", op = "flat", perRank = { 1, 2, 3, 4, 5 } } },
			explain = "Increases your Parry chance by 1% per rank.",
		},
		{
			key = "entrapment", name = "Entrapment", maxRank = 5, kind = "conditional", tree = "Survival",
			explain = "Targets caught by your traps are Entrapped, unable to move for 1 sec per rank.",
		},
		{
			key = "savageStrikes", name = "Savage Strikes", maxRank = 2, kind = "conditional", tree = "Survival",
			explain = "Increases the critical strike chance of your melee abilities by 2% per rank (not auto attacks, so not shown in the sheet's crit).",
		},
		{
			key = "survivalist", name = "Survivalist", maxRank = 5, kind = "stat", tree = "Survival",
			effects = { { stat = "health", op = "pct", perRank = { 0.02, 0.04, 0.06, 0.08, 0.10 } } },
			explain = "Increases your total Health by 2% per rank.",
		},
		{
			key = "improvedWingClip", name = "Improved Wing Clip", maxRank = 3, kind = "conditional", tree = "Survival",
			explain = "Gives Wing Clip a 7/13/20% chance to immobilize the target for 5 sec.",
		},
		{
			key = "cleverTraps", name = "Clever Traps", maxRank = 2, kind = "conditional", tree = "Survival",
			explain = "Increases the duration of Freezing and Frost trap effects and the damage of Immolation and Explosive trap effects by 15% per rank.",
		},
		{
			key = "surefooted", name = "Surefooted", maxRank = 3, kind = "stat", tree = "Survival",
			effects = { { stat = "hit", op = "flat", perRank = { 1, 2, 3 } } },
			explain = "Increases your hit chance by 1% per rank and reduces the duration of movement impairing effects on you by 10% per rank.",
		},
		{
			key = "deterrence", name = "Deterrence", maxRank = 1, kind = "utility", tree = "Survival",
			explain = "Grants Deterrence: increases your Dodge and Parry chance by 25% for 10 sec (5 min cooldown).",
		},
		{
			key = "survivalTactics", name = "Survival Tactics", maxRank = 2, kind = "conditional", tree = "Survival",
			explain = "Increases your chance to hit with Trap and Feign Death abilities by 5% per rank.",
		},
		{
			key = "predatorsEdge", name = "Predator's Edge", maxRank = 5, kind = "conditional", tree = "Survival",
			explain = "Increases your melee ability critical strike damage by 6% and your off-hand weapon damage by 10% per rank.",
		},
		{
			key = "counterattack", name = "Counterattack", maxRank = 1, kind = "utility", tree = "Survival",
			explain = "Grants Counterattack: after you parry, strike for 50% weapon damage and immobilize the target for 5 sec (5 sec cooldown).",
		},
		{
			key = "resourcefulness", name = "Resourcefulness", maxRank = 2, kind = "conditional", tree = "Survival",
			explain = "Reduces the mana cost of Trap and melee abilities by 30% per rank; your critical strikes have a 50% chance per rank to let 50% of your mana regeneration continue while casting for 30 sec.",
		},
		{
			key = "exposePrey", name = "Expose Prey", maxRank = 2, kind = "conditional", tree = "Survival",
			explain = "Your melee and ranged attacks against targets with Hunter's Mark have a 5% chance per rank to enable Mongoose Bite for 10 sec.",
		},
		{
			key = "survivalistsDiscipline", name = "Survivalist's Discipline", maxRank = 2, kind = "utility", tree = "Survival",
			explain = "Reduces the cooldown of your Trap and Deterrence abilities by 20% per rank.",
		},
		{
			key = "striderKick", name = "Strider Kick", maxRank = 1, kind = "utility", tree = "Survival",
			explain = "Grants Strider Kick: a kick for 100% melee weapon damage that increases your movement speed by 30% for 3 sec (8 sec cooldown).",
		},
		{
			key = "lightningReflexes", name = "Lightning Reflexes", maxRank = 5, kind = "stat", tree = "Survival",
			effects = { { stat = "agi", op = "pct", perRank = { 0.02, 0.04, 0.06, 0.08, 0.10 } } },
			explain = "Increases your Agility by 2% per rank.",
		},
		{
			key = "laceratingStrikes", name = "Lacerating Strikes", maxRank = 1, kind = "conditional", tree = "Survival",
			explain = "Mongoose Bite also makes the target bleed for 40% of its damage over 21 sec.",
		},
	},
}
