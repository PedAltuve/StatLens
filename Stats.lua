local ADDON, ns = ...

local Stats = {}
ns.Stats = Stats

-- Call fn(...) under pcall; return all results, or nothing on error / missing API.
local function try(fn, ...)
	if type(fn) ~= "function" then return end
	local res = { pcall(fn, ...) }
	if res[1] then return unpack(res, 2) end
end

local function readValues()
	local v = {}
	local names = { "str", "agi", "stam", "int" }
	for i, name in ipairs(names) do
		local _, effective = try(UnitStat, "player", i)
		v[name] = effective
	end

	local base, pos, neg = try(UnitAttackPower, "player")
	if base ~= nil and pos ~= nil and neg ~= nil then
		-- A secret component poisons the sum; keep it as-is so the caller can detect it.
		if ns.IsSecret(base) or ns.IsSecret(pos) or ns.IsSecret(neg) then
			v.ap = base
		else
			v.ap = base + pos + neg
		end
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
