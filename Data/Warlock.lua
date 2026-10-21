local ADDON, ns = ...

-- Source: Forever talent tooltips (see odd/sources/warlock-trees.txt).
-- Percent values are fractions; flat hit values are percentage points.
-- School-only, pet and spell-specific bonuses are conditional: the sheet does not show them.
ns.Data = ns.Data or {}

ns.Data.WARLOCK = {
	tree = "Affliction",
	talents = {
		{
			key = "improvedLifeTap", name = "Improved Life Tap", maxRank = 2, kind = "conditional",
			explain = "Increases the Mana gained from Life Tap by 10% per rank.",
		},
		{
			key = "suppression", name = "Suppression", maxRank = 5, kind = "stat",
			effects = {
				{ stat = "hit", op = "flat", perRank = { 1, 2, 3, 4, 5 } },
				{ stat = "spellHit", op = "flat", perRank = { 1, 2, 3, 4, 5 } },
			},
			explain = "Improves your chance to hit by 1% per rank and reduces all threat you generate by 4% per rank.",
		},
		{
			key = "improvedCorruption", name = "Improved Corruption", maxRank = 5, kind = "conditional",
			explain = "Reduces Corruption's casting time by 0.4 sec and increases its damage by 2% per rank.",
		},
		{
			key = "grimReach", name = "Grim Reach", maxRank = 2, kind = "utility",
			explain = "Increases the range of your Affliction spells by 10% per rank.",
		},
		{
			key = "soulHarvest", name = "Soul Harvest", maxRank = 2, kind = "conditional",
			explain = "Killing a target afflicted by your Drain Soul increases Mana regeneration by 50% per rank for 10 sec and lets 50% per rank continue while casting.",
		},
		{
			key = "improvedDrains", name = "Improved Drains", maxRank = 3, kind = "conditional",
			explain = "Increases health drained or damage done by Drain Life, Drain Soul and Wrack by 7% at rank 1, up to 20% at rank 3.",
		},
		{
			key = "improvedBaneOfAgony", name = "Improved Bane of Agony", maxRank = 2, kind = "conditional",
			explain = "Increases the damage of Bane of Agony by 5% per rank.",
		},
		{
			key = "felConcentration", name = "Fel Concentration", maxRank = 3, kind = "conditional",
			explain = "Gives Drain Life, Drain Mana, Drain Soul and Wrack a chance to lose no casting time when you take damage (23% at rank 1, up to 70% at rank 3).",
		},
		{
			key = "amplifyCurse", name = "Amplify Curse", maxRank = 1, kind = "conditional",
			explain = "Increases the effect of your next Curse of Weakness or Bane of Agony by 50%, or Curse of Exhaustion by 20% (3 min cooldown).",
		},
		{
			key = "pandemic", name = "Pandemic", maxRank = 3, kind = "conditional",
			explain = "Increases the critical strike damage bonus of Corruption, Banes, drains, Siphon Life and Wrack by 33% at rank 1, up to 100% at rank 3.",
		},
		{
			key = "malevolence", name = "Malevolence", maxRank = 5, kind = "conditional",
			explain = "Increases the critical effect chance of your Shadow spells by 1% per rank (Shadow spells only, not shown in the sheet's spell crit).",
		},
		{
			key = "nightfall", name = "Nightfall", maxRank = 2, kind = "conditional",
			explain = "Corruption, Drain Soul, Drain Life and Wrack have a 2% chance per rank to make your next Shadow Bolt instant.",
		},
		{
			key = "curseOfExhaustion", name = "Curse of Exhaustion", maxRank = 1, kind = "utility",
			explain = "Grants Curse of Exhaustion: reduces the target's movement speed by 30% for 12 sec.",
		},
		{
			key = "siphonLife", name = "Siphon Life", maxRank = 1, kind = "conditional",
			explain = "Grants Siphon Life: transfers health from the target to you every 3 sec for 30 sec.",
		},
		{
			key = "soulSiphon", name = "Soul Siphon", maxRank = 3, kind = "conditional",
			explain = "Drain Life, Drain Soul and Wrack deal 4% more per rank for each of your other Affliction effects on the target, up to 12% per rank.",
		},
		{
			key = "shadowMastery", name = "Shadow Mastery", maxRank = 5, kind = "conditional",
			explain = "Increases the damage dealt or life drained by your Shadow spells by 2% per rank.",
		},
		{
			key = "wrack", name = "Wrack", maxRank = 1, kind = "conditional",
			explain = "Grants Wrack: Shadow damage every sec for 6 sec, and the target takes 10% more damage from your other Shadow damage over time effects.",
		},
		{
			key = "improvedHealthFunnel", name = "Improved Health Funnel", maxRank = 2, kind = "conditional", tree = "Demonology",
			explain = "Health Funnel transfers 20% more health and costs 15% less health per rank, generates 50% less threat per rank, and works at any demon health.",
		},
		{
			key = "improvedImp", name = "Improved Imp", maxRank = 3, kind = "conditional", tree = "Demonology",
			explain = "Increases the damage of your Imp's Firebolt and the effect of its Fire Shield by 10% per rank.",
		},
		{
			key = "demonicEmbrace", name = "Demonic Embrace", maxRank = 5, kind = "stat", tree = "Demonology",
			effects = { { stat = "stam", op = "pct", perRank = { 0.03, 0.06, 0.09, 0.12, 0.15 } } },
			explain = "Increases your total Stamina by 3% per rank.",
		},
		{
			key = "unholyPower", name = "Unholy Power", maxRank = 5, kind = "conditional", tree = "Demonology",
			explain = "Increases all damage done by your Imp, Voidwalker, Succubus, Incubus and Felhunter by 2% per rank.",
		},
		{
			key = "demonicAegis", name = "Demonic Aegis", maxRank = 2, kind = "conditional", tree = "Demonology",
			explain = "Increases the effectiveness of Demon Skin and Demon Armor by 15% per rank.",
		},
		{
			key = "improvedVoidwalker", name = "Improved Voidwalker", maxRank = 3, kind = "conditional", tree = "Demonology",
			explain = "Increases the effectiveness of your Voidwalker's Torment, Consume Shadows, Sacrifice and Suffering by 10% per rank.",
		},
		{
			key = "felVitality", name = "Fel Vitality", maxRank = 3, kind = "conditional", tree = "Demonology",
			explain = "Increases your maximum Mana by 5% per rank (mana is not tracked by StatLens) and your demon's maximum health and Mana by 5% per rank.",
		},
		{
			key = "demonicEnergies", name = "Demonic Energies", maxRank = 2, kind = "conditional", tree = "Demonology",
			explain = "You heal your pet for 8/15% of your spell damage, and your demon gains 50% per rank of the Mana you get from Life Tap.",
		},
		{
			key = "improvedSayaad", name = "Improved Sayaad", maxRank = 3, kind = "conditional", tree = "Demonology",
			explain = "Increases your Succubus' and Incubus' Lash of Pain and Soothing Kiss effects and Seduction and Lesser Invisibility durations by 10% per rank.",
		},
		{
			key = "demonicSacrifice", name = "Demonic Sacrifice", maxRank = 1, kind = "conditional", tree = "Demonology",
			explain = "Sacrifices your demon for a 2 hr effect: Imp +15% Shadow damage, Voidwalker 2% Mana every 4 sec, Succubus/Incubus +15% Fire damage, Felhunter 3% Health every 4 sec.",
		},
		{
			key = "masterSummoner", name = "Master Summoner", maxRank = 2, kind = "utility", tree = "Demonology",
			explain = "Reduces the casting time of your demon summons by 2 sec and their Mana cost by 20% per rank.",
		},
		{
			key = "decimation", name = "Decimation", maxRank = 2, kind = "conditional", tree = "Demonology",
			explain = "Reduces Soul Fire's cooldown by 45% per rank; Shadow Bolt or Searing Pain on targets below 35% health makes them deal 3% more damage per rank and speeds up your next Soul Fire.",
		},
		{
			key = "felDomination", name = "Fel Domination", maxRank = 1, kind = "utility", tree = "Demonology",
			explain = "Grants Fel Domination: your next demon summon is 5.5 sec faster and costs 50% less Mana (5 min cooldown).",
		},
		{
			key = "demonicBrand", name = "Demonic Brand", maxRank = 3, kind = "conditional", tree = "Demonology",
			explain = "Searing Pain generates less threat and brands the target; your pet's next 2 attacks per rank against it deal extra Fire or Shadow damage.",
		},
		{
			key = "improvedFelhunter", name = "Improved Felhunter", maxRank = 3, kind = "conditional", tree = "Demonology",
			explain = "Improves your Felhunter's Tainted Blood, Devour Magic and Paranoia by 10% per rank and reduces Spell Lock's cooldown by 2 sec per rank.",
		},
		{
			key = "soulLink", name = "Soul Link", maxRank = 1, kind = "conditional", tree = "Demonology",
			explain = "Grants Soul Link: 30% of the damage you take goes to your demon, and you both deal 3% more damage while it is active.",
		},
		{
			key = "demonicKnowledge", name = "Demonic Knowledge", maxRank = 3, kind = "stat", tree = "Demonology",
			effects = { { stat = "sp", op = "perLevel", pet = true, perRank = { 0.33, 0.67, 1.00 } } },
			explain = "While you have a summoned Demon pet, increases your spell damage by up to 33% of your level per rank (100% at rank 3); also applies to your pet.",
			inferred = { rank = true },
		},
		{
			key = "masterDemonologist", name = "Master Demonologist", maxRank = 5, kind = "conditional", tree = "Demonology",
			explain = "While your demon is active, you both gain 2% per rank: Imp more Fire damage, Voidwalker less Physical damage taken, Succubus/Incubus more Shadow damage, Felhunter less Magic damage taken.",
		},
		{
			key = "demonicPact", name = "Demonic Pact", maxRank = 1, kind = "conditional", tree = "Demonology",
			explain = "Your Demonic Sacrifice effect is no longer cancelled by summoning a different demon.",
		},
		{
			key = "destructiveReach", name = "Destructive Reach", maxRank = 2, kind = "utility", tree = "Destruction",
			explain = "Increases the range of your Destruction spells by 10% per rank.",
		},
		{
			key = "improvedShadowBolt", name = "Improved Shadow Bolt", maxRank = 5, kind = "conditional", tree = "Destruction",
			explain = "Shadow Bolt critical strikes increase the Shadow damage the target takes from you by 4% per rank for 12 sec.",
		},
		{
			key = "bane", name = "Bane", maxRank = 5, kind = "utility", tree = "Destruction",
			explain = "Reduces the casting time of Shadow Bolt, Immolate and Incinerate by 0.1 sec and Soul Fire by 0.4 sec per rank.",
		},
		{
			key = "moltenSkin", name = "Molten Skin", maxRank = 5, kind = "conditional", tree = "Destruction",
			explain = "Reduces all damage taken by 2% per rank (damage reduction is not a sheet stat).",
		},
		{
			key = "cataclysm", name = "Cataclysm", maxRank = 3, kind = "utility", tree = "Destruction",
			explain = "Reduces the Mana cost of your Destruction spells by 3% at rank 1, up to 10% at rank 3.",
		},
		{
			key = "aftermath", name = "Aftermath", maxRank = 5, kind = "conditional", tree = "Destruction",
			explain = "Increases Immolate's initial damage by 10% per rank, and Conflagrate has a 20% chance per rank to Daze the target for 5 sec.",
		},
		{
			key = "ruin", name = "Ruin", maxRank = 5, kind = "conditional", tree = "Destruction",
			explain = "Increases the critical strike damage bonus of your Destruction spells by 20% per rank.",
		},
		{
			key = "shadowburn", name = "Shadowburn", maxRank = 1, kind = "utility", tree = "Destruction",
			explain = "Grants Shadowburn: instant Shadow damage, and you gain a Soul Shard if the target dies within 8 sec (15 sec cooldown).",
		},
		{
			key = "intensity", name = "Intensity", maxRank = 3, kind = "conditional", tree = "Destruction",
			explain = "Gives your Destruction spells a chance to lose no casting time when you take damage (23% at rank 1, up to 70% at rank 3).",
		},
		{
			key = "agonizingFlames", name = "Agonizing Flames", maxRank = 3, kind = "conditional", tree = "Destruction",
			explain = "Increases Searing Pain's critical strike chance and the damage of all your Destruction spells by 3% at rank 1, up to 10% at rank 3.",
		},
		{
			key = "conflagrate", name = "Conflagrate", maxRank = 1, kind = "utility", tree = "Destruction",
			explain = "Grants Conflagrate: consumes your Immolate on the target to deal Fire damage (10 sec cooldown).",
		},
		{
			key = "pyroclasm", name = "Pyroclasm", maxRank = 2, kind = "conditional", tree = "Destruction",
			explain = "Soul Fire, Rain of Fire and Hellfire have a 13% chance per rank to stun targets for 3 sec.",
		},
		{
			key = "baneOfHavoc", name = "Bane of Havoc", maxRank = 1, kind = "utility", tree = "Destruction",
			explain = "Grants Bane of Havoc: 15% of your damage to other targets is also dealt to the afflicted target for 5 min.",
		},
		{
			key = "fireAndBrimstone", name = "Fire and Brimstone", maxRank = 3, kind = "conditional", tree = "Destruction",
			explain = "Increases the critical strike chance of Conflagrate by 8% at rank 1, up to 25% at rank 3.",
		},
		{
			key = "shadowAndFlame", name = "Shadow and Flame", maxRank = 5, kind = "conditional", tree = "Destruction",
			explain = "Conflagrate raises your Shadow damage and Shadowburn your Fire damage by 2% per rank for 20 sec; each has a 20% chance per rank to keep Immolate or refund a Soul Shard.",
		},
		{
			key = "incinerate", name = "Incinerate", maxRank = 1, kind = "utility", tree = "Destruction",
			explain = "Grants Incinerate: a Fire spell that deals 25% more damage to targets afflicted by Immolate.",
		},
	},
}
