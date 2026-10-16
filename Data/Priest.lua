local ADDON, ns = ...

-- Source: Forever talent tooltips (see odd/sources/priest-trees.txt).
-- Percent values are fractions. School-only hit/crit talents are conditional: the sheet shows
-- generic spell hit/crit, not per-school values.
ns.Data = ns.Data or {}

ns.Data.PRIEST = {
	tree = "Discipline",
	talents = {
		{
			key = "powerInLight", name = "Power in Light", maxRank = 5, kind = "conditional",
			explain = "Smite and Penance deal 2% more damage per rank to targets with your Holy Fire or Shadow Word: Pain.",
		},
		{
			key = "wandSpecialization", name = "Wand Specialization", maxRank = 2, kind = "conditional",
			explain = "Increases your wand damage by 13% at rank 1 and 25% at rank 2.",
		},
		{
			key = "twinDisciplines", name = "Twin Disciplines", maxRank = 5, kind = "conditional",
			explain = "Increases the damage and healing of your instant cast spells by 1% per rank.",
		},
		{
			key = "silentResolve", name = "Silent Resolve", maxRank = 3, kind = "utility",
			explain = "Reduces the threat of your spells by 10% per rank and the duration of Stun, Fear and Silence effects on you by 5% per rank.",
		},
		{
			key = "holyPrecision", name = "Holy Precision", maxRank = 3, kind = "conditional",
			explain = "Improves your chance to hit with Holy spells by 6% per rank (Holy spells only, so it is not shown as spell hit).",
		},
		{
			key = "mentalStrength", name = "Mental Strength", maxRank = 5, kind = "stat",
			effects = { { stat = "int", op = "pct", perRank = { 0.02, 0.04, 0.06, 0.08, 0.10 } } },
			explain = "Increases your total Intellect by 2% per rank.",
		},
		{
			key = "martyrdom", name = "Martyrdom", maxRank = 2, kind = "conditional",
			explain = "50% chance per rank after a melee or ranged crit against you to gain Focused Casting for 6 sec (no pushback, +20% interrupt resistance).",
		},
		{
			key = "mentalAgility", name = "Mental Agility", maxRank = 3, kind = "utility",
			explain = "Reduces the mana cost of Smite, Holy Fire and instant cast spells by 3% at rank 1 and 10% at rank 3.",
		},
		{
			key = "innerFocus", name = "Inner Focus", maxRank = 1, kind = "conditional",
			explain = "When activated, your next spell costs no mana and gains +25% critical effect chance if it is non-periodic (3 min cooldown).",
		},
		{
			key = "improvedPowerWordShield", name = "Improved Power Word: Shield", maxRank = 3, kind = "conditional",
			explain = "Increases the damage absorbed by Power Word: Shield by 7% at rank 1 and 20% at rank 3.",
		},
		{
			key = "meditation", name = "Meditation", maxRank = 3, kind = "conditional",
			explain = "Allows 17% of your mana regeneration to continue while casting at rank 1 and 50% at rank 3.",
		},
		{
			key = "improvedInnerFire", name = "Improved Inner Fire", maxRank = 3, kind = "conditional",
			explain = "Increases the armor bonus of Inner Fire by 15% per rank and its charges by 4 per rank.",
		},
		{
			key = "improvedManaBurn", name = "Improved Mana Burn", maxRank = 2, kind = "utility",
			explain = "Reduces the cast time of Mana Burn by 0.5 sec per rank.",
		},
		{
			key = "soulWarding", name = "Soul Warding", maxRank = 1, kind = "utility",
			explain = "Reduces the cooldown of Power Word: Shield by 4 sec and its mana cost by 15%.",
		},
		{
			key = "penance", name = "Penance", maxRank = 1, kind = "utility",
			explain = "Grants Penance: a holy volley that damages an enemy or heals an ally instantly and every 1 sec for 2 sec (12 sec cooldown).",
		},
		{
			key = "renewedHope", name = "Renewed Hope", maxRank = 5, kind = "conditional",
			explain = "Your direct heals gain 2% critical chance per rank on targets with Weakened Soul and shorten it by 1 sec per rank.",
		},
		{
			key = "divineAegis", name = "Divine Aegis", maxRank = 3, kind = "conditional",
			explain = "Your non-periodic critical heals shield the target for 5% per rank of the amount healed (up to 1200, 12 sec).",
		},
		{
			key = "powerInfusion", name = "Power Infusion", maxRank = 1, kind = "conditional",
			explain = "Increases the target's spell damage and healing by 20% for 15 sec (3 min cooldown).",
		},
		{
			key = "twilightFocus", name = "Twilight Focus", maxRank = 3, kind = "conditional", tree = "Holy",
			explain = "Gives your spells a 23% chance at rank 1 (70% at rank 3) to lose no casting time when you take damage.",
		},
		{
			key = "improvedRenew", name = "Improved Renew", maxRank = 3, kind = "conditional", tree = "Holy",
			explain = "Increases the amount healed by Renew by 5% per rank.",
		},
		{
			key = "holySpecialization", name = "Holy Specialization", maxRank = 5, kind = "conditional", tree = "Holy",
			explain = "Increases the critical effect chance of your Holy spells by 1% per rank (Holy spells only, so it is not shown as spell crit).",
		},
		{
			key = "spellWarding", name = "Spell Warding", maxRank = 5, kind = "utility", tree = "Holy",
			explain = "Reduces all spell damage taken by 2% per rank.",
		},
		{
			key = "divineFury", name = "Divine Fury", maxRank = 5, kind = "utility", tree = "Holy",
			explain = "Reduces the cast time of Smite, Holy Fire, Heal and Greater Heal by 0.1 sec per rank.",
		},
		{
			key = "holyNova", name = "Holy Nova", maxRank = 1, kind = "utility", tree = "Holy",
			explain = "Grants Holy Nova: Holy damage to nearby enemies and healing to nearby party members, with no threat.",
		},
		{
			key = "blessedRecovery", name = "Blessed Recovery", maxRank = 3, kind = "conditional", tree = "Holy",
			explain = "After a crit or a big hit against you, heals 8% at rank 1 (25% at rank 3) of the damage taken over 6 sec.",
		},
		{
			key = "inspiration", name = "Inspiration", maxRank = 3, kind = "conditional", tree = "Holy",
			explain = "Your non-periodic critical heals increase the target's armor by 8% at rank 1 and 25% at rank 3 for 15 sec.",
		},
		{
			key = "holyReach", name = "Holy Reach", maxRank = 2, kind = "utility", tree = "Holy",
			explain = "Increases the range of Smite and Holy Fire and the radius of Prayer of Healing and Holy Nova by 10% per rank.",
		},
		{
			key = "improvedHealing", name = "Improved Healing", maxRank = 3, kind = "utility", tree = "Holy",
			explain = "Reduces the mana cost of Lesser Heal, Heal, Greater Heal, Penance and Prayer of Mending by 5% per rank.",
		},
		{
			key = "searingLight", name = "Searing Light", maxRank = 2, kind = "conditional", tree = "Holy",
			explain = "Increases your Holy damage by 2% at rank 1 and 5% at rank 2; Holy Fire ticks can make your next Holy Nova free.",
		},
		{
			key = "bindingHeal", name = "Binding Heal", maxRank = 1, kind = "utility", tree = "Holy",
			explain = "Grants Binding Heal: heals a friendly target and yourself.",
		},
		{
			key = "litanyOfLight", name = "Litany of Light", maxRank = 2, kind = "conditional", tree = "Holy",
			explain = "Casting a heal different from your previous one refunds 5% per rank of its base mana cost.",
		},
		{
			key = "spiritOfRedemption", name = "Spirit of Redemption", maxRank = 1, kind = "utility", tree = "Holy",
			explain = "On death you become the Spirit of Redemption for 15 sec and can cast healing spells for free.",
		},
		{
			key = "spiritualGuidance", name = "Spiritual Guidance", maxRank = 5, kind = "stat", tree = "Holy",
			effects = {
				{ stat = "heal", op = "fromStat", source = "spirit", perRank = { 0.05, 0.10, 0.15, 0.20, 0.25 } },
				{ stat = "sp", op = "fromStat", source = "spirit", perRank = { 0.01, 0.0275, 0.045, 0.0625, 0.08 } },
			},
			explain = "Increases spell healing by 5% per rank of your total Spirit and spell damage by 1% at rank 1 up to 8% at rank 5; middle-rank spell damage values are inferred.",
			inferred = { rank = true },
		},
		{
			key = "spiritualHealing", name = "Spiritual Healing", maxRank = 3, kind = "conditional", tree = "Holy",
			explain = "Increases the amount healed by your spells by 3% at rank 1 and 10% at rank 3.",
		},
		{
			key = "prayerOfMending", name = "Prayer of Mending", maxRank = 1, kind = "utility", tree = "Holy",
			explain = "Grants Prayer of Mending: a heal that triggers when the target takes damage and then jumps up to 5 times (10 sec cooldown).",
		},
		{
			key = "shadowFocus", name = "Shadow Focus", maxRank = 5, kind = "conditional", tree = "Shadow Magic",
			explain = "Improves your chance to hit with Shadow spells by 1% per rank (Shadow spells only, so it is not shown as spell hit).",
		},
		{
			key = "blackout", name = "Blackout", maxRank = 5, kind = "conditional", tree = "Shadow Magic",
			explain = "Gives your Shadow damage spells a 2% chance per rank to stun the target for 3 sec.",
		},
		{
			key = "spiritTap", name = "Spirit Tap", maxRank = 5, kind = "conditional", tree = "Shadow Magic",
			explain = "20% chance per rank after a kill to double your Spirit for 15 sec, with 50% of mana regeneration continuing while casting.",
		},
		{
			key = "improvedMindBlast", name = "Improved Mind Blast", maxRank = 5, kind = "utility", tree = "Shadow Magic",
			explain = "Reduces the cooldown of Mind Blast by 0.5 sec per rank.",
		},
		{
			key = "improvedShadowWordPain", name = "Improved Shadow Word: Pain", maxRank = 2, kind = "utility", tree = "Shadow Magic",
			explain = "Increases the duration of Shadow Word: Pain by 3 sec per rank.",
		},
		{
			key = "shadowReach", name = "Shadow Reach", maxRank = 2, kind = "utility", tree = "Shadow Magic",
			explain = "Increases the range of your offensive Shadow spells by 10% per rank.",
		},
		{
			key = "improvedPsychicScream", name = "Improved Psychic Scream", maxRank = 2, kind = "utility", tree = "Shadow Magic",
			explain = "Reduces the cooldown of Psychic Scream by 2 sec per rank.",
		},
		{
			key = "mindFlay", name = "Mind Flay", maxRank = 1, kind = "utility", tree = "Shadow Magic",
			explain = "Grants Mind Flay: Shadow damage over 3 sec that slows the target by 50%.",
		},
		{
			key = "improvedMindFlay", name = "Improved Mind Flay", maxRank = 2, kind = "conditional", tree = "Shadow Magic",
			explain = "Each Mind Flay tick deals 10% more damage per rank than the previous one.",
		},
		{
			key = "darkInspiration", name = "Dark Inspiration", maxRank = 5, kind = "conditional", tree = "Shadow Magic",
			explain = "Mind Blast and fully channeled Mind Flay increase your and your party's Spirit by 3% per rank for 10 sec.",
		},
		{
			key = "vampiricEmbrace", name = "Vampiric Embrace", maxRank = 1, kind = "utility", tree = "Shadow Magic",
			explain = "Grants Vampiric Embrace: your party is healed for 20% of the Shadow damage you deal for 30 sec.",
		},
		{
			key = "shadowWeaving", name = "Shadow Weaving", maxRank = 3, kind = "conditional", tree = "Shadow Magic",
			explain = "Your Shadow damage spells have a 33% chance per rank to increase the Shadow damage the target takes from you by 2%, stacking up to 5 times.",
		},
		{
			key = "silence", name = "Silence", maxRank = 1, kind = "utility", tree = "Shadow Magic",
			explain = "Grants Silence: silences the target for 5 sec (45 sec cooldown).",
		},
		{
			key = "devouringContagion", name = "Devouring Contagion", maxRank = 2, kind = "utility", tree = "Shadow Magic",
			explain = "Reduces the mana cost of Devouring Plague by 25% per rank; it spreads to 2 nearby enemies when the target dies.",
		},
		{
			key = "earlyDemise", name = "Early Demise", maxRank = 2, kind = "conditional", tree = "Shadow Magic",
			explain = "Increases Shadow Word: Death's critical strike chance on targets at or below 20% health by 15% per rank.",
		},
		{
			key = "darkness", name = "Darkness", maxRank = 5, kind = "conditional", tree = "Shadow Magic",
			explain = "Increases your Shadow damage by 2% per rank.",
		},
		{
			key = "shadowform", name = "Shadowform", maxRank = 1, kind = "conditional", tree = "Shadow Magic",
			explain = "In Shadowform: +10% Shadow damage, 50% cheaper Shadow spells, +100% Shadow critical damage bonus and 15% less Physical damage taken; no healing spells.",
		},
	},
}
