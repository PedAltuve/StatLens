local ADDON, ns = ...

-- Source: Forever build 1.60.1.70755 live tooltips (odd/sources/paladin-trees-70755.txt).
-- Percent values are fractions; flat hit/crit/dodge/parry/block values are percentage points.
-- School-only hit talents are conditional: the sheet shows generic spell hit, not per-school values.
ns.Data = ns.Data or {}

ns.Data.PALADIN = {
	tree = "Holy",
	talents = {
		{
			key = "divineStrength", name = "Divine Strength", maxRank = 5, kind = "stat",
			effects = { { stat = "str", op = "pct", perRank = { 0.02, 0.04, 0.06, 0.08, 0.10 } } },
			explain = "Increases your Strength by 2% per rank.",
		},
		{
			key = "divineIntellect", name = "Divine Intellect", maxRank = 5, kind = "stat", tree = "Protection",
			effects = { { stat = "int", op = "pct", perRank = { 0.02, 0.04, 0.06, 0.08, 0.10 } } },
			explain = "Increases your total Intellect by 2% per rank.",
		},
		{
			key = "healingLight", name = "Healing Light", maxRank = 3, kind = "conditional",
			explain = "Increases the healing of Holy Light, Flash of Light and Holy Shock by 4% per rank.",
		},
		{
			key = "spiritualFocus", name = "Spiritual Focus", maxRank = 5, kind = "conditional",
			explain = "Gives Flash of Light, Holy Light and Light's Vigil a 14% chance per rank to lose no casting time when you take damage.",
		},
		{
			key = "improvedSeals", name = "Improved Seals", maxRank = 5, kind = "conditional",
			explain = "Increases the damage of your Seals and Judgements by 3% per rank.",
		},
		{
			key = "unyieldingFaith", name = "Unyielding Faith", maxRank = 2, kind = "utility", tree = "Retribution",
			explain = "Reduces the duration of Fear and Disorient effects on you by 15% per rank.",
		},
		{
			key = "oathOfLight", name = "Oath of Light", maxRank = 1, kind = "utility",
			explain = "Protects one ally for 5 min, increasing Holy Light healing on them by up to 400, Flash of Light by up to 115 and Holy Shock by up to 230. Only one Oath may be active.",
		},
		{
			key = "reverence", name = "Reverence", maxRank = 2, kind = "conditional",
			explain = "Allows 15% per rank of your mana regeneration to continue while casting.",
		},
		{
			key = "purifyingPower", name = "Purifying Power", maxRank = 2, kind = "utility",
			explain = "Reduces the mana cost of Cleanse and Purify by 10% per rank and the cooldown of Exorcism and Holy Wrath by 17% at rank 1 and 33% at rank 2.",
		},
		{
			key = "infusionOfLight", name = "Infusion of Light", maxRank = 2, kind = "conditional",
			explain = "Holy Shock and Flash of Light crits reduce the cast time of your next Holy Light within 15 sec by 0.5 sec per rank.",
		},
		{
			key = "illumination", name = "Illumination", maxRank = 5, kind = "conditional",
			explain = "Critical heals from Flash of Light, Holy Light, Light's Vigil or Holy Shock have a 20% chance per rank to refund 50% of the base mana cost.",
		},
		{
			key = "divineFavor", name = "Divine Favor", maxRank = 1, kind = "utility",
			explain = "Your next Flash of Light, Holy Light or Holy Shock is a guaranteed critical effect (2 min cooldown).",
		},
		{
			key = "divinePrecision", name = "Divine Precision", maxRank = 2, kind = "conditional",
			explain = "Improves your chance to hit with Holy spells by 4% per rank and reduces Silence duration by 10% per rank. Holy-only hit is not shown as generic spell hit.",
		},
		{
			key = "holyShock", name = "Holy Shock", maxRank = 1, kind = "utility",
			explain = "Grants Holy Shock: instant Holy damage to an enemy or healing to an ally (10 sec cooldown).",
		},
		{
			key = "consecratedGround", name = "Consecrated Ground", maxRank = 2, kind = "conditional",
			explain = "Your Holy spells deal 5% more damage per rank to the first 4 enemies that enter your Consecration.",
		},
		{
			key = "holyPower", name = "Holy Power", maxRank = 5, kind = "conditional",
			explain = "Increases the critical strike healing bonus of your Holy spells by 10% per rank.",
		},
		{
			key = "boundlessLight", name = "Boundless Light", maxRank = 2, kind = "conditional",
			explain = "Increases Holy Shock critical strike chance by 15% per rank when healing allies not affected by your Oath of Light.",
		},
		{
			key = "lightsVigil", name = "Light's Vigil", maxRank = 1, kind = "utility",
			explain = "Applies Light's Vigil to a friendly target for 30 sec. Your next Holy Shock on them has no cooldown and heals them and their party for 325 to 344. Only one Vigil per Paladin may be active in each party.",
		},
		{
			key = "toughness", name = "Toughness", maxRank = 5, kind = "stat", tree = "Protection",
			effects = { { stat = "armor", op = "pct", perRank = { 0.02, 0.04, 0.06, 0.08, 0.10 } } },
			explain = "Increases armor from items by 2% per rank. StatLens applies it to total armor, so its share is slightly overstated.",
			inferred = { rank = true },
		},
		{
			key = "redoubt", name = "Redoubt", maxRank = 5, kind = "conditional", tree = "Protection",
			explain = "Damaging melee attacks against you have a 10% chance to increase your block chance by 6% per rank for 10 sec or 5 blocks.",
		},
		{
			key = "precision", name = "Precision", maxRank = 3, kind = "stat", tree = "Protection",
			effects = {
				{ stat = "hit", op = "flat", perRank = { 1, 2, 3 } },
				{ stat = "spellHit", op = "flat", perRank = { 1, 2, 3 } },
			},
			explain = "Improves your chance to hit by 1% per rank.",
		},
		{
			key = "guardiansFavor", name = "Guardian's Favor", maxRank = 2, kind = "utility", tree = "Protection",
			explain = "Reduces the cooldown of Blessing of Protection by 1 min per rank and extends Blessing of Freedom by 3 sec per rank.",
		},
		{
			key = "anticipation", name = "Anticipation", maxRank = 5, kind = "stat", tree = "Protection",
			effects = {
				{ stat = "defense", op = "flat", perRank = { 4, 8, 12, 16, 20 } },
				{ stat = "dodge", op = "flat", perRank = { 0.16, 0.32, 0.48, 0.64, 0.8 } },
				{ stat = "parry", op = "flat", perRank = { 0.16, 0.32, 0.48, 0.64, 0.8 } },
				{ stat = "block", op = "flat", perRank = { 0.16, 0.32, 0.48, 0.64, 0.8 } },
			},
			explain = "Increases your Defense skill by 4 per rank. Dodge, parry and block gain 0.04% per Defense point (a Classic rule, so the derived values are inferred); block is not shield-gated here.",
			inferred = { rank = true },
		},
		{
			key = "stoicism", name = "Stoicism", maxRank = 2, kind = "utility", tree = "Protection",
			explain = "Reduces the duration of Stun and Charm effects on you by 10% per rank.",
		},
		{
			key = "improvedRighteousFury", name = "Improved Righteous Fury", maxRank = 3, kind = "conditional", tree = "Protection",
			explain = "While Righteous Fury is active, all damage taken is reduced by 3% per rank.",
		},
		{
			key = "shieldSpecialization", name = "Shield Specialization", maxRank = 2, kind = "conditional", tree = "Protection",
			explain = "Increases shield absorption by 15% per rank and gives blocks a 50% chance per rank to restore 4% of your maximum mana, at most once every 3 sec.",
		},
		{
			key = "sacredDuty", name = "Sacred Duty", maxRank = 2, kind = "utility", tree = "Protection",
			explain = "Reduces the cooldown of Divine Shield, Divine Protection and Templar's Bulwark by 30 sec per rank and the duration of Forbearance by 5 sec per rank.",
		},
		{
			key = "swiftJudgement", name = "Swift Judgement", maxRank = 1, kind = "utility", tree = "Protection",
			explain = "Unleashes your Seal's Judgement effect on an enemy without consuming the Seal. Does not share a cooldown with Judgement.",
		},
		{
			key = "shieldsworn", name = "Shieldsworn", maxRank = 1, kind = "conditional", tree = "Protection",
			explain = "Reduces Holy Strike's cooldown by 4 sec. Holy Strike uses your shield, triggering active Holy Shield and Shield Specialization without consuming charges or triggering cooldowns, and lets you block spells for 6 sec.",
		},
		{
			key = "improvedHammerOfJustice", name = "Improved Hammer of Justice", maxRank = 3, kind = "utility", tree = "Protection",
			explain = "Reduces the cooldown of Hammer of Justice by 5 sec per rank.",
		},
		{
			key = "templarsBulwark", name = "Templar's Bulwark", maxRank = 1, kind = "utility", tree = "Protection",
			explain = "Grants Templar's Bulwark: an absorb shield equal to your maximum health for 8 sec (5 min cooldown, applies Forbearance).",
		},
		{
			key = "reckoning", name = "Reckoning", maxRank = 5, kind = "conditional", tree = "Protection",
			explain = "Gives an 8% chance per rank after blocking, and 20% per rank after a non-periodic critical strike against you, to gain an extra attack (stores up to 4). Block procs can occur at most once every 1.5 sec.",
		},
		{
			key = "ironCreed", name = "Iron Creed", maxRank = 3, kind = "conditional", tree = "Protection",
			explain = "Increases Holy Strike threat by 10% per rank; with Righteous Fury, Holy Strike also reduces damage taken by 2% per rank for 6 sec.",
		},
		{
			key = "holyShield", name = "Holy Shield", maxRank = 1, kind = "conditional", tree = "Protection",
			explain = "Increases your block chance by 30% for 10 sec (4 charges), dealing 75 Holy damage on each block with 20% additional threat.",
		},
		{
			key = "deflection", name = "Deflection", maxRank = 5, kind = "stat", tree = "Retribution",
			effects = { { stat = "parry", op = "flat", perRank = { 1, 2, 3, 4, 5 } } },
			explain = "Increases your parry chance by 1% per rank.",
		},
		{
			key = "benediction", name = "Benediction", maxRank = 5, kind = "utility", tree = "Retribution",
			explain = "Reduces the mana cost of all instant cast spells and abilities by 2% per rank.",
		},
		{
			key = "improvedJudgement", name = "Improved Judgement", maxRank = 2, kind = "utility", tree = "Retribution",
			explain = "Reduces the cooldown of Judgement by 1 sec per rank.",
		},
		{
			key = "holyConduit", name = "Holy Conduit", maxRank = 2, kind = "utility", tree = "Holy",
			explain = "Reduces the mana cost of Consecration, Holy Wrath, Exorcism and Hammer of Wrath by 20% per rank.",
		},
		{
			key = "conviction", name = "Conviction", maxRank = 3, kind = "stat", tree = "Retribution",
			effects = {
				{ stat = "meleeCrit", op = "flat", perRank = { 2, 4, 6 } },
				{ stat = "spellCrit", op = "flat", perRank = { 2, 4, 6 } },
			},
			explain = "Improves your critical strike chance with all spells and attacks by 2% per rank.",
		},
		{
			key = "vindication", name = "Vindication", maxRank = 3, kind = "conditional", tree = "Retribution",
			explain = "Your melee attacks have a chance to reduce the target's Strength and Agility by 5% for 10 sec.",
		},
		{
			key = "sanctifiedJudgement", name = "Sanctified Judgement", maxRank = 3, kind = "conditional", tree = "Retribution",
			explain = "Gives Judgement a 33/66/100% chance to refund 20/40/60% of the judged seal's mana cost.",
		},
		{
			key = "sealOfCommand", name = "Seal of Command", maxRank = 1, kind = "conditional", tree = "Retribution",
			explain = "Grants Seal of Command for 30 sec: a chance on hit to deal extra Holy damage equal to 70% of weapon damage. Judgement deals 74 Holy damage, or 136 to 148 against stunned or incapacitated targets.",
		},
		{
			key = "pursuitOfJustice", name = "Pursuit of Justice", maxRank = 2, kind = "utility", tree = "Retribution",
			explain = "Increases movement and mounted speed by 8% at rank 1 and 15% at rank 2 (does not stack with other speed effects).",
		},
		{
			key = "eyeForAnEye", name = "Eye for an Eye", maxRank = 2, kind = "conditional", tree = "Retribution",
			explain = "Critical strikes against you deal 5% per rank of the damage taken back to the attacker, capped at 50% of your total health.",
		},
		{
			key = "sacredArbiter", name = "Sacred Arbiter", maxRank = 1, kind = "conditional", tree = "Retribution",
			explain = "Increases Holy Strike damage by 20% and makes it refresh your Judgement effects on the target.",
		},
		{
			key = "twoHandedWeaponSpecialization", name = "Two-Handed Weapon Specialization", maxRank = 3, kind = "conditional", tree = "Retribution",
			explain = "While a two-handed melee weapon is equipped, increases your Physical and Holy damage by 2% per rank and reduces all threat by 7/14/20%.",
		},
		{
			key = "vengeance", name = "Vengeance", maxRank = 3, kind = "conditional", tree = "Retribution",
			explain = "After a non-periodic critical strike, increases your Physical and Holy damage by 1% per rank for 30 sec, stacking up to 5 times.",
		},
		{
			key = "repentance", name = "Repentance", maxRank = 1, kind = "utility", tree = "Retribution",
			explain = "Grants Repentance: incapacitates a Humanoid for up to 6 sec; damage breaks it (1 min cooldown).",
		},
		{
			key = "championOfTheLight", name = "Champion of the Light", maxRank = 5, kind = "stat", tree = "Retribution",
			effects = { { stat = "sp", op = "fromStat", source = "int", perRank = { 0.12, 0.24, 0.36, 0.48, 0.60 } } },
			explain = "Increases your spell damage by up to 12% of your Intellect per rank and reduces Hammer of Wrath's cast time by 0.2 sec per rank.",
		},
		{
			key = "turnEvil", name = "Turn Evil", maxRank = 2, kind = "utility", tree = "Retribution",
			explain = "Reduces Turn Undead's cast time by 0.5 sec per rank and cooldown by 5 sec per rank, and allows it to affect Demons.",
		},
		{
			key = "unsealedWrath", name = "Unsealed Wrath", maxRank = 1, kind = "conditional", tree = "Retribution",
			explain = "Melee attacks store your active Seal for 15 sec, up to 3 stacks. Attacking with a different Seal consumes the stacks, giving the stored Seal its normal chance to activate once per stack.",
		},
	},
}
