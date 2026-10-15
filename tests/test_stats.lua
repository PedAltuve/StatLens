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

T.test("Stats.Read spirit, hit, spellHit, health", function()
	local ns = load()
	fullApi()
	_G.UnitStat = function(_, i) return 100 + i, 200 + i end
	_G.GetHitModifier = function() return 1.5 end
	_G.GetSpellHitModifier = function() return 2.5 end
	_G.UnitHealthMax = function() return 850 end
	local v = ns.Stats.Read().values
	T.eq(v.spirit, 205, "UnitStat 5 effective"); T.eq(v.hit, 1.5); T.eq(v.spellHit, 2.5); T.eq(v.health, 850)
end)

T.test("Stats.Read new values: missing API nil, secret flagged", function()
	local ns = load()
	fullApi()
	_G.UnitStat = function(_, i) return 1, 2 end
	local r = ns.Stats.Read()
	T.truthy(r.ok); T.eq(r.values.hit, nil); T.eq(r.values.spellHit, nil); T.eq(r.values.health, nil)
	_G.UnitHealthMax = function() return 777 end
	_G.issecretvalue = function(v) return v == 777 end
	r = ns.Stats.Read()
	T.eq(r.secret, true); T.eq(r.ok, false)
end)

local function items(map)
	-- map: slot -> { classID, subClassID }; item id = slot * 100
	_G.GetInventoryItemID = function(_, slot) return map[slot] and slot * 100 or nil end
	_G.C_Item = { GetItemInfoInstant = function(id)
		local m = map[id / 100]
		return id, "t", "s", "loc", 1, m[1], m[2]
	end }
end

T.test("Stats.Read block and defense", function()
	local ns = load()
	fullApi()
	_G.GetBlockChance = function() return 12.5 end
	_G.UnitDefense = function() return 25, 3 end
	local v = ns.Stats.Read().values
	T.eq(v.block, 12.5); T.eq(v.defense, 28)
end)

T.test("Stats.Read weapon kinds", function()
	local ns = load()
	fullApi()
	local cases = {
		{ { [16] = { 2, 1 } }, "axe", nil },
		{ { [16] = { 2, 8 } }, "sword", nil },
		{ { [16] = { 2, 7 }, [17] = { 4, 6 } }, "sword", "shield" },
		{ { [16] = { 2, 4 }, [17] = { 4, 0 } }, "mace", "offhand" },
		{ { [16] = { 2, 15 }, [17] = { 2, 13 } }, "dagger", "fist" },
		{ { [16] = { 2, 99 } }, "weapon:99", nil },
		{ {}, nil, nil },
	}
	for i, c in ipairs(cases) do
		items(c[1])
		local v = ns.Stats.Read().values
		T.eq(v.mainHand, c[2], "main " .. i); T.eq(v.offHand, c[3], "off " .. i)
	end
	T.eq(ns.Stats.WEAPONS[6], "polearm"); T.eq(ns.Stats.WEAPONS[10], "staff")
end)

T.test("Stats.Read equipment: missing API, secret", function()
	local ns = load()
	fullApi()
	local r = ns.Stats.Read()
	T.truthy(r.ok); T.eq(r.values.mainHand, nil)
	items({ [16] = { 2, 1 } })
	_G.issecretvalue = function(v) return v == 1600 end
	r = ns.Stats.Read()
	T.eq(r.secret, true); T.eq(r.ok, false)
end)

T.test("Stats.Read AP/defense: plain components still sum", function()
	local ns = load()
	fullApi()
	_G.UnitAttackPower = function() return 100, 20, -5 end
	_G.UnitDefense = function() return 300, 12 end
	local r = ns.Stats.Read()
	T.truthy(r.ok); T.eq(r.values.ap, 115); T.eq(r.values.defense, 312)
end)

T.test("Stats.Read AP with only a non-base component secret", function()
	for _, secretAt in ipairs({ 2, 3 }) do
		local ns = load()
		fullApi()
		_G.UnitAttackPower = function() return 100, secretAt == 2 and 777 or 20, secretAt == 3 and 888 or -5 end
		_G.issecretvalue = function(v) return v == 777 or v == 888 end
		local ok, r = pcall(ns.Stats.Read)
		T.truthy(ok, "no error " .. secretAt)
		T.eq(r.ok, false, "ok " .. secretAt); T.eq(r.secret, true, "secret " .. secretAt)
	end
end)

T.test("Stats.Read defense with only the modifier secret", function()
	local ns = load()
	fullApi()
	_G.UnitDefense = function() return 300, 555 end
	_G.issecretvalue = function(v) return v == 555 end
	local ok, r = pcall(ns.Stats.Read)
	T.truthy(ok, "no error")
	T.eq(r.ok, false); T.eq(r.secret, true)
end)
