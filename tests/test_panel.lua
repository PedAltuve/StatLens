local S = require("wow_stubs")

local FILES = { "Core.lua", "Data/Shaman.lua", "Talents.lua", "Stats.lua", "Calc.lua", "Format.lua", "Panel.lua" }

local function load(withCharacterFrame)
	S.reset()
	if withCharacterFrame then _G.CharacterFrame = CreateFrame("Frame", "CharacterFrame") end
	_G.UnitStat = function() return 10, 10 end
	local ns = {}
	for _, f in ipairs(FILES) do S.loadAddonFile(f, ns) end
	return ns
end

T.test("Panel loads and refreshes without CharacterFrame", function()
	local ok, err = pcall(function()
		local ns = load(false)
		S.fire("ADDON_LOADED", "StatLens")
		S.fire("PLAYER_LOGIN")
		S.fire("UNIT_STATS", "player")
	end)
	T.truthy(ok, tostring(err))
end)

T.test("Panel renders when CharacterFrame shows", function()
	local ns = load(true)
	S.fire("ADDON_LOADED", "StatLens")
	S.fire("PLAYER_LOGIN")
	CharacterFrame:Show()
	CharacterFrame.scripts.OnShow(CharacterFrame)
	T.truthy(ns.Panel.frame, "frame created")
	T.eq(ns.Panel.pool[1].text, "No stat talents taken yet.")
	CharacterFrame.scripts.OnHide(CharacterFrame)
	T.eq(ns.Panel.frame.shown, false, "hidden with CharacterFrame")
end)

T.test("combat freezes the panel", function()
	local ns = load(true)
	S.fire("ADDON_LOADED", "StatLens")
	S.fire("PLAYER_LOGIN")
	CharacterFrame:Show()
	CharacterFrame.scripts.OnShow(CharacterFrame)
	_G.InCombatLockdown = function() return true end
	S.fire("PLAYER_REGEN_DISABLED")
	T.eq(ns.Panel.pool[2].text, "Frozen in combat", "footer after kept lines")
end)

T.test("/sl panel toggles the saved flag", function()
	local ns = load(true)
	S.fire("ADDON_LOADED", "StatLens")
	T.eq(StatLensDB.panelShown, true, "default")
	S.fire("PLAYER_LOGIN")
	CharacterFrame:Show()
	CharacterFrame.scripts.OnShow(CharacterFrame)
	SlashCmdList.STATLENS("panel")
	T.eq(StatLensDB.panelShown, false)
	T.eq(ns.Panel.frame.shown, false, "hidden immediately")
	SlashCmdList.STATLENS("panel")
	T.eq(StatLensDB.panelShown, true)
	T.eq(ns.Panel.frame.shown, true, "shown immediately")
end)

-- ComputeOffset
local function box(right, scale, shown, children)
	return {
		GetRight = function() return right end,
		GetEffectiveScale = function() return scale or 1 end,
		IsShown = function() return shown ~= false end,
		GetChildren = function() return unpack(children or {}) end,
	}
end

T.test("ComputeOffset", function()
	local ns = load(false)
	local C = ns.Panel.ComputeOffset
	local panel = box(900)
	T.eq(C(box(500, 1, true, {}), panel), 6, "no children")
	T.eq(C(box(500, 1, true, { box(545) }), panel), 51, "tab column sticks out 45")
	T.eq(C(box(500, 1, true, { box(nil), box(480) }), panel), 6, "nil GetRight ignored, inside frame")
	T.eq(C(box(500, 1, true, { box(700, 1, false) }), panel), 6, "hidden ignored")
	T.eq(C(box(500, 1, true, { panel }), panel), 6, "panel excluded")
	T.eq(C(box(500, 1, true, { box(10, 1, true, { box(530) }) }), panel), 36, "nested child")
	T.eq(C(box(500, 1, true, { box(300, 2) }), panel), 106, "scale conversion 300*2/1=600")
	T.eq(C(nil, panel), 6, "nil frame")
end)

T.test("/sl offset override", function()
	local ns = load(true)
	S.fire("ADDON_LOADED", "StatLens")
	S.fire("PLAYER_LOGIN")
	SlashCmdList.STATLENS("offset 20")
	T.eq(StatLensDB.panelOffsetX, 20)
	T.eq(ns.Panel.currentOffset, 20, "applied")
	SlashCmdList.STATLENS("offset auto")
	T.eq(StatLensDB.panelOffsetX, nil)
	T.eq(ns.Panel.currentOffset, 6, "auto again")
	SlashCmdList.STATLENS("offset zzz")
	T.eq(StatLensDB.panelOffsetX, nil, "invalid ignored")
end)

T.test("UPDATE_SHAPESHIFT_FORM triggers a refresh", function()
	local ns = load(true)
	S.fire("ADDON_LOADED", "StatLens")
	S.fire("PLAYER_LOGIN")
	CharacterFrame:Show()
	CharacterFrame.scripts.OnShow(CharacterFrame)
	local n = 0
	local orig = ns.Format.Lines
	ns.Format.Lines = function(...) n = n + 1 return orig(...) end
	S.fire("UPDATE_SHAPESHIFT_FORM")
	T.eq(n, 1, "refreshed")
end)
