local ADDON, ns = ...

local Calc = {}
ns.Calc = Calc

local function find(classData, key)
	for _, t in ipairs(classData and classData.talents or {}) do
		if t.key == key then return t end
	end
end

-- Active stat talents: rank > 0, clamped to maxRank.
local function active(ranks, classData)
	local list = {}
	for _, t in ipairs(classData and classData.talents or {}) do
		local r = ranks and ranks[t.key] or 0
		if t.kind == "stat" and r > 0 then
			list[#list + 1] = { t = t, rank = math.min(r, t.maxRank) }
		end
	end
	return list
end

function Calc.Breakdown(values, ranks, classData)
	local out = { stats = {}, talents = {} }
	local list = active(ranks, classData)

	local function statEntry(stat)
		local s = out.stats[stat]
		if not s then
			s = { total = values[stat], talentTotal = 0, parts = {} }
			out.stats[stat] = s
		end
		return s
	end
	local function talentEntry(a)
		local e = out.talents[a.t.key]
		if not e then
			e = { rank = a.rank, contributions = {}, chained = {} }
			out.talents[a.t.key] = e
		end
		return e
	end
	local function add(a, stat, amount, op)
		local s, e = statEntry(stat), talentEntry(a)
		s.parts[#s.parts + 1] = { key = a.t.key, name = a.t.name, amount = amount, op = op }
		s.talentTotal = s.talentTotal + amount
		e.contributions[stat] = (e.contributions[stat] or 0) + amount
	end
	local function effects(a, op)
		local i = 0
		return function()
			while true do
				i = i + 1
				local e = a.t.effects[i]
				if not e then return end
				if e.op == op and values[e.stat] ~= nil then return e end
			end
		end
	end

	-- a. pct: invert the client total. Several pct talents on one stat share one base.
	local pctSum, pctAmounts = {}, {}
	for _, a in ipairs(list) do
		for e in effects(a, "pct") do
			local p = e.perRank[a.rank]
			if p then pctSum[e.stat] = (pctSum[e.stat] or 0) + p end
		end
	end
	for _, a in ipairs(list) do
		for e in effects(a, "pct") do
			local p = e.perRank[a.rank]
			if p then
				local base = values[e.stat] / (1 + pctSum[e.stat])
				local amount = base * p
				add(a, e.stat, amount, "pct")
				pctAmounts[#pctAmounts + 1] = { a = a, stat = e.stat, amount = amount }
			end
		end
	end

	-- b. fromStat: ratio x total of the source stat.
	local fromStat = {}
	for _, a in ipairs(list) do
		for e in effects(a, "fromStat") do
			local ratio = e.perRank[a.rank]
			if ratio and values[e.source] ~= nil then
				add(a, e.stat, ratio * values[e.source], "fromStat")
				fromStat[#fromStat + 1] = { a = a, target = e.stat, source = e.source, ratio = ratio }
			end
		end
	end

	-- c. chain attribution: informational, never added to talentTotal.
	for _, p in ipairs(pctAmounts) do
		for _, f in ipairs(fromStat) do
			if f.source == p.stat then
				local chained = talentEntry(p.a).chained
				chained[f.target] = chained[f.target] or {}
				table.insert(chained[f.target], { via = f.a.t.key, amount = f.ratio * p.amount })
			end
		end
	end

	-- d. flat
	for _, a in ipairs(list) do
		for e in effects(a, "flat") do
			local amount = e.perRank[a.rank]
			if amount then add(a, e.stat, amount, "flat") end
		end
	end

	-- e. enables: credit the full current total.
	for _, a in ipairs(list) do
		for e in effects(a, "enables") do
			add(a, e.stat, values[e.stat], "enables")
		end
	end

	return out
end

function Calc.NextPoint(values, ranks, classData, key)
	local t = find(classData, key)
	if not t or t.kind ~= "stat" then return nil end
	local r = math.min(ranks and ranks[key] or 0, t.maxRank)
	if r >= t.maxRank then return nil end

	local res = { rank = r, nextRank = r + 1, deltas = {}, chained = {} }
	local current = active(ranks, classData)

	for _, e in ipairs(t.effects) do
		local total = values[e.stat]
		local cur = r > 0 and e.perRank and e.perRank[r] or 0
		local nxt = e.perRank and e.perRank[r + 1]
		if e.op == "enables" then
			if r == 0 then res.deltas[e.stat] = "enables" end
		elseif total ~= nil and nxt then
			if e.op == "pct" then
				local delta = total / (1 + cur) * (nxt - cur)
				res.deltas[e.stat] = (res.deltas[e.stat] or 0) + delta
				for _, a in ipairs(current) do
					for _, fe in ipairs(a.t.effects) do
						local ratio = fe.op == "fromStat" and fe.source == e.stat and fe.perRank[a.rank]
						if ratio and values[fe.stat] ~= nil then
							local amount = ratio * delta
							res.deltas[fe.stat] = (res.deltas[fe.stat] or 0) + amount
							res.chained[fe.stat] = res.chained[fe.stat] or {}
							table.insert(res.chained[fe.stat], { via = a.t.key, amount = amount })
						end
					end
				end
			elseif e.op == "fromStat" then
				local src = values[e.source]
				if src ~= nil then res.deltas[e.stat] = (res.deltas[e.stat] or 0) + src * (nxt - cur) end
			elseif e.op == "flat" then
				res.deltas[e.stat] = (res.deltas[e.stat] or 0) + (nxt - cur)
			end
		end
	end
	return res
end
