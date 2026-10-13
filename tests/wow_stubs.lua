-- Minimal WoW API stubs. Call S.reset() before each test for a clean slate.
local S = { frames = {}, failRegister = {}, chat = {} }

-- Unknown methods (SetSize, SetPoint, ...) are harmless no-ops returning nil.
local lenient = { __index = function() return function() end end }

local function newFontString()
	local fs = setmetatable({}, lenient)
	function fs:SetText(t) self.text = t end
	function fs:GetText() return self.text end
	function fs:SetTextColor(r, g, b, a) self.color = { r, g, b, a } end
	return fs
end

local function newFrame()
	local f = setmetatable({ events = {}, scripts = {}, shown = false }, lenient)
	function f:IsShown() return self.shown end
	function f:CreateFontString() return newFontString() end
	function f:RegisterEvent(e)
		if S.failRegister[e] then error("unknown event " .. e) end
		self.events[e] = true
	end
	function f:UnregisterEvent(e) self.events[e] = nil end
	function f:SetScript(name, fn) self.scripts[name] = fn end
	function f:HookScript(name, fn)
		local prev = self.scripts[name]
		self.scripts[name] = function(...)
			if prev then prev(...) end
			fn(...)
		end
	end
	function f:Show() self.shown = true end
	function f:Hide() self.shown = false end
	-- Test helper: deliver an event to the frame's OnEvent script.
	function f:Fire(event, ...)
		if self.scripts.OnEvent then self.scripts.OnEvent(self, event, ...) end
	end
	return f
end

-- Test helper: fire an event on every frame that registered it.
function S.fire(event, ...)
	for _, f in ipairs(S.frames) do
		if f.events[event] then f:Fire(event, ...) end
	end
end

function S.reset()
	S.frames, S.failRegister, S.chat = {}, {}, {}
	_G.CreateFrame = function()
		local f = newFrame()
		S.frames[#S.frames + 1] = f
		return f
	end
	_G.SlashCmdList = {}
	_G.hooksecurefunc = function() end
	_G.issecretvalue = function() return false end
	_G.DEFAULT_CHAT_FRAME = { AddMessage = function(_, msg) S.chat[#S.chat + 1] = msg end }
	_G.StatLensDB = nil
	_G.C_Traits, _G.C_ClassTalents, _G.C_Spell = nil, nil, nil
	for _, n in ipairs({ "UnitStat", "UnitAttackPower", "GetSpellBonusDamage", "GetCritChance",
		"GetSpellCritChance", "GetDodgeChance", "GetParryChance", "UnitLevel", "GetSpellBonusHealing",
		"UnitArmor", "GetShapeshiftFormID" }) do _G[n] = nil end
	_G.C_Timer = { After = function(_, fn) fn() end }
	_G.InCombatLockdown = function() return false end
	_G.UIParent = newFrame()
	_G.CharacterFrame = nil
	_G.UnitClass = function() return "Shaman", "SHAMAN" end
	for k in pairs(_G) do
		if type(k) == "string" and k:match("^SLASH_") then _G[k] = nil end
	end
end

function S.loadAddonFile(path, ns)
	local chunk, err = loadfile(path)
	if not chunk then error(err) end
	return chunk("StatLens", ns)
end

S.reset()
return S
