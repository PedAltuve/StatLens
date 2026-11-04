local ADDON, ns = ...

-- Source: Forever talent tooltips (see odd/sources/rogue-trees.txt).
-- Percent values are fractions; flat hit/crit/dodge/parry values are percentage points.
-- Ability-only, poison and finishing-move bonuses are conditional: the sheet does not show them.
ns.Data = ns.Data or {}

ns.Data.ROGUE = {
	tree = "Assassination",
	talents = {
		{
			key = "improvedGouge", name = "Improved Gouge", maxRank = 3, kind = "utility",
			explain = "Increases the duration of Gouge by 0.5 sec per rank.",
		},
		{
			key = "remorselessAttacks", name = "Remorseless Attacks", maxRank = 2, kind = "conditional",
			explain = "After killing a non-trivial enemy, your next Sinister Strike, Backstab, Ambush, Mutilate or Ghostly Strike within 20 sec has 20% more crit chance per rank.",
		},
		{
			key = "malice", name = "Malice", maxRank = 5, kind = "stat",
			effects = {
				{ stat = "meleeCrit", op = "flat", perRank = { 1, 2, 3, 4, 5 } },
				{ stat = "rangedCrit", op = "flat", perRank = { 1, 2, 3, 4, 5 } },
			},
			explain = "Increases your critical strike chance with all attacks and Poisons by 1% per rank.",
		},
		{
			key = "ruthlessness", name = "Ruthlessness", maxRank = 3, kind = "conditional",
			explain = "Gives your finishing moves a 20% chance per rank to add a Combo Point to your target.",
		},
		{
			key = "improvedSliceAndDice", name = "Improved Slice and Dice", maxRank = 3, kind = "utility",
			explain = "Increases the duration of Slice and Dice by 15% per rank.",
		},
		{
			key = "relentlessStrikes", name = "Relentless Strikes", maxRank = 5, kind = "conditional",
			explain = "Your finishing moves have a 4% chance per rank per Combo Point to restore 25 Energy (20% at rank 5).",
		},
		{
			key = "improvedExposeArmor", name = "Improved Expose Armor", maxRank = 2, kind = "utility",
			explain = "Reduces Expose Armor's Energy cost by 5 per rank and refunds 1 Combo Point per rank when cast with 5 Combo Points.",
		},
		{
			key = "lethality", name = "Lethality", maxRank = 2, kind = "conditional",
			explain = "Increases the critical strike damage bonus of Sinister Strike, Gouge, Backstab, Mutilate, Ghostly Strike and Hemorrhage by 10% per rank.",
		},
		{
			key = "vilePoisons", name = "Vile Poisons", maxRank = 5, kind = "conditional",
			explain = "Increases the damage of your poisons by 4% per rank and gives them an extra 8% chance per rank to resist dispel effects.",
		},
		{
			key = "coldBlood", name = "Cold Blood", maxRank = 1, kind = "conditional",
			explain = "When activated, your next Sinister Strike, Backstab, Ambush, Eviscerate or Mutilate has 100% increased crit chance (3 min cooldown).",
		},
		{
			key = "improvedPoisons", name = "Improved Poisons", maxRank = 5, kind = "conditional",
			explain = "Increases the chance to apply Poisons by 2% per rank, and Poison applications have a 10% chance per rank to not consume a charge.",
		},
		{
			key = "vigor", name = "Vigor", maxRank = 2, kind = "utility",
			explain = "Increases your maximum Energy by 5 per rank.",
		},
		{
			key = "bloodSplatter", name = "Blood Splatter", maxRank = 1, kind = "utility",
			explain = "Increases the duration of Rupture by 6 sec and Garrote by 9 sec.",
		},
		{
			key = "mutilate", name = "Mutilate", maxRank = 1, kind = "conditional",
			explain = "Grants Mutilate: attacks with both weapons for 90% weapon damage plus 39.6 with each weapon, dealing 20% more damage to Poisoned targets and awarding 2 Combo Points.",
		},
		{
			key = "improvedKidneyShot", name = "Improved Kidney Shot", maxRank = 2, kind = "conditional",
			explain = "Enemies stunned by your Kidney Shot take 5% more damage per rank from your poisons and attacks.",
		},
		{
			key = "sealFate", name = "Seal Fate", maxRank = 3, kind = "conditional",
			explain = "Critical strikes from abilities that add Combo Points have a 33/66/100% chance to add an extra Combo Point.",
		},
		{
			key = "venom", name = "Venom", maxRank = 1, kind = "conditional",
			explain = "Your Shank increases your Poison damage by 30% and your chance to apply Poisons by 20% for 6 sec.",
		},
		{
			key = "coupDeGrace", name = "Coup de Grace", maxRank = 3, kind = "conditional", tree = "Combat",
			explain = "Increases the damage of Eviscerate, and the damage and storage rate of Death Mark, by 7/13/20%.",
		},
		{
			key = "efficientStrikes", name = "Efficient Strikes", maxRank = 2, kind = "utility", tree = "Combat",
			explain = "Reduces the Energy cost of Sinister Strike and Hemorrhage by 3 at rank 1 and 5 at rank 2.",
		},
		{
			key = "lightningReflexes", name = "Lightning Reflexes", maxRank = 5, kind = "stat", tree = "Combat",
			effects = { { stat = "dodge", op = "flat", perRank = { 1, 2, 3, 4, 5 } } },
			explain = "Increases your Dodge chance by 1% per rank.",
		},
		{
			key = "puncturingWounds", name = "Puncturing Wounds", maxRank = 3, kind = "conditional", tree = "Combat",
			explain = "Increases the crit chance of Backstab by 10% and Mutilate by 5% per rank, and gives Backstab a 15% chance per rank to add an extra Combo Point.",
		},
		{
			key = "deflection", name = "Deflection", maxRank = 3, kind = "stat", tree = "Combat",
			effects = { { stat = "parry", op = "flat", perRank = { 2, 4, 6 } } },
			explain = "Increases your Parry chance by 2% per rank.",
		},
		{
			key = "precision", name = "Precision", maxRank = 3, kind = "stat", tree = "Combat",
			effects = { { stat = "hit", op = "flat", perRank = { 1, 2, 3 } } },
			explain = "Improves your chance to hit by 1% per rank.",
		},
		{
			key = "endurance", name = "Endurance", maxRank = 2, kind = "utility", tree = "Combat",
			explain = "Reduces the cooldown of Sprint and Evasion by 30% per rank.",
		},
		{
			key = "riposte", name = "Riposte", maxRank = 1, kind = "utility", tree = "Combat",
			explain = "Grants Riposte: after you parry, strike for 150% weapon damage and disarm the target for 6 sec (6 sec cooldown).",
		},
		{
			key = "composure", name = "Composure", maxRank = 2, kind = "utility", tree = "Combat",
			explain = "Increases the Energy cost reduction of Poised by 5 per rank.",
		},
		{
			key = "improvedSprint", name = "Improved Sprint", maxRank = 2, kind = "utility", tree = "Combat",
			explain = "Gives Sprint a 50% chance per rank to remove all movement impairing effects.",
		},
		{
			key = "improvedKick", name = "Improved Kick", maxRank = 2, kind = "utility", tree = "Combat",
			explain = "Gives Kick a 50% chance per rank to Silence the target for 2 sec.",
		},
		{
			key = "flawlessExecution", name = "Flawless Execution", maxRank = 1, kind = "utility", tree = "Combat",
			explain = "Reduces the Energy cost of Eviscerate by 15.",
		},
		{
			key = "dualWieldSpecialization", name = "Dual Wield Specialization", maxRank = 2, kind = "conditional", tree = "Combat",
			explain = "Increases the damage of your off-hand weapon by 25% per rank.",
		},
		{
			key = "bladeFlurry", name = "Blade Flurry", maxRank = 1, kind = "conditional", tree = "Combat",
			explain = "When activated, increases your melee attack speed by 20% and your melee attacks hit an additional nearby enemy for 15 sec (2 min cooldown).",
		},
		{
			key = "hackAndSlash", name = "Hack and Slash", maxRank = 5, kind = "stat", tree = "Combat",
			effects = { { stat = "meleeCrit", op = "flat", weapons = { "dagger", "fist" }, perRank = { 1, 2, 3, 4, 5 } } },
			explain = "Dagger/Fist: +1% critical strike chance per rank. Axe/Sword: 1% per rank chance for an extra attack. Mace: ignore 3% of target armor per rank.",
		},
		{
			key = "flashOfSteel", name = "Flash of Steel", maxRank = 5, kind = "utility", tree = "Combat",
			explain = "Increases the Energy generated by Shank by 3 per rank and reduces its cooldown by 0.4 sec per rank.",
		},
		{
			key = "weaponExpertise", name = "Weapon Expertise", maxRank = 2, kind = "conditional", tree = "Combat",
			explain = "Reduces the chance for your attacks to be Dodged or Parried by 1% per rank.",
		},
		{
			key = "aggression", name = "Aggression", maxRank = 3, kind = "conditional", tree = "Combat",
			explain = "Increases the damage of Sinister Strike and Eviscerate by 5% per rank.",
		},
		{
			key = "adrenalineRush", name = "Adrenaline Rush", maxRank = 1, kind = "conditional", tree = "Combat",
			explain = "When activated, increases your Energy regeneration by 100% for 15 sec (5 min cooldown).",
		},
		{
			key = "camouflage", name = "Camouflage", maxRank = 3, kind = "utility", tree = "Subtlety",
			explain = "Reduces the speed penalty of Stealth by 5% per rank and its cooldown by 2 sec per rank.",
		},
		{
			key = "masterOfDeception", name = "Master of Deception", maxRank = 3, kind = "utility", tree = "Subtlety",
			explain = "Makes you harder to detect in Stealth, as if you were 1 level higher per rank.",
		},
		{
			key = "opportunity", name = "Opportunity", maxRank = 5, kind = "conditional", tree = "Subtlety",
			explain = "Increases the damage of Backstab, Garrote, Ambush and Mutilate by 4% per rank.",
		},
		{
			key = "setup", name = "Setup", maxRank = 3, kind = "conditional", tree = "Subtlety",
			explain = "Gives a 15% chance per rank to add a Combo Point after you Dodge an attack or fully resist a spell.",
		},
		{
			key = "elusiveness", name = "Elusiveness", maxRank = 2, kind = "utility", tree = "Subtlety",
			explain = "Reduces the cooldown of Vanish and Blind by 45 sec per rank.",
		},
		{
			key = "dirtyTricks", name = "Dirty Tricks", maxRank = 2, kind = "utility", tree = "Subtlety",
			explain = "Reduces the Energy cost of Sap and Blind by 25% per rank.",
		},
		{
			key = "improvedAmbush", name = "Improved Ambush", maxRank = 3, kind = "conditional", tree = "Subtlety",
			explain = "Increases the critical strike chance of Ambush by 15% per rank.",
		},
		{
			key = "initiative", name = "Initiative", maxRank = 3, kind = "conditional", tree = "Subtlety",
			explain = "Gives a 33/67/100% chance to add an extra Combo Point with Ambush, Garrote or Cheap Shot.",
		},
		{
			key = "ghostlyStrike", name = "Ghostly Strike", maxRank = 1, kind = "conditional", tree = "Subtlety",
			explain = "Grants Ghostly Strike: a strike (stronger with a main-hand Dagger) that increases your dodge chance by 15% for 7 sec (already in the sheet while active) and lets your next Ambush or Garrote within 7 sec not require Stealth.",
		},
		{
			key = "quickGetaway", name = "Quick Getaway", maxRank = 2, kind = "utility", tree = "Subtlety",
			explain = "Increases the maximum number of Sapped targets by 1 and your movement speed by 15% per rank for 3 sec after Sapping a target.",
		},
		{
			key = "heightenedSenses", name = "Heightened Senses", maxRank = 2, kind = "conditional", tree = "Subtlety",
			explain = "Improves your Stealth detection and reduces your chance to be hit by spells and ranged attacks by 2% per rank.",
		},
		{
			key = "premeditation", name = "Premeditation", maxRank = 1, kind = "utility", tree = "Subtlety",
			explain = "Grants Premeditation: adds 2 Combo Points to your target; you must add to or use them within 20 sec or they are lost.",
		},
		{
			key = "serratedBlades", name = "Serrated Blades", maxRank = 3, kind = "conditional", tree = "Subtlety",
			explain = "Your attacks ignore 3% of your target's Armor per rank and Rupture deals 10% more damage per rank.",
		},
		{
			key = "dirtyDeeds", name = "Dirty Deeds", maxRank = 2, kind = "utility", tree = "Subtlety",
			explain = "Reduces the Energy cost of Cheap Shot and Garrote by 10 per rank; Garrote no longer requires being behind the target.",
		},
		{
			key = "preparation", name = "Preparation", maxRank = 1, kind = "utility", tree = "Subtlety",
			explain = "Grants Preparation: finishes the cooldown of your other Rogue abilities (10 min cooldown).",
		},
		{
			key = "hemorrhage", name = "Hemorrhage", maxRank = 1, kind = "conditional", tree = "Subtlety",
			explain = "Grants Hemorrhage: a strike (stronger with a Dagger) that makes the target take 15% more Rupture and Garrote damage from you for 15 sec.",
		},
		{
			key = "bootKnife", name = "Boot Knife", maxRank = 5, kind = "conditional", tree = "Subtlety",
			explain = "Gives your Shank a 20% chance per rank to add 2 Combo Points to the target.",
		},
		{
			key = "deathMark", name = "Death Mark", maxRank = 1, kind = "conditional", tree = "Subtlety",
			explain = "Finishing move that marks the target and stores 12% per Combo Point of the damage your attacks deal (Garrote and Rupture twice as much); after 6 sec the stored damage is dealt, capped by an amount that scales with Attack Power and crit chance.",
		},
	},
}
