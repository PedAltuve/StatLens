local S = require("wow_stubs")

local function load()
	S.reset()
	local ns = {}
	for _, f in ipairs({ "Core.lua", "Data/Warrior.lua", "Calc.lua", "Format.lua" }) do S.loadAddonFile(f, ns) end
	return ns, ns.Data.WARRIOR
end

local function texts(ns, d, v, ranks)
	local out = {}
	for i, l in ipairs(ns.Format.Lines(ns.Calc.Breakdown(v, ranks, d), ranks, d)) do out[i] = l.kind .. "|" .. l.text end
	return out
end

T.test("Weaponmaster: active with axe, inactive with sword", function()
	local ns, d = load()
	local ranks = { weaponmaster = 5 }
	local v = { meleeCrit = 15, mainHand = "axe" }
	local b = ns.Calc.Breakdown(v, ranks, d)
	T.eq(b.talents.weaponmaster.contributions.meleeCrit, 5)
	local got = texts(ns, d, v, ranks)
	T.eq(got[1], "stat|Melee Crit 15.0% (talents +5.0%)")
	T.eq(got[2], "part|Weaponmaster 5/5: +5.0%")

	v.mainHand = "sword"
	b = ns.Calc.Breakdown(v, ranks, d)
	T.eq(b.talents.weaponmaster.inactive.meleeCrit, 5)
	got = texts(ns, d, v, ranks)
	T.eq(got[1], "stat|Melee Crit 15.0%")
	T.eq(got[2], "inactive|Weaponmaster 5/5: +5.0% with an Axe or Polearm")
end)

T.test("Shield Specialization: needs a shield", function()
	local ns, d = load()
	local ranks = { shieldSpecialization = 5 }
	local b = ns.Calc.Breakdown({ block = 10, offHand = "shield" }, ranks, d)
	T.eq(b.talents.shieldSpecialization.contributions.block, 5)
	b = ns.Calc.Breakdown({ block = 10, offHand = "offhand" }, ranks, d)
	T.eq(b.talents.shieldSpecialization.inactive.block, 5)
	T.eq(b.stats.block.talentTotal, 0)
	local got = texts(ns, d, { block = 10 }, ranks)
	T.eq(got[2], "inactive|Shield Specialization 5/5: +5.0% with a shield")
end)

T.test("Anticipation: defense plus derived dodge/parry/block", function()
	local ns, d = load()
	local ranks = { anticipation = 5 }
	local v = { defense = 300, dodge = 5, parry = 6, block = 7 }
	local b = ns.Calc.Breakdown(v, ranks, d)
	local c = b.talents.anticipation.contributions
	T.eq(c.defense, 20)
	T.near(c.dodge, 0.8, 1e-9); T.near(c.parry, 0.8, 1e-9); T.near(c.block, 0.8, 1e-9)
	local entry
	for _, t in ipairs(d.talents) do if t.key == "anticipation" then entry = t end end
	T.eq(entry.inferred.rank, true)
	T.eq(entry.maxRank, 5)
end)

T.test("Cruelty and Deflection are flat", function()
	local ns, d = load()
	local b = ns.Calc.Breakdown({ meleeCrit = 12, parry = 8 }, { cruelty = 4, deflection = 3 }, d)
	T.eq(b.talents.cruelty.contributions.meleeCrit, 4)
	T.eq(b.talents.deflection.contributions.parry, 3)
end)

local function entry(d, key)
	for _, t in ipairs(d.talents) do if t.key == key then return t end end
end

T.test("build 70755: Raging Blows removed, Reckless Swings and Improved Whirlwind added", function()
	local _, d = load()
	T.eq(entry(d, "ragingBlows"), nil)
	local rs = entry(d, "recklessSwings")
	T.eq(rs and rs.name, "Reckless Swings"); T.eq(rs and rs.tree, "Fury"); T.eq(rs and rs.maxRank, 1)
	local iw = entry(d, "improvedWhirlwind")
	T.eq(iw and iw.name, "Improved Whirlwind"); T.eq(iw and iw.tree, "Fury"); T.eq(iw and iw.maxRank, 2)
end)

T.test("build 70755: max rank changes", function()
	local _, d = load()
	T.eq(entry(d, "improvedTacticalMastery").maxRank, 3)
	T.eq(entry(d, "bloodthrill").maxRank, 2)
	T.eq(entry(d, "flurry").maxRank, 3)
	T.eq(entry(d, "defiance").maxRank, 3)
end)

T.test("build 70755: sheet-stat per-rank values are unchanged", function()
	local _, d = load()
	local function per(key, i) return table.concat(entry(d, key).effects[i or 1].perRank, ",") end
	T.eq(per("deflection"), "1,2,3,4,5")
	T.eq(per("weaponmaster"), "1,2,3,4,5")
	T.eq(per("cruelty"), "1,2,3,4,5")
	T.eq(per("shieldSpecialization"), "1,2,3,4,5")
	T.eq(per("anticipation"), "4,8,12,16,20")
end)

T.test("build 70755: explain texts match live values", function()
	local _, d = load()
	local function has(key, s, want)
		local e = entry(d, key)
		local found = e and e.explain:find(s, 1, true) ~= nil
		T.eq(found, want ~= false, key .. " explain: " .. s)
	end
	has("improvedTacticalMastery", "5 additional Rage per rank")
	has("spearingStrike", "75% weapon damage")
	has("spearingStrike", "75% more")
	has("twoHandedWeaponSpecialization", "2% per rank")
	has("bloodthrill", "10% chance per rank")
	has("bloodthrill", "6 sec", false)
	has("improvedSlam", "2.5 sec per rank")
	has("flurry", "10% per rank")
	has("improvedWhirlwind", "15% per rank")
	has("recklessSwings", "5 additional Rage")
	has("defiance", "7% at rank 1, up to 20% at rank 3")
	has("boomingVoice", "5% per rank", false)
end)
