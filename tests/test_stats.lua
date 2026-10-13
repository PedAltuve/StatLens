local S = require("wow_stubs")

local function load()
	S.reset()
	local ns = {}
	S.loadAddonFile("Core.lua", ns)
	S.loadAddonFile("Stats.lua", ns)
	return ns
end

local function fullApi()
	_G.UnitStat = function(_, i) return 100 + i, 200 + i end
	_G.UnitAttackPower = function() return 100, 20, -5 end
	_G.GetSpellBonusDamage = function(school) return school * 10 end
	_G.GetCritChance = function() return 5.5 end
	_G.GetSpellCritChance = function(school) return school == 4 and 3.25 or 0 end
	_G.GetDodgeChance = function() return 4.5 end
	_G.GetParryChance = function() return 6.5 end
end

T.test("Stats.Read reads all values", function()
	local ns = load()
	fullApi()
	local r = ns.Stats.Read()
	T.truthy(r.ok); T.eq(r.secret, false)
	local v = r.values
	T.eq(v.str, 201); T.eq(v.agi, 202); T.eq(v.stam, 203); T.eq(v.int, 204)
	T.eq(v.ap, 115, "ap = base+pos+neg")
	T.eq(v.sp, 70, "max over schools 2..7")
	T.eq(v.meleeCrit, 5.5); T.eq(v.spellCrit, 3.25); T.eq(v.dodge, 4.5); T.eq(v.parry, 6.5)
end)

T.test("Stats.Read secret value", function()
	local ns = load()
	fullApi()
	_G.issecretvalue = function(v) return v == 5.5 end
	local r = ns.Stats.Read()
	T.eq(r.ok, false); T.eq(r.secret, true)
	T.eq(r.values.str, nil, "values left nil")
	T.eq(r.values.meleeCrit, nil)
end)

T.test("Stats.Read missing/throwing API leaves nil", function()
	local ns = load()
	fullApi()
	_G.GetParryChance = nil
	_G.GetDodgeChance = function() error("x") end
	local okCall, r = pcall(ns.Stats.Read)
	T.truthy(okCall, "no error")
	T.eq(r.values.parry, nil); T.eq(r.values.dodge, nil)
	T.eq(r.values.str, 201)
end)
