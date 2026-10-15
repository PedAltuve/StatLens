local ADDON, ns = ...

local StatTooltip = {}
ns.StatTooltip = StatTooltip

-- Native tooltip title prefixes (enUS) -> stat key. Longer labels are tried first.
local LABELS = {
	{ "Spell Critical Strike", "spellCrit" },
	{ "Spell Crit", "spellCrit" },
	{ "Melee Critical Strike", "meleeCrit" },
	{ "Critical Strike", "meleeCrit" },
	{ "Crit Chance", "meleeCrit" },
	{ "Melee Crit", "meleeCrit" },
	{ "Melee Attack Power", "ap" },
	{ "Attack Power", "ap" },
	{ "Spell Power", "sp" },
	{ "Bonus Damage", "sp" },
	{ "Spell Damage", "sp" },
	{ "Spell Healing", "heal" },
	{ "Armor", "armor" },
	{ "Defense", "defense" },
	{ "Block Chance", "block" },
	{ "Block", "block" },
	{ "Spirit", "spirit" },
	{ "Health", "health" },
	{ "Hit Chance", "hit" },
	{ "Strength", "str" },
	{ "Agility", "agi" },
	{ "Stamina", "stam" },
	{ "Intellect", "int" },
	{ "Dodge", "dodge" },
	{ "Parry", "parry" },
}
table.sort(LABELS, function(a, b) return #a[1] > #b[1] end)

local seenTitles = {}
local busy

local function strip(text)
	return (text:gsub("|c%x%x%x%x%x%x%x%x", ""):gsub("|r", ""))
end

function StatTooltip.MatchStat(title)
	if type(title) ~= "string" then return nil end
	title = strip(title)
	for _, entry in ipairs(LABELS) do
		local label = entry[1]
		if title:sub(1, #label) == label then
			local nextChar = title:sub(#label + 1, #label + 1)
			if nextChar == "" or nextChar == " " or nextChar == ":" then return entry[2] end
		end
	end
end

local function underCharacterFrame(owner)
	local node = owner
	for _ = 1, 20 do
		if not node then return false end
		if node == CharacterFrame then return true end
		local ok, parent = pcall(function() return node:GetParent() end)
		node = ok and parent or nil
	end
	return false
end

local function titleOf(tooltip)
	local name = tooltip:GetName()
	local line = name and _G[name .. "TextLeft1"]
	local text = line and line:GetText()
	if text == nil or ns.IsSecret(text) then return nil end
	return strip(text)
end

local function append(tooltip)
	if busy or tooltip.statLensStatDone then return end
	if StatLensDB and StatLensDB.tooltip == false then return end
	if InCombatLockdown() or not CharacterFrame then return end
	if not underCharacterFrame(tooltip:GetOwner()) then return end

	local title = titleOf(tooltip)
	if not title then return end
	if StatLensDB and StatLensDB.debug and not seenTitles[title] then
		seenTitles[title] = true
		ns.Print("stat tooltip title: " .. title)
	end

	local statKey = StatTooltip.MatchStat(title)
	if not statKey then return end
	local stats = ns.Stats.Read()
	if not stats.ok then return end
	local data = ns.Data[select(2, UnitClass("player"))]
	if not data then return end
	local talents = ns.Talents.last or ns.Talents.Read()
	local breakdown = ns.Calc.Breakdown(stats.values, talents.ranks, data)
	local lines = ns.Format.StatTooltipLines(statKey, breakdown, data, talents.ranks)
	if #lines == 0 then return end

	tooltip.statLensStatDone = true
	if not tooltip.statLensStatHooked and tooltip.HookScript then
		tooltip.statLensStatHooked = true
		pcall(tooltip.HookScript, tooltip, "OnTooltipCleared", function(t) t.statLensStatDone = nil end)
	end
	busy = true
	for _, line in ipairs(lines) do tooltip:AddLine(line, 1, 1, 1, false) end
	tooltip:Show()
	busy = false
end

local function safeAppend(tooltip)
	local ok, err = pcall(append, tooltip)
	busy = false
	if not ok and StatLensDB and StatLensDB.debug then ns.Print("stat tooltip error: " .. tostring(err)) end
end

pcall(hooksecurefunc, GameTooltip, "Show", safeAppend)
