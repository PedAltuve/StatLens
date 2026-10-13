local ADDON, ns = ...

local Format = {}
ns.Format = Format

local ORDER = { "int", "stam", "agi", "str", "ap", "sp", "meleeCrit", "spellCrit", "dodge", "parry" }
local LABELS = {
	int = "Intellect", stam = "Stamina", agi = "Agility", str = "Strength", ap = "Attack Power",
	sp = "Spell Power", meleeCrit = "Melee Crit", spellCrit = "Spell Crit", dodge = "Dodge", parry = "Parry",
}
local PERCENT = { meleeCrit = true, spellCrit = true, dodge = true, parry = true }

local function num(stat, x)
	if PERCENT[stat] then return ("%.1f%%"):format(x) end
	return ("%d"):format(math.floor(x + 0.5))
end

local function ratioOf(talent, stat, rank)
	for _, e in ipairs(talent.effects or {}) do
		if e.stat == stat and e.op == "fromStat" then return e.perRank[rank], e.source end
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
				if p.op ~= "enables" then total, shown = total + p.amount, true end
			end
			local head = LABELS[stat] .. " " .. num(stat, s.total or 0)
			if shown then head = head .. " (talents +" .. num(stat, total) .. ")" end
			add(head, 0, "stat")

			for _, p in ipairs(s.parts) do
				local t = byKey[p.key]
				local rank = breakdown.talents[p.key].rank
				local name = p.name .. (t and t.inferred and "*" or "")
				if t and t.inferred then inferred = true end
				if p.op == "enables" then
					add(("%s: enables %s (%s)"):format(name, LABELS[stat], num(stat, s.total or 0)), 1, "part")
				else
					local text = ("%s %d/%d: +%s"):format(name, rank, t and t.maxRank or rank, num(stat, p.amount))
					local ratio, source
					if p.op == "fromStat" and t then ratio, source = ratioOf(t, stat, rank) end
					if ratio then
						text = text .. (" (%d%% of %s)"):format(math.floor(ratio * 100 + 0.5), LABELS[source])
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
