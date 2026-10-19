local ADDON, ns = ...

-- Source: Forever talent tooltips (see odd/sources/mage-trees.txt).
-- Percent values are fractions; flat hit/crit values are percentage points.
-- School-only hit and crit talents are conditional: the sheet shows generic spell hit and crit.
ns.Data = ns.Data or {}

ns.Data.MAGE = {
	tree = "Arcane",
	talents = {
		{
			key = "wandSpecialization", name = "Wand Specialization", maxRank = 2, kind = "conditional",
			explain = "Increases your damage with Wands by 13% at rank 1 and 25% at rank 2.",
		},
		{
			key = "arcaneFocus", name = "Arcane Focus", maxRank = 5, kind = "conditional",
			explain = "Improves your chance to hit with Arcane spells by 1% per rank (not shown in the sheet's spell hit).",
		},
		{
			key = "improvedChanneling", name = "Improved Channeling", maxRank = 5, kind = "conditional",
			explain = "Gives Arcane Missiles a 20% chance per rank, and Arcane Blast and Arcane Wrath 14% per rank, to lose no casting time when you take damage.",
		},
		{
			key = "missileBarrage", name = "Missile Barrage", maxRank = 2, kind = "conditional",
			explain = "Your damage spells can make your next Arcane Missiles free, faster and twice as quick to fire (Arcane Blast 20% per rank, others 10% per rank).",
		},
		{
			key = "arcaneSubtlety", name = "Arcane Subtlety", maxRank = 2, kind = "conditional",
			explain = "Reduces your target's resistance to your spells by 8/15 and the threat of your Arcane spells by 15% per rank.",
		},
		{
			key = "magicAbsorption", name = "Magic Absorption", maxRank = 2, kind = "conditional",
			explain = "Increases all resistances by 5 per rank (resistances are not tracked by StatLens) and fully resisted spells restore 1% of your mana per rank.",
		},
		{
			key = "arcaneConcentration", name = "Arcane Concentration", maxRank = 5, kind = "conditional",
			explain = "Gives a 2% chance per rank to enter Clearcasting after a damage spell hits, making your next damage spell free.",
		},
		{
			key = "arcaneResilience", name = "Arcane Resilience", maxRank = 2, kind = "stat",
			effects = { { stat = "armor", op = "fromStat", source = "int", perRank = { 0.25, 0.50 } } },
			explain = "Increases your Armor by 25% of your Intellect per rank.",
		},
		{
			key = "arcaneGeometry", name = "Arcane Geometry", maxRank = 2, kind = "utility",
			explain = "Increases the range of your Arcane spells by 3 yards per rank.",
		},
		{
			key = "arcaneImpact", name = "Arcane Impact", maxRank = 3, kind = "conditional",
			explain = "Increases the critical strike chance of your Arcane spells by 2% per rank (not shown in the sheet's crit).",
		},
		{
			key = "arcaneBlast", name = "Arcane Blast", maxRank = 1, kind = "utility",
			explain = "Grants Arcane Blast: each cast adds 15% of your Intellect as spell damage and raises its mana cost, stacking up to 4 times.",
		},
		{
			key = "arcaneShielding", name = "Arcane Shielding", maxRank = 2, kind = "conditional",
			explain = "Reduces mana lost per damage taken with Mana Shield by 17/33% and increases Mage Armor resistances by 25% per rank.",
		},
		{
			key = "improvedCounterspell", name = "Improved Counterspell", maxRank = 2, kind = "utility",
			explain = "Your Counterspell also silences the target for 2 sec per rank.",
		},
		{
			key = "arcaneMeditation", name = "Arcane Meditation", maxRank = 3, kind = "conditional",
			explain = "Allows 17% of your mana regeneration at rank 1 and 50% at rank 3 to continue while casting.",
		},
		{
			key = "arcaneWrath", name = "Arcane Wrath", maxRank = 1, kind = "utility",
			explain = "Grants Arcane Wrath: an Arcane projectile that gains spell damage equal to 5% of your maximum mana (6 sec cooldown).",
		},
		{
			key = "presenceOfMind", name = "Presence of Mind", maxRank = 1, kind = "utility",
			explain = "Grants Presence of Mind: your next Mage spell with a cast time under 10 sec becomes instant (3 min cooldown).",
		},
		{
			key = "arcaneMind", name = "Arcane Mind", maxRank = 5, kind = "stat",
			effects = { { stat = "int", op = "pct", perRank = { 0.02, 0.04, 0.06, 0.08, 0.10 } } },
			explain = "Increases your Intellect by 2% per rank and the critical strike damage bonus of your Arcane spells by 20% per rank.",
		},
		{
			key = "arcaneInstability", name = "Arcane Instability", maxRank = 3, kind = "stat",
			effects = {
				{ stat = "meleeCrit", op = "flat", perRank = { 1, 2, 3 } },
				{ stat = "spellCrit", op = "flat", perRank = { 1, 2, 3 } },
			},
			explain = "Increases your critical strike chance and your spell damage by 1% per rank.",
		},
		{
			key = "arcanePower", name = "Arcane Power", maxRank = 1, kind = "conditional",
			explain = "Grants Arcane Power: your spells deal 30% more damage and cost 30% more mana for 15 sec (3 min cooldown).",
		},
		{
			key = "improvedFireBlast", name = "Improved Fire Blast", maxRank = 2, kind = "utility", tree = "Fire",
			explain = "Reduces the cooldown of Fire Blast by 1 sec per rank and increases its range by 8/15 yards.",
		},
		{
			key = "incineration", name = "Incineration", maxRank = 3, kind = "conditional", tree = "Fire",
			explain = "Increases the critical strike chance of Fire Blast, Ice Lance, Arcane Blast and Scorch by 2% per rank.",
		},
		{
			key = "improvedFireball", name = "Improved Fireball", maxRank = 5, kind = "utility", tree = "Fire",
			explain = "Reduces the cast time of Fireball and Frostfire Bolt by 0.1 sec per rank.",
		},
		{
			key = "ignite", name = "Ignite", maxRank = 5, kind = "conditional", tree = "Fire",
			explain = "Fire spell crits burn the target for an extra 8% per rank of the spell's damage over 4 sec.",
		},
		{
			key = "flameThrowing", name = "Flame Throwing", maxRank = 2, kind = "utility", tree = "Fire",
			explain = "Increases the range of your Fire spells by 3 yards per rank.",
		},
		{
			key = "impact", name = "Impact", maxRank = 3, kind = "conditional", tree = "Fire",
			explain = "Gives your Fire spells a chance to stun the target for 2 sec (3% at rank 1, 10% at rank 3).",
		},
		{
			key = "burningSoul", name = "Burning Soul", maxRank = 3, kind = "conditional", tree = "Fire",
			explain = "Gives your Fire spells a 23% chance per rank to lose no casting time when you take damage and reduces their threat by 10% per rank.",
		},
		{
			key = "improvedFlamestrike", name = "Improved Flamestrike", maxRank = 3, kind = "conditional", tree = "Fire",
			explain = "Increases the critical strike chance of Flamestrike by 5% per rank.",
		},
		{
			key = "pyroblast", name = "Pyroblast", maxRank = 1, kind = "utility", tree = "Fire",
			explain = "Grants Pyroblast: a slow, heavy Fire spell with damage over time.",
		},
		{
			key = "improvedScorch", name = "Improved Scorch", maxRank = 3, kind = "conditional", tree = "Fire",
			explain = "Scorch has a 33% chance per rank to make the target take 3% more Fire damage from you, stacking up to 5 times.",
		},
		{
			key = "improvedFireWard", name = "Improved Fire Ward", maxRank = 2, kind = "conditional", tree = "Fire",
			explain = "Gives Fire Ward a 10% chance per rank to reflect Fire spells.",
		},
		{
			key = "heatingUp", name = "Heating Up", maxRank = 1, kind = "conditional", tree = "Fire",
			explain = "Crits with Fireball, Frostfire Bolt, Fire Blast and Scorch reduce the cast time of your next Pyroblast by 25%, stacking up to 3 times.",
		},
		{
			key = "masterOfElements", name = "Master of Elements", maxRank = 3, kind = "conditional", tree = "Fire",
			explain = "Your Fire and Frost crits refund 10% per rank of their base mana cost.",
		},
		{
			key = "criticalMass", name = "Critical Mass", maxRank = 5, kind = "conditional", tree = "Fire",
			explain = "Increases the critical strike chance of your Fire spells by 2% per rank (not shown in the sheet's crit).",
		},
		{
			key = "blastWave", name = "Blast Wave", maxRank = 1, kind = "utility", tree = "Fire",
			explain = "Grants Blast Wave: Fire damage to nearby enemies that dazes them for 6 sec (45 sec cooldown).",
		},
		{
			key = "firePower", name = "Fire Power", maxRank = 3, kind = "conditional", tree = "Fire",
			explain = "Increases your Fire spell damage by 1% per rank for each of your Fire effects on the target, up to 4% per rank.",
		},
		{
			key = "combustion", name = "Combustion", maxRank = 1, kind = "conditional", tree = "Fire",
			explain = "Grants Combustion: each Fire spell hit adds 10% Fire crit chance until you land 3 Fire crits (3 min cooldown).",
		},
		{
			key = "frostWarding", name = "Frost Warding", maxRank = 2, kind = "conditional", tree = "Frost",
			explain = "Increases the Armor and resistance of Frost Armor and Ice Armor by 15% per rank and gives Frost Ward a 10% chance per rank to reflect Frost spells.",
		},
		{
			key = "improvedFrostbolt", name = "Improved Frostbolt", maxRank = 5, kind = "utility", tree = "Frost",
			explain = "Reduces the cast time of Frostbolt and Frost Blast by 0.1 sec per rank.",
		},
		{
			key = "elementalPrecision", name = "Elemental Precision", maxRank = 5, kind = "conditional", tree = "Frost",
			explain = "Improves your chance to hit with Frost and Fire spells by 1% per rank (not shown in the sheet's spell hit).",
		},
		{
			key = "iceShards", name = "Ice Shards", maxRank = 5, kind = "conditional", tree = "Frost",
			explain = "Increases the critical strike damage bonus of your Frost spells by 20% per rank.",
		},
		{
			key = "frostbite", name = "Frostbite", maxRank = 3, kind = "conditional", tree = "Frost",
			explain = "Gives your Chill effects a 5% chance per rank to freeze the target for 5 sec.",
		},
		{
			key = "improvedFrostNova", name = "Improved Frost Nova", maxRank = 2, kind = "utility", tree = "Frost",
			explain = "Reduces the cooldown of Frost Nova by 2 sec per rank.",
		},
		{
			key = "permafrost", name = "Permafrost", maxRank = 3, kind = "conditional", tree = "Frost",
			explain = "Increases the duration of your Chill effects by 11% at rank 1 and 33% at rank 3, and slows the target further.",
		},
		{
			key = "piercingIce", name = "Piercing Ice", maxRank = 3, kind = "conditional", tree = "Frost",
			explain = "Increases the damage of your Frost spells by 2% per rank.",
		},
		{
			key = "frostChanneling", name = "Frost Channeling", maxRank = 3, kind = "conditional", tree = "Frost",
			explain = "Reduces the mana cost of your Frost spells by 5% per rank and their threat by 10% per rank.",
		},
		{
			key = "iceLance", name = "Ice Lance", maxRank = 1, kind = "utility", tree = "Frost",
			explain = "Grants Ice Lance: an instant Frost attack that deals 200% more damage to frozen targets.",
		},
		{
			key = "improvedBlizzard", name = "Improved Blizzard", maxRank = 3, kind = "conditional", tree = "Frost",
			explain = "Adds a Chill effect to Blizzard that slows targets (15% at rank 1, 40% at rank 3).",
		},
		{
			key = "arcticReach", name = "Arctic Reach", maxRank = 2, kind = "utility", tree = "Frost",
			explain = "Increases the range of Frostbolt, Frost Blast and Blizzard and the radius of Frost Nova and Cone of Cold by 10% per rank.",
		},
		{
			key = "iceBlock", name = "Ice Block", maxRank = 1, kind = "utility", tree = "Frost",
			explain = "Grants Ice Block: immunity to all attacks and spells for 10 sec, but you cannot act (5 min cooldown).",
		},
		{
			key = "shatter", name = "Shatter", maxRank = 3, kind = "conditional", tree = "Frost",
			explain = "Increases the critical strike chance of all your spells against frozen targets by 17% at rank 1 and 50% at rank 3.",
		},
		{
			key = "improvedConeOfCold", name = "Improved Cone of Cold", maxRank = 3, kind = "conditional", tree = "Frost",
			explain = "Increases the damage of Cone of Cold by 12% at rank 1 and 35% at rank 3.",
		},
		{
			key = "coldSnap", name = "Cold Snap", maxRank = 1, kind = "utility", tree = "Frost",
			explain = "Grants Cold Snap: finishes the cooldown of all your other Frost spells (10 min cooldown).",
		},
		{
			key = "fingersOfFrost", name = "Fingers of Frost", maxRank = 2, kind = "conditional", tree = "Frost",
			explain = "Your Chill effects have a 15% chance to treat your next spell (2 spells at rank 2) as if the target were frozen.",
		},
		{
			key = "wintersChill", name = "Winter's Chill", maxRank = 5, kind = "conditional", tree = "Frost",
			explain = "Frostbolt, Frost Blast and empowered Ice Lance have a 20% chance per rank to empower your next Cone of Cold, stacking up to 5 times.",
		},
		{
			key = "iceBarrier", name = "Ice Barrier", maxRank = 1, kind = "utility", tree = "Frost",
			explain = "Grants Ice Barrier: a shield that absorbs damage and prevents cast interruption while it holds (30 sec cooldown).",
		},
	},
}
