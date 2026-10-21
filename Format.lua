local ADDON, ns = ...

local Format = {}
ns.Format = Format

local ORDER = {
	"health", "str", "agi", "stam", "int", "spirit", "ap", "rangedAp", "sp", "heal", "hit", "spellHit",
	"meleeCrit", "rangedCrit", "spellCrit", "defense", "dodge", "parry", "block", "armor",
}
local LABELS = {
	int = "Intellect", stam = "Stamina", agi = "Agility", str = "Strength", ap = "Attack Power",
	spirit = "Spirit", defense = "Defense", block = "Block", hit = "Melee Hit", spellHit = "Spell Hit", health = "Health",
	sp = "Spell Power", heal = "Spell Healing", armor = "Armor", meleeCrit = "Melee Crit", spellCrit = "Spell Crit", dodge = "Dodge", parry = "Parry",
	rangedAp = "Ranged Attack Power", rangedCrit = "Ranged Crit",
}
local PERCENT = { block = true, hit = true, spellHit = true, meleeCrit = true, rangedCrit = true, spellCrit = true, dodge = true, parry = true }

local function num(stat, x)
	if PERCENT[stat] then return ("%.1f%%"):format(x) end
	return ("%d"):format(math.floor(x + 0.5))
end

local FORM_NAMES = { cat = "Cat", bear = "Bear", moonkin = "Moonkin" }

-- {"cat","bear"} -> "Cat or Bear Form"
local function formText(forms)
	local names = {}
	for i, f in ipairs(forms or {}) do names[i] = FORM_NAMES[f] or f end
	if #names == 0 then return "other forms" end
	return table.concat(names, " or ") .. " Form"
end

-- Display names for weapon kinds whose capitalized key is not a weapon name on its own.
local WEAPON_NAMES = { fist = "Fist Weapon" }

local function weaponText(weapons)
	local names = {}
	for i, w in ipairs(weapons) do names[i] = WEAPON_NAMES[w] or (w:sub(1, 1):upper() .. w:sub(2)) end
	local article = names[1]:find("^[AEIOU]") and "an" or "a"
	return article .. " " .. table.concat(names, " or ")
end

-- Why a bonus is inactive, e.g. "in Cat Form", "with an Axe or Polearm", "with a shield".
-- `cond` is anything carrying forms / weapons / shield (an effect, a part, an inactiveConds entry).
local function conditionText(cond)
	local parts = {}
	if cond and cond.forms then parts[#parts + 1] = "in " .. formText(cond.forms) end
	if cond and cond.weapons and #cond.weapons > 0 then parts[#parts + 1] = "with " .. weaponText(cond.weapons) end
	if cond and cond.shield then parts[#parts + 1] = "with a shield" end
	if #parts == 0 then return "in other forms" end
	return table.concat(parts, " and ")
end

local function capitalize(text) return text:sub(1, 1):upper() .. text:sub(2) end

local function ratioOf(talent, stat, rank)
	for _, e in ipairs(talent.effects or {}) do
		if e.stat == stat and e.op == "fromStat" then return e.perRank[rank], e.source end
	end
end

local function perLevelOf(talent, stat, rank)
	for _, e in ipairs(talent.effects or {}) do
		if e.stat == stat and e.op == "perLevel" then return e.perRank[rank] end
	end
end

function Format.Lines(breakdown, ranks, classData)
	local lines, inferred = {}, false
	local talents = classData and classData.talents or {}
	local byKey = {}
	for _, t in ipairs(talents) do byKey[t.key] = t end

	local function add(text, indent, kind) lines[#lines + 1] = { text = text, indent = indent, kind = kind } end

	for _, stat in ipairs(ORDER) do
		local s = breakdown and breakdown.stats and breakdown.stats[stat]
		if s and #s.parts > 0 then
			local total, shown = 0, false
			for _, p in ipairs(s.parts) do
				if p.op ~= "enables" and not p.inactive then total, shown = total + p.amount, true end
			end
			local head = LABELS[stat] .. " " .. num(stat, s.total or 0)
			if shown then head = head .. " (talents +" .. num(stat, total) .. ")" end
			add(head, 0, "stat")

			for _, p in ipairs(s.parts) do
				local t = byKey[p.key]
				local rank = breakdown.talents[p.key].rank
				local name = p.name .. (t and t.inferred and "*" or "")
				if t and t.inferred then inferred = true end
				if p.inactive then
					local text = p.op == "enables" and ("%s: enables %s %s"):format(name, LABELS[stat], conditionText(p))
						or ("%s %d/%d: +%s %s"):format(name, rank, t and t.maxRank or rank, num(stat, p.amount), conditionText(p))
					add(text, 1, "inactive")
				elseif p.op == "enables" then
					add(("%s: enables %s (%s)"):format(name, LABELS[stat], num(stat, s.total or 0)), 1, "part")
				else
					local text = ("%s %d/%d: +%s"):format(name, rank, t and t.maxRank or rank, num(stat, p.amount))
					local ratio, source
					if p.op == "fromStat" and t then ratio, source = ratioOf(t, stat, rank) end
					if ratio then
						text = text .. (" (%d%% of %s)"):format(math.floor(ratio * 100 + 0.5), LABELS[source])
					end
					if p.op == "perLevel" and t then
						local per = perLevelOf(t, stat, rank)
						if per and stat == "armor" then
							text = text .. (" (%g per level)"):format(per)
						elseif per then
							text = text .. (" (%d%% of level)"):format(math.floor(per * 100 + 0.5))
						end
					end
					add(text, 1, "part")
					if p.op == "fromStat" then
						for _, pt in ipairs(talents) do
							local c = breakdown.talents[pt.key]
							for _, link in ipairs(c and c.chained[stat] or {}) do
								if link.via == p.key then
									add(("incl. +%s from %s"):format(num(stat, link.amount), pt.name), 2, "chain")
								end
							end
						end
					end
				end
			end
		end
	end

	local notes = {}
	for _, t in ipairs(talents) do
		local rank = ranks and ranks[t.key] or 0
		if t.kind == "conditional" and rank > 0 then
			if t.inferred then inferred = true end
			notes[#notes + 1] = ("%s%s %d/%d: %s"):format(t.name, t.inferred and "*" or "", rank, t.maxRank, t.explain)
		end
	end

	if #lines == 0 and #notes == 0 then
		add("No stat talents taken yet.", 0, "note")
		return lines
	end
	if #notes > 0 then
		add("Conditional talents", 0, "header")
		for _, n in ipairs(notes) do add(n, 1, "note") end
	end
	if inferred then add("* rank value inferred, verify in game", 0, "note") end
	return lines
end

local GOLD, GREY, GREEN = { 1, 0.82, 0 }, { 0.6, 0.6, 0.6 }, { 0.6, 1, 0.6 }

local function partName(breakdown, stat, key)
	local s = breakdown and breakdown.stats and breakdown.stats[stat]
	for _, p in ipairs(s and s.parts or {}) do
		if p.key == key then return p.name end
	end
	return key
end

local function partCondFor(breakdown, stat, key)
	local st = breakdown and breakdown.stats and breakdown.stats[stat]
	for _, p in ipairs(st and st.parts or {}) do
		if p.key == key and p.inactive then return p end
	end
end

local function isEnables(entry, stat)
	for _, e in ipairs(entry.effects or {}) do
		if e.stat == stat and e.op == "enables" then return true end
	end
end

function Format.TooltipLines(entry, rank, breakdown, nextPoint)
	local lines = {}
	local function add(text, c) lines[#lines + 1] = { text = text, r = c[1], g = c[2], b = c[3] } end
	add("StatLens", GOLD)

	if entry.kind == "conditional" then
		add("Not shown on character sheet: " .. entry.explain, GREY)
	elseif entry.kind == "utility" then
		add("No stat effect.", GREY)
	elseif entry.kind == "stat" then
		local function chain(map)
			for _, stat in ipairs(ORDER) do
				for _, link in ipairs(map and map[stat] or {}) do
					add(("  incl. +%s %s via %s"):format(num(stat, link.amount), LABELS[stat], partName(breakdown, stat, link.via)), GREEN)
				end
			end
		end

		local now = rank > 0 and breakdown and breakdown.talents and breakdown.talents[entry.key]
		if now then
			for _, stat in ipairs(ORDER) do
				local amount = now.contributions[stat]
				if amount then
					if isEnables(entry, stat) then
						add("Now: enables " .. LABELS[stat], GREEN)
					else
						add(("Now: +%s %s"):format(num(stat, amount), LABELS[stat]), GREEN)
					end
				end
			end
			chain(now.chained)
			for _, stat in ipairs(ORDER) do
				local amount = now.inactive and now.inactive[stat]
				if amount then
					add(("%s: +%s %s"):format(capitalize(conditionText(partCondFor(breakdown, stat, entry.key))), num(stat, amount), LABELS[stat]), GREY)
				end
			end
		end

		if nextPoint then
			local mark = entry.inferred and " (value inferred)" or ""
			for _, stat in ipairs(ORDER) do
				local delta = nextPoint.deltas[stat]
				if type(delta) == "number" then
					for _, link in ipairs(nextPoint.chained and nextPoint.chained[stat] or {}) do
						delta = delta - link.amount
					end
					if math.abs(delta) < 0.05 then delta = nil end
				end
				if delta == "enables" then
					add(("Next point (%d/%d): enables %s%s"):format(nextPoint.nextRank, entry.maxRank, LABELS[stat], mark), GREEN)
				elseif delta then
					add(("Next point (%d/%d): +%s %s%s"):format(nextPoint.nextRank, entry.maxRank, num(stat, delta), LABELS[stat], mark), GREEN)
				end
			end
			chain(nextPoint.chained)
			for _, stat in ipairs(ORDER) do
				local delta = nextPoint.inactiveDeltas and nextPoint.inactiveDeltas[stat]
				if delta == "enables" then
					add(("Next point (%d/%d): enables %s %s%s"):format(nextPoint.nextRank, entry.maxRank, LABELS[stat],
						conditionText(nextPoint.inactiveConds[stat]), mark), GREY)
				elseif delta then
					add(("Next point (%d/%d): +%s %s %s%s"):format(nextPoint.nextRank, entry.maxRank, num(stat, delta),
						LABELS[stat], conditionText(nextPoint.inactiveConds[stat]), mark), GREY)
				end
			end
		elseif rank >= entry.maxRank then
			add("Maxed", GREY)
		end
	end
	return lines
end

local C_GOLD, C_WHITE, C_GREY, C_END = "|cffffd100", "|cffffffff", "|cff999999", "|r"

local function tag(t, rank)
	return ("%s%s %d/%d"):format(t.name, t.inferred and "*" or "", rank, t.maxRank)
end

-- Native-style lines (with color escapes) for a character sheet stat tooltip.
function Format.StatTooltipLines(statKey, breakdown, classData, ranks)
	local out = {}
	local talents = classData and classData.talents or {}
	local stat = breakdown and breakdown.stats and breakdown.stats[statKey]
	local function rankOf(t)
		local e = breakdown and breakdown.talents and breakdown.talents[t.key]
		return e and e.rank or ranks and ranks[t.key] or 0
	end
	local byKey = {}
	for _, t in ipairs(talents) do byKey[t.key] = t end

	-- a. direct pct/flat contributions to this stat
	for _, p in ipairs(stat and stat.parts or {}) do
		local t = byKey[p.key]
		if t and not p.inactive and (p.op == "pct" or p.op == "flat" or p.op == "perLevel") then
			out[#out + 1] = ("%sTalents add %s%s+%s%s%s (%s)%s"):format(
				C_GOLD, C_END, C_WHITE, num(statKey, p.amount), C_END, C_GREY, tag(t, rankOf(t)), C_END)
		end
	end

	-- b. this stat feeds another stat through a fromStat talent
	for _, t in ipairs(talents) do
		local e = breakdown and breakdown.talents and breakdown.talents[t.key]
		for _, eff in ipairs(t.kind == "stat" and e and t.effects or {}) do
			local amount = eff.op == "fromStat" and eff.source == statKey and e.contributions[eff.stat]
			if amount then
				out[#out + 1] = ("%sIncreases %s%s%s%s%s by %s%s%s%s%s (%s)%s"):format(
					C_GOLD, C_END, C_WHITE, LABELS[eff.stat], C_END, C_GOLD, C_END,
					C_WHITE, num(eff.stat, amount), C_END, C_GREY, tag(t, rankOf(t)), C_END)
			end
		end
	end

	-- c. this stat receives from a fromStat talent, plus the chained shares
	for _, p in ipairs(stat and stat.parts or {}) do
		local t = byKey[p.key]
		if t and not p.inactive and p.op == "fromStat" then
			local source
			for _, eff in ipairs(t.effects) do
				if eff.stat == statKey and eff.op == "fromStat" then source = eff.source end
			end
			out[#out + 1] = ("%sIncludes %s%s+%s%s%s from %s%s%s%s%s (%s)%s"):format(
				C_GOLD, C_END, C_WHITE, num(statKey, p.amount), C_END, C_GOLD, C_END,
				C_WHITE, LABELS[source] or "?", C_END, C_GREY, tag(t, rankOf(t)), C_END)
			for _, pt in ipairs(talents) do
				local c = breakdown.talents[pt.key]
				for _, link in ipairs(c and c.chained[statKey] or {}) do
					if link.via == p.key then
						out[#out + 1] = ("%s  incl. +%s via %s%s"):format(C_GREY, num(statKey, link.amount), pt.name, C_END)
					end
				end
			end
		end
	end

	-- d. this stat only exists because of a talent
	for _, p in ipairs(stat and stat.parts or {}) do
		local t = byKey[p.key]
		if t and not p.inactive and p.op == "enables" then
			out[#out + 1] = ("%sEnabled by %s%s%s%s"):format(C_GOLD, C_END, C_WHITE, t.name .. (t.inferred and "*" or ""), C_END)
		end
	end
	-- e. bonuses that only apply in other forms
	for _, p in ipairs(stat and stat.parts or {}) do
		local t = byKey[p.key]
		if t and p.inactive then
			out[#out + 1] = ("%s%s: +%s (%s)%s"):format(C_GREY, capitalize(conditionText(p)), num(statKey, p.amount), tag(t, rankOf(t)), C_END)
		end
	end
	return out
end
