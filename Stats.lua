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
	-- Keep the exact result count: `#` on a table with nil holes is unreliable.
	local res = { n = 0 }
	local function pack(...) res.n = select("#", ...) for i = 1, res.n do res[i] = (select(i, ...)) end end
	pack(pcall(fn, ...))
	if res[1] then return unpack(res, 2, res.n) end
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

-- Kind of the item in an equipment slot: weapon kind, "shield", "offhand", or nil. A secret id,
-- classID or subClassID means unknown (nil), like an empty slot; it is a condition input, not a stat.
local function slotKind(slot)
	local id = try(GetInventoryItemID, "player", slot)
	if ns.IsSecret(id) then return nil end
	if id == nil then return nil end
	local info = C_Item and C_Item.GetItemInfoInstant
	local _, _, _, _, _, classID, subClassID = try(info, id)
	-- Never compare, concatenate or index with a secret.
	if firstSecret(classID, subClassID) then return nil end
	if classID == 2 then return Stats.WEAPONS[subClassID] or ("weapon:" .. tostring(subClassID)) end
	if slot == 17 and classID == 4 then return subClassID == 6 and "shield" or "offhand" end
end

-- Sum of a multi-part read (base, buffs...). The secret check runs before any nil test or
-- arithmetic: a secret component is returned as-is so Read() can flag it; any of the `n`
-- expected parts missing gives nil.
local function sumParts(n, ...)
	local hasSecret, secret = firstSecret(...)
	if hasSecret then return secret end
	local total = 0
	for i = 1, n do
		local x = select(i, ...)
		if x == nil then return nil end
		total = total + x
	end
	return total
end

local function readValues()
	local v = {}
	local names = { "str", "agi", "stam", "int", "spirit" }
	for i, name in ipairs(names) do
		local _, effective = try(UnitStat, "player", i)
		v[name] = effective
	end

	v.ap = sumParts(3, try(UnitAttackPower, "player"))
	v.rangedAp = sumParts(3, try(UnitRangedAttackPower, "player"))

	local sp
	for school = 2, 7 do
		local x = try(GetSpellBonusDamage, school)
		-- Secret check first: only a known-plain value may be nil-tested or compared.
		if ns.IsSecret(x) then sp = x break end
		if x ~= nil and (sp == nil or x > sp) then sp = x end
	end
	v.sp = sp

	v.meleeCrit = try(GetCritChance)
	v.rangedCrit = try(GetRangedCritChance)
	v.spellCrit = try(GetSpellCritChance, 4)
	v.dodge = try(GetDodgeChance)
	v.parry = try(GetParryChance)

	v.hit = try(GetHitModifier)
	v.spellHit = try(GetSpellHitModifier)
	v.health = try(UnitHealthMax, "player")

	-- Level only feeds perLevel effects: a secret level is unknown, not a frozen stat.
	local level = try(UnitLevel, "player")
	if ns.IsSecret(level) then v.level = nil else v.level = level end
	v.heal = try(GetSpellBonusHealing)
	local _, armor = try(UnitArmor, "player")
	v.armor = armor

	v.block = try(GetBlockChance)
	v.defense = sumParts(2, try(UnitDefense, "player"))

	-- Pet state only gates `pet` effects; a secret answer means unknown (inactive) rather than
	-- flagging the whole read. Never test the value before the secret check.
	local pet = try(UnitExists, "pet")
	if ns.IsSecret(pet) then v.pet = nil else v.pet = pet end

	v.mainHand = slotKind(16)
	v.offHand = slotKind(17)

	local formID = try(GetShapeshiftFormID)
	if ns.IsSecret(formID) then
		-- Unknown form; never keep or build strings from the secret.
		Stats.formID, v.form = nil, nil
	else
		Stats.formID, v.form = formID, formName(formID)
	end
	return v
end

-- Stats the panel displays; `ok` is false only when none of them is plain and at least one is secret.
Stats.DISPLAYED = {
	"str", "agi", "stam", "int", "spirit", "ap", "rangedAp", "sp", "heal", "meleeCrit", "rangedCrit",
	"spellCrit", "hit", "spellHit", "dodge", "parry", "block", "defense", "armor", "health",
}

-- Secret values are removed from `values` (Calc skips nil stats) and listed in `secretStats`.
function Stats.Read()
	local values, secretStats, secret = readValues(), {}, false
	for k, x in pairs(values) do
		if ns.IsSecret(x) then
			values[k], secretStats[k], secret = nil, true, true
		end
	end
	local anyPlain = false
	for _, k in ipairs(Stats.DISPLAYED) do
		if values[k] ~= nil then anyPlain = true break end
	end
	return { ok = anyPlain or not secret, secret = secret, values = values, secretStats = secretStats }
end

-- In-game validation: shows what the client reports and how we map it.
ns.commands.form = function()
	local id = try(GetShapeshiftFormID)
	if ns.IsSecret(id) then return ns.Print("form id: <secret>") end
	ns.Print(("form id: %s -> %s"):format(id == nil and "none" or tostring(id), formName(id) or "none"))
end
