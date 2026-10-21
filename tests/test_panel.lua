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

T.test("UNIT_PET for the player triggers a refresh with the new pet state", function()
	local ns = load(true)
	S.fire("ADDON_LOADED", "StatLens")
	S.fire("PLAYER_LOGIN")
	CharacterFrame:Show()
	CharacterFrame.scripts.OnShow(CharacterFrame)
	local n, lastPet = 0, "unset"
	local orig = ns.Calc.Breakdown
	ns.Calc.Breakdown = function(v, ...) n = n + 1 lastPet = v.pet return orig(v, ...) end
	S.fire("UNIT_PET", "target")
	T.eq(n, 0, "other unit ignored")
	_G.UnitExists = function(unit) return unit == "pet" end
	S.fire("UNIT_PET", "player")
	T.eq(n, 1, "refreshed")
	T.eq(lastPet, true, "new pet state read")
end)

T.test("a secret stat renders the rest plus an unavailable note", function()
	local ns = load(true)
	_G.UnitStat = function(_, i) return 110, 110 end
	_G.UnitHealthMax = function() return 777 end
	_G.UnitArmor = function() return 0, 555 end
	_G.issecretvalue = function(v) return v == 777 or v == 555 end
	S.fire("ADDON_LOADED", "StatLens")
	S.fire("PLAYER_LOGIN")
	ns.Talents.last = { ranks = { ancestralKnowledge = 5 }, spellIDs = {}, unmatched = {}, missing = {}, ok = true }
	CharacterFrame:Show()
	CharacterFrame.scripts.OnShow(CharacterFrame)
	local texts = {}
	for i, fs in ipairs(ns.Panel.pool) do if fs.shown ~= false and fs.text then texts[#texts + 1] = fs.text end end
	T.eq(texts[1], "Intellect 110 (talents +10)")
	T.eq(texts[2], "Ancestral Knowledge 5/5: +10")
	T.eq(texts[#texts], "Unavailable right now: Health, Armor")
	T.eq(ns.Panel.pool[1].color[4], 1, "not dimmed")
end)

T.test("combat with no previous render shows only the frozen note", function()
	local ns = load(true)
	S.fire("ADDON_LOADED", "StatLens")
	S.fire("PLAYER_LOGIN")
	_G.InCombatLockdown = function() return true end
	CharacterFrame:Show()
	CharacterFrame.scripts.OnShow(CharacterFrame)
	T.eq(ns.Panel.pool[1] and ns.Panel.pool[1].text, "Frozen in combat")
	T.eq(ns.Panel.pool[2], nil)
end)

T.test("every displayable stat secret freezes out of combat", function()
	local ns = load(true)
	_G.issecretvalue = function(v) return type(v) == "number" end
	S.fire("ADDON_LOADED", "StatLens")
	S.fire("PLAYER_LOGIN")
	CharacterFrame:Show()
	CharacterFrame.scripts.OnShow(CharacterFrame)
	T.eq(ns.Panel.pool[1] and ns.Panel.pool[1].text, "Frozen in combat")
end)

local function renderWithSecretInputs(extraTalent, ranks)
	local ns = load(true)
	_G.UnitStat = function(_, i) return 110, 110 end
	_G.UnitLevel = function() return 25 end
	_G.GetShapeshiftFormID = function() return 1 end
	_G.UnitExists = function() return "pet-secret" end
	_G.issecretvalue = function(v) return v == 25 or v == 1 or v == "pet-secret" end
	if extraTalent then table.insert(ns.Data.SHAMAN.talents, extraTalent) end
	S.fire("ADDON_LOADED", "StatLens")
	S.fire("PLAYER_LOGIN")
	ns.Talents.last = { ranks = ranks, spellIDs = {}, unmatched = {}, missing = {}, ok = true }
	CharacterFrame:Show()
	CharacterFrame.scripts.OnShow(CharacterFrame)
	local texts = {}
	for i, fs in ipairs(ns.Panel.pool) do if fs.shown ~= false and fs.text then texts[#texts + 1] = fs.text end end
	return texts
end

T.test("secret condition inputs used by ranked talents render an unknown note", function()
	local fake = { key = "fakeCond", name = "Fake", maxRank = 1, kind = "stat", effects = {
		{ stat = "armor", op = "pct", forms = { "bear" }, perRank = { 0.1 } },
		{ stat = "health", op = "perLevel", perRank = { 1 } },
	} }
	local texts = renderWithSecretInputs(fake, { ancestralKnowledge = 5, fakeCond = 1 })
	T.eq(texts[1], "Intellect 110 (talents +10)")
	T.eq(texts[#texts], "Unknown right now: form, level (talents that depend on them are not counted)")
end)

T.test("secret inputs no ranked talent depends on stay silent", function()
	local texts = renderWithSecretInputs(nil, { ancestralKnowledge = 5 })
	T.eq(texts[#texts], "Ancestral Knowledge 5/5: +10")
end)
