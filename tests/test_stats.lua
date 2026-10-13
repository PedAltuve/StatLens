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

T.test("Stats.Read level, heal, armor", function()
	local ns = load()
	fullApi()
	_G.UnitLevel = function() return 25 end
	_G.GetSpellBonusHealing = function() return 88 end
	_G.UnitArmor = function() return 500, 640, 0, 0 end
	local v = ns.Stats.Read().values
	T.eq(v.level, 25); T.eq(v.heal, 88); T.eq(v.armor, 640, "effective armor")
end)

T.test("Stats.Read form mapping", function()
	local ns = load()
	fullApi()
	local id
	_G.GetShapeshiftFormID = function() return id end
	local cases = { { 1, "cat" }, { 5, "bear" }, { 8, "bear" }, { 31, "moonkin" }, { 99, "form:99" } }
	for _, c in ipairs(cases) do
		id = c[1]
		T.eq(ns.Stats.Read().values.form, c[2], "form " .. c[1])
		T.eq(ns.Stats.formID, c[1], "raw formID")
	end
	id = nil
	T.eq(ns.Stats.Read().values.form, nil, "nil id"); T.eq(ns.Stats.formID, nil)
	id = 0
	T.eq(ns.Stats.Read().values.form, nil, "0 id")
	T.eq(ns.Stats.FORMS[8], "bear")
end)

T.test("Stats.Read new values missing API -> nil, no error", function()
	local ns = load()
	fullApi()
	local ok, r = pcall(ns.Stats.Read)
	T.truthy(ok and r.ok)
	T.eq(r.values.level, nil); T.eq(r.values.heal, nil); T.eq(r.values.armor, nil); T.eq(r.values.form, nil)
end)

T.test("Stats.Read secret form id", function()
	local ns = load()
	fullApi()
	_G.GetShapeshiftFormID = function() return 1 end
	_G.issecretvalue = function(v) return v == 1 end
	local r = ns.Stats.Read()
	T.eq(r.secret, true); T.eq(r.ok, false)
end)

T.test("/sl form prints raw id and mapped name", function()
	local ns = load()
	_G.GetShapeshiftFormID = function() return 8 end
	SlashCmdList.STATLENS("form")
	local all = table.concat(S.chat, "\n")
	T.truthy(all:find("8", 1, true) and all:find("bear", 1, true), "raw + mapped")
	S.chat = {}
	_G.GetShapeshiftFormID = function() return nil end
	SlashCmdList.STATLENS("form")
	T.truthy(table.concat(S.chat, "\n"):find("none", 1, true), "no form")
	S.chat = {}
	_G.GetShapeshiftFormID = nil
	SlashCmdList.STATLENS("form")
	T.truthy(table.concat(S.chat, "\n"):find("form id: none", 1, true), "missing API prints none")
end)
