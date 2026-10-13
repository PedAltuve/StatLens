local S = require("wow_stubs")

local FILES = { "Core.lua", "Data/Shaman.lua", "Talents.lua", "Stats.lua", "Calc.lua", "Format.lua", "StatTooltip.lua" }

local function node(parent)
	return { GetParent = function() return parent end }
end

local function newTooltip(owner, title)
	local tt = { lines = {}, scripts = {}, owner = owner }
	function tt:GetOwner() return self.owner end
	function tt:GetName() return "GameTooltip" end
	function tt:AddLine(text, r, g, b, wrap) self.lines[#self.lines + 1] = text; self.wrap = wrap end
	function tt:HookScript(n, fn) self.scripts[n] = fn end
	function tt:Show() self.shownCount = (self.shownCount or 0) + 1; if self.onShow then self.onShow(self) end end
	function tt:Clear() if self.scripts.OnTooltipCleared then self.scripts.OnTooltipCleared(self) end self.lines = {} end
	_G.GameTooltipTextLeft1 = { GetText = function() return title end }
	return tt
end

local function setup(title, ownerInside)
	S.reset()
	_G.CharacterFrame = node(nil)
	local owner = ownerInside == false and node(node(nil)) or node(node(node(CharacterFrame)))
	_G.GameTooltip = newTooltip(owner, title)
	local hooks = {}
	_G.hooksecurefunc = function(obj, name, fn)
		hooks[name] = fn
		-- Real hooksecurefunc runs the hook after every call, including our own Show.
		local orig = obj[name]
		obj[name] = function(self, ...) orig(self, ...); fn(self, ...) end
	end
	_G.UnitStat = function(_, i) return 72, 72 end
	_G.UnitAttackPower = function() return 200, 0, 0 end
	_G.GetSpellBonusDamage = function() return 0 end
	_G.GetCritChance = function() return 10 end
	_G.GetSpellCritChance = function() return 8 end
	_G.GetDodgeChance = function() return 5 end
	_G.GetParryChance = function() return 5 end
	local ns = {}
	for _, f in ipairs(FILES) do S.loadAddonFile(f, ns) end
	S.fire("ADDON_LOADED", "StatLens")
	ns.Talents.last = { ranks = { ancestralKnowledge = 1, mentalDexterity = 3 }, spellIDs = {}, unmatched = {}, missing = {}, ok = true }
	return ns, hooks
end

T.test("MatchStat", function()
	local ns = setup("x")
	local M = ns.StatTooltip.MatchStat
	T.eq(M("Intellect 72 (40+32)"), "int")
	T.eq(M("|cffffffffIntellect|r 72"), "int")
	T.eq(M("Intellect"), "int")
	T.eq(M("Intellect: 72"), "int")
	T.eq(M("Intellectual"), nil, "needs boundary")
	T.eq(M("Spell Critical Strike 5%"), "spellCrit")
	T.eq(M("Critical Strike 5%"), "meleeCrit")
	T.eq(M("Melee Critical Strike"), "meleeCrit")
	T.eq(M("Melee Attack Power 100"), "ap")
	T.eq(M("Attack Power"), "ap")
	T.eq(M("Bonus Damage 12"), "sp")
	T.eq(M("Dodge 5%"), "dodge")
	T.eq(M("Parry 5%"), "parry")
	T.eq(M("Strength 10"), "str"); T.eq(M("Agility 10"), "agi"); T.eq(M("Stamina 10"), "stam")
	T.eq(M("Fireball"), nil)
end)

T.test("appends once for owner under CharacterFrame", function()
	local ns, hooks = setup("Intellect 72 (40+32)")
	T.truthy(hooks.Show, "hooked")
	GameTooltip:Show()
	T.truthy(#GameTooltip.lines >= 2, "lines appended")
	T.eq(GameTooltip.wrap, false)
	local n = #GameTooltip.lines
	GameTooltip:Show()
	T.eq(#GameTooltip.lines, n, "no double append")
	GameTooltip:Clear()
	GameTooltip:Show()
	T.eq(#GameTooltip.lines, n, "appends again after clear")
end)

T.test("re-entry from our own Show is guarded", function()
	local ns = setup("Intellect 72")
	GameTooltip:Show()
	T.eq(GameTooltip.shownCount, 2, "original + our Show, no recursion")
end)

T.test("owner outside CharacterFrame -> nothing", function()
	local ns = setup("Intellect 72", false)
	GameTooltip:Show()
	T.eq(#GameTooltip.lines, 0)
end)

T.test("combat -> nothing", function()
	local ns = setup("Intellect 72")
	_G.InCombatLockdown = function() return true end
	GameTooltip:Show()
	T.eq(#GameTooltip.lines, 0)
end)

T.test("toggle off -> nothing", function()
	local ns = setup("Intellect 72")
	StatLensDB.tooltip = false
	GameTooltip:Show()
	T.eq(#GameTooltip.lines, 0)
end)

T.test("unmatched title -> nothing", function()
	local ns = setup("Fireball")
	GameTooltip:Show()
	T.eq(#GameTooltip.lines, 0)
end)

T.test("debug prints each distinct title once", function()
	local ns = setup("|cffffffffMystery Stat|r 5")
	StatLensDB.debug = true
	GameTooltip:Show()
	GameTooltip:Clear()
	GameTooltip:Show()
	local count = 0
	for _, m in ipairs(S.chat) do if m:find("Mystery Stat 5", 1, true) then count = count + 1 end end
	T.eq(count, 1)
end)
