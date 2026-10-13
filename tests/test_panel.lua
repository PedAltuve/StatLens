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
