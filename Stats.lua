local ADDON, ns = ...

local Stats = {}
ns.Stats = Stats

-- GetShapeshiftFormID -> short form name used by `forms` in talent data.
Stats.FORMS = { [1] = "cat", [5] = "bear", [8] = "bear", [31] = "moonkin" }

-- Weapon subclass (classID 2) -> short kind used by `weapons` in talent data.
Stats.WEAPONS = {
	[0] = "axe", [1] = "axe", [4] = "mace", [5] = "mace", [6] = "polearm", [7] = "sword", [8] = "sword",
	[10] = "staff", [13] = "fist", [15] = "dagger", [2] = "bow", [3] = "gun", [18] = "crossbow",
	[19] = "wand", [16] = "thrown",
}

-- Call fn(...) under pcall; return all results, or nothing on error / missing API.
local function try(fn, ...)
	if type(fn) ~= "function" then return end
	local res = { pcall(fn, ...) }
	if res[1] then return unpack(res, 2) end
end

local function formName(id)
	if id == nil or id == 0 then return nil end
	return Stats.FORMS[id] or ("form:" .. tostring(id))
end

-- Returns true and the first secret among the given values, or false. The flag is separate so callers
-- never test or compare the secret itself; a secret component is never summed.
local function firstSecret(...)
	for i = 1, select("#", ...) do
		local x = select(i, ...)
		if ns.IsSecret(x) then return true, x end
	end
	return false
end

-- Kind of the item in an equipment slot: weapon kind, "shield", "offhand", or nil. A secret id is
-- returned raw so Read() can flag it.
local function slotKind(slot)
	local id = try(GetInventoryItemID, "player", slot)
	if id == nil then return nil end
	if ns.IsSecret(id) then return id end
	local info = C_Item and C_Item.GetItemInfoInstant
	local _, _, _, _, _, classID, subClassID = try(info, id)
	if classID == 2 then return Stats.WEAPONS[subClassID] or ("weapon:" .. tostring(subClassID)) end
	if slot == 17 and classID == 4 then return subClassID == 6 and "shield" or "offhand" end
end

local function readValues()
	local v = {}
	local names = { "str", "agi", "stam", "int", "spirit" }
	for i, name in ipairs(names) do
		local _, effective = try(UnitStat, "player", i)
		v[name] = effective
	end

	local base, pos, neg = try(UnitAttackPower, "player")
	if base ~= nil and pos ~= nil and neg ~= nil then
		-- A secret component poisons the sum; keep it as-is so the caller can detect it.
		local hasSecret, secret = firstSecret(base, pos, neg)
		if hasSecret then v.ap = secret else v.ap = base + pos + neg end
	end

	local sp
	for school = 2, 7 do
		local x = try(GetSpellBonusDamage, school)
		if x ~= nil then
			if ns.IsSecret(x) then sp = x break end
			if sp == nil or x > sp then sp = x end
		end
	end
	v.sp = sp

	v.meleeCrit = try(GetCritChance)
	v.spellCrit = try(GetSpellCritChance, 4)
	v.dodge = try(GetDodgeChance)
	v.parry = try(GetParryChance)

	v.hit = try(GetHitModifier)
	v.spellHit = try(GetSpellHitModifier)
	v.health = try(UnitHealthMax, "player")

	v.level = try(UnitLevel, "player")
	v.heal = try(GetSpellBonusHealing)
	local _, armor = try(UnitArmor, "player")
	v.armor = armor

	v.block = try(GetBlockChance)
	local defBase, defMod = try(UnitDefense, "player")
	if defBase ~= nil and defMod ~= nil then
		local hasSecret, secret = firstSecret(defBase, defMod)
		if hasSecret then v.defense = secret else v.defense = defBase + defMod end
	end

	v.mainHand = slotKind(16)
	v.offHand = slotKind(17)

	local formID = try(GetShapeshiftFormID)
	Stats.formID = formID
	if ns.IsSecret(formID) then
		-- Kept raw so Read() can flag it; never build strings from it.
		v.form = formID
	else
		v.form = formName(formID)
	end
	return v
end

function Stats.Read()
	local values = readValues()
	for _, x in pairs(values) do
		if ns.IsSecret(x) then
			return { ok = false, secret = true, values = {} }
		end
	end
	return { ok = true, secret = false, values = values }
end

-- In-game validation: shows what the client reports and how we map it.
ns.commands.form = function()
	local id = try(GetShapeshiftFormID)
	if ns.IsSecret(id) then return ns.Print("form id: <secret>") end
	ns.Print(("form id: %s -> %s"):format(id == nil and "none" or tostring(id), formName(id) or "none"))
end
