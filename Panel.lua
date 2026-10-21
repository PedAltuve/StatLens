local ADDON, ns = ...

local Panel = { pool = {} }
ns.Panel = Panel

local WIDTH, PAD, TITLE_H, LINE_H, INDENT = 260, 10, 18, 14, 10
local COLORS = {
	header = { 1, 0.82, 0 }, stat = { 1, 1, 1 }, part = { 0.6, 1, 0.6 },
	chain = { 0.6, 0.6, 0.6 }, note = { 0.6, 0.6, 0.6 }, inactive = { 0.6, 0.6, 0.6 },
}

local lastLines, pending, warned

local function enabled() return not StatLensDB or StatLensDB.panelShown ~= false end

local MARGIN = 6

local function call(obj, method, ...)
	local ok, a = pcall(function(...) return obj[method](obj, ...) end, ...)
	if ok then return a end
end

-- Right edge of a frame in `frame`'s coordinate space, or nil before layout.
local function rightIn(child, frameScale)
	local right = call(child, "GetRight")
	if type(right) ~= "number" then return nil end
	local scale = call(child, "GetEffectiveScale")
	if type(scale) == "number" and type(frameScale) == "number" and frameScale > 0 then
		right = right * scale / frameScale
	end
	return right
end

-- Offset from frame's right edge that clears shown children (and grandchildren), e.g. side tabs.
function Panel.ComputeOffset(frame, panel)
	if not frame then return MARGIN end
	local frameRight = call(frame, "GetRight")
	if type(frameRight) ~= "number" then return MARGIN end
	local frameScale = call(frame, "GetEffectiveScale")
	local maxRight = frameRight

	local function visit(parent, depth)
		local ok, kids = pcall(function() return { parent:GetChildren() } end)
		if not ok then return end
		for _, child in ipairs(kids) do
			if child ~= panel and call(child, "IsShown") then
				local r = rightIn(child, frameScale)
				if r and r > maxRight then maxRight = r end
				if depth < 2 then visit(child, depth + 1) end
			end
		end
	end
	visit(frame, 1)
	return math.max(0, maxRight - frameRight) + MARGIN
end

local function anchor()
	local f = Panel.frame
	if not f or not CharacterFrame then return end
	local x = StatLensDB and StatLensDB.panelOffsetX or Panel.ComputeOffset(CharacterFrame, f)
	Panel.currentOffset = x
	f:ClearAllPoints()
	f:SetPoint("TOPLEFT", CharacterFrame, "TOPRIGHT", x, 0)
end
Panel.Anchor = anchor

local function ensureFrame()
	if Panel.frame then return Panel.frame end
	if not CharacterFrame then
		if StatLensDB and StatLensDB.debug and not warned then
			warned = true
			ns.Print("CharacterFrame not found; panel disabled")
		end
		return nil
	end
	local ok, f = pcall(CreateFrame, "Frame", "StatLensPanel", CharacterFrame, "BackdropTemplate")
	if not ok or not f then f = CreateFrame("Frame", "StatLensPanel", CharacterFrame) end
	f:SetWidth(WIDTH)
	if f.SetBackdrop then
		f:SetBackdrop({
			bgFile = "Interface\\Tooltips\\UI-Tooltip-Background",
			edgeFile = "Interface\\Tooltips\\UI-Tooltip-Border",
			edgeSize = 12, insets = { left = 3, right = 3, top = 3, bottom = 3 },
		})
		f:SetBackdropColor(0, 0, 0, 0.8)
	end
	local title = f:CreateFontString(nil, "OVERLAY", "GameFontNormal")
	title:SetPoint("TOPLEFT", f, "TOPLEFT", PAD, -PAD + 2)
	title:SetText("StatLens")
	f:Hide()
	Panel.frame = f
	anchor()

	CharacterFrame:HookScript("OnShow", function()
		if enabled() then anchor() f:Show() Panel.Refresh() end
	end)
	CharacterFrame:HookScript("OnHide", function() f:Hide() end)
	if CharacterFrame:IsShown() and enabled() then f:Show() end
	return f
end

local function render(lines, dim)
	local f = ensureFrame()
	if not f then return end
	anchor()
	local alpha = dim and 0.5 or 1
	local y = PAD + TITLE_H
	for i, line in ipairs(lines) do
		local fs = Panel.pool[i]
		if not fs then
			fs = f:CreateFontString(nil, "OVERLAY", "GameFontHighlightSmall")
			fs:SetJustifyH("LEFT")
			Panel.pool[i] = fs
		end
		local indent = line.indent * INDENT
		local c = COLORS[line.kind] or COLORS.note
		fs:ClearAllPoints()
		fs:SetWidth(WIDTH - 2 * PAD - indent)
		fs:SetPoint("TOPLEFT", f, "TOPLEFT", PAD + indent, -y)
		fs:SetTextColor(c[1], c[2], c[3], alpha)
		fs:SetText(line.text)
		fs:Show()
		y = y + (fs:GetStringHeight() or LINE_H) + 2
	end
	for i = #lines + 1, #Panel.pool do
		Panel.pool[i]:SetText(nil)
		Panel.pool[i]:Hide()
	end
	f:SetHeight(y + PAD)
end

local function renderFrozen()
	if not lastLines then return end
	local lines = {}
	for i, l in ipairs(lastLines) do lines[i] = l end
	lines[#lines + 1] = { text = "Frozen in combat", indent = 0, kind = "note" }
	render(lines, true)
end

function Panel.Refresh()
	if not enabled() or not ensureFrame() or not CharacterFrame:IsShown() then return end
	if InCombatLockdown() then return renderFrozen() end

	local stats = ns.Stats.Read()
	if stats.secret then return renderFrozen() end
	local class = select(2, UnitClass("player"))
	local data = ns.Data[class]
	if not stats.ok or not data then return end

	local talents = ns.Talents.last or ns.Talents.Read()
	lastLines = ns.Format.Lines(ns.Calc.Breakdown(stats.values, talents.ranks, data), talents.ranks, data)
	render(lastLines)
end

-- Coalesce bursts of events into one refresh.
function Panel.Request()
	if pending then return end
	if not (C_Timer and C_Timer.After) then return Panel.Refresh() end
	pending = true
	C_Timer.After(0.2, function()
		pending = false
		Panel.Refresh()
	end)
end

local function onPlayerUnit(unit)
	if unit == "player" then Panel.Request() end
end

ns.On("PLAYER_LOGIN", function() ensureFrame() end)
ns.On("UNIT_STATS", onPlayerUnit)
ns.On("UNIT_ATTACK_POWER", onPlayerUnit)
ns.On("UNIT_AURA", onPlayerUnit)
ns.On("UNIT_PET", onPlayerUnit)
ns.On("UPDATE_SHAPESHIFT_FORM", Panel.Request)
ns.On("PLAYER_EQUIPMENT_CHANGED", Panel.Request)
ns.On("PLAYER_REGEN_DISABLED", function()
	if Panel.frame and Panel.frame:IsShown() then renderFrozen() end
end)
ns.On("PLAYER_REGEN_ENABLED", Panel.Request)
ns.Talents.OnChange(Panel.Request)

ns.commands.panel = function()
	StatLensDB = StatLensDB or {}
	StatLensDB.panelShown = not enabled()
	local f = ensureFrame()
	if StatLensDB.panelShown then
		if f and CharacterFrame:IsShown() then f:Show() Panel.Refresh() end
	elseif f then
		f:Hide()
	end
	ns.Print("panel " .. (StatLensDB.panelShown and "on" or "off"))
end

ns.commands.offset = function(args)
	StatLensDB = StatLensDB or {}
	if args == "auto" then
		StatLensDB.panelOffsetX = nil
	elseif tonumber(args) then
		StatLensDB.panelOffsetX = tonumber(args)
	else
		return ns.Print("usage: offset <number>|auto")
	end
	anchor()
	ns.Print("panel offset " .. (StatLensDB.panelOffsetX and tostring(StatLensDB.panelOffsetX) or "auto"))
end
