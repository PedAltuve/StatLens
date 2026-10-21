local ADDON, ns = ...

local Tooltip = {}
ns.Tooltip = Tooltip

local GREY = { 0.6, 0.6, 0.6 }
local hooked = {}

local function resolve(spellID)
	local entry = ns.Talents.BySpellID(spellID)
	if entry then return entry end
	local ok, name = pcall(function() return C_Spell.GetSpellName(spellID) end)
	return ok and name and ns.Talents.ByName(name) or nil
end

local function build(spellID)
	local entry = resolve(spellID)
	if not entry then return nil end
	local stats = ns.Stats.Read()
	if not stats.ok then
		return { { text = "StatLens: unavailable in combat", r = GREY[1], g = GREY[2], b = GREY[3] } }
	end
	local talents = ns.Talents.last or ns.Talents.Read()
	local data = ns.Data[select(2, UnitClass("player"))]
	local rank = talents.ranks[entry.key] or 0
	local breakdown = ns.Calc.Breakdown(stats.values, talents.ranks, data)
	local nextPoint = ns.Calc.NextPoint(stats.values, talents.ranks, data, entry.key)
	local lines = ns.Format.TooltipLines(entry, rank, breakdown, nextPoint)
	-- One note per unreadable stat this talent reads or changes, in panel order.
	local touched = {}
	for _, e in ipairs(entry.effects or {}) do
		touched[e.stat] = true
		if e.source then touched[e.source] = true end
	end
	for _, stat in ipairs(ns.Format.ORDER) do
		if touched[stat] and stats.secretStats[stat] then
			lines[#lines + 1] = { text = ("StatLens: %s unavailable right now"):format(ns.Format.Label(stat)), r = GREY[1], g = GREY[2], b = GREY[3] }
		end
	end
	return lines
end

local function append(tooltip, spellID)
	if ns.IsSecret(spellID) then return end
	if not spellID or (StatLensDB and StatLensDB.tooltip == false) then return end
	if not hooked[tooltip] and tooltip.HookScript then
		hooked[tooltip] = true
		pcall(tooltip.HookScript, tooltip, "OnTooltipCleared", function(t) t.statLensSpell = nil end)
	end
	if tooltip.statLensSpell == spellID then return end
	local lines = build(spellID)
	if not lines then return end
	tooltip.statLensSpell = spellID
	tooltip:AddLine(" ")
	for _, l in ipairs(lines) do tooltip:AddLine(l.text, l.r, l.g, l.b, true) end
	tooltip:Show()
end

local function safeAppend(tooltip, spellID)
	local ok, err = pcall(append, tooltip, spellID)
	if not ok and StatLensDB and StatLensDB.debug then ns.Print("tooltip error: " .. tostring(err)) end
end

local function install()
	if TooltipDataProcessor and TooltipDataProcessor.AddTooltipPostCall and Enum and Enum.TooltipDataType then
		local ok = pcall(TooltipDataProcessor.AddTooltipPostCall, Enum.TooltipDataType.Spell, function(tooltip, data)
			safeAppend(tooltip, data and data.id)
		end)
		if ok then return end
	end
	pcall(hooksecurefunc, GameTooltip, "SetSpellByID", safeAppend)
end

install()

ns.commands.tooltip = function()
	StatLensDB = StatLensDB or {}
	StatLensDB.tooltip = StatLensDB.tooltip == false
	ns.Print("tooltip " .. (StatLensDB.tooltip and "on" or "off"))
end
