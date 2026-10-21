local S = require("wow_stubs")

local FILES = { "Core.lua", "Data/Shaman.lua", "Talents.lua", "Stats.lua", "Calc.lua", "Format.lua", "Tooltip.lua" }

local function newTooltip()
	local tt = { lines = {}, scripts = {} }
	function tt:AddLine(text, r, g, b, wrap) self.lines[#self.lines + 1] = text end
	function tt:Show() self.shown = true end
	function tt:HookScript(n, fn) self.scripts[n] = fn end
	function tt:Clear() if self.scripts.OnTooltipCleared then self.scripts.OnTooltipCleared(self) end self.lines = {} end
	return tt
end

local function setup(opts)
	opts = opts or {}
	S.reset()
	local cb
	if not opts.noProcessor then
		_G.TooltipDataProcessor = { AddTooltipPostCall = function(_, fn) cb = fn end }
		_G.Enum = { TooltipDataType = { Spell = 1 } }
	else
		_G.TooltipDataProcessor, _G.Enum = nil, nil
	end
	_G.GameTooltip = newTooltip()
	local hooks = {}
	_G.hooksecurefunc = function(obj, name, fn) hooks[name] = fn end
	_G.UnitStat = function(_, i) return 341, 341 end
	_G.UnitAttackPower = function() return 500, 0, 0 end
	_G.GetSpellBonusDamage = function() return 300 end
	_G.GetCritChance = function() return 10 end
	_G.GetSpellCritChance = function() return 8 end
	_G.GetDodgeChance = function() return 5 end
	_G.GetParryChance = function() return 5 end
	_G.C_ClassTalents = { GetActiveConfigID = function() return 9 end }
	_G.C_Spell = { GetSpellName = function(id) return ({ [100] = "Ancestral Knowledge", [555] = "Fireball" })[id] end }
	_G.C_Traits = {
		GetConfigInfo = function() return { treeIDs = { 1 } } end,
		GetTreeNodes = function() return { 1 } end,
		GetNodeInfo = function() return { ID = 1, entryIDs = { 1 }, currentRank = 2 } end,
		GetEntryInfo = function() return { definitionID = 1 } end,
		GetDefinitionInfo = function() return { spellID = 101 } end, -- next-rank id
	}
	_G.C_Spell.GetSpellName = function(id) return ({ [101] = "Ancestral Knowledge", [555] = "Fireball" })[id] end
	local ns = {}
	for _, f in ipairs(FILES) do S.loadAddonFile(f, ns) end
	S.fire("ADDON_LOADED", "StatLens")
	ns.Talents.Refresh()
	return ns, cb, hooks
end

T.test("processor callback appends lines for talent spell", function()
	local ns, cb = setup()
	cb(GameTooltip, { id = 101 })
	T.eq(GameTooltip.lines[1], " ")
	T.eq(GameTooltip.lines[2], "StatLens")
	T.eq(GameTooltip.lines[3], "Now: +" .. ("%d"):format(math.floor(341 - 341 / 1.04 + 0.5)) .. " Intellect")
	T.truthy(GameTooltip.shown)
end)

T.test("name fallback when spellID differs", function()
	local ns, cb = setup()
	cb(GameTooltip, { id = 99999 })
	T.eq(#GameTooltip.lines, 0, "unknown id and unknown name adds nothing")
	_G.C_Spell.GetSpellName = function() return "Ancestral Knowledge" end
	cb(GameTooltip, { id = 99999 })
	T.eq(GameTooltip.lines[2], "StatLens")
end)

T.test("non-talent spell adds nothing", function()
	local ns, cb = setup()
	cb(GameTooltip, { id = 555 })
	T.eq(#GameTooltip.lines, 0)
end)

T.test("secret stats -> combat line only", function()
	local ns, cb = setup()
	-- Every stat secret; the spellID itself stays plain (a secret spellID adds nothing at all).
	_G.issecretvalue = function(v) return type(v) == "number" and v ~= 101 end
	cb(GameTooltip, { id = 101 })
	T.eq(#GameTooltip.lines, 2)
	T.eq(GameTooltip.lines[2], "StatLens: unavailable in combat")
end)

T.test("no double append until cleared", function()
	local ns, cb = setup()
	cb(GameTooltip, { id = 101 })
	local n = #GameTooltip.lines
	cb(GameTooltip, { id = 101 })
	T.eq(#GameTooltip.lines, n, "second call ignored")
	GameTooltip:Clear()
	cb(GameTooltip, { id = 101 })
	T.eq(#GameTooltip.lines, n, "appends again after clear")
end)

T.test("fallback hooksecurefunc path", function()
	local ns, cb, hooks = setup({ noProcessor = true })
	T.truthy(hooks.SetSpellByID, "hooked")
	hooks.SetSpellByID(GameTooltip, 101)
	T.eq(GameTooltip.lines[2], "StatLens")
end)

T.test("toggle off adds nothing; /sl tooltip toggles", function()
	local ns, cb = setup()
	T.eq(StatLensDB.tooltip, true, "default")
	SlashCmdList.STATLENS("tooltip")
	T.eq(StatLensDB.tooltip, false)
	cb(GameTooltip, { id = 101 })
	T.eq(#GameTooltip.lines, 0)
	SlashCmdList.STATLENS("tooltip")
	T.eq(StatLensDB.tooltip, true)
end)

T.test("affected secret stat adds an unavailable line", function()
	local ns, cb = setup()
	_G.UnitStat = function(_, i) return i == 4 and 999 or 341, i == 4 and 999 or 341 end
	_G.issecretvalue = function(v) return v == 999 end
	cb(GameTooltip, { id = 101 })
	T.eq(GameTooltip.lines[2], "StatLens")
	T.eq(GameTooltip.lines[#GameTooltip.lines], "StatLens: Intellect unavailable right now")
end)

T.test("unrelated secret stat adds no unavailable line", function()
	local ns, cb = setup()
	_G.UnitHealthMax = function() return 777 end
	_G.issecretvalue = function(v) return v == 777 end
	cb(GameTooltip, { id = 101 })
	for _, l in ipairs(GameTooltip.lines) do T.truthy(not l:find("unavailable", 1, true), l) end
	T.eq(GameTooltip.lines[3], "Now: +" .. ("%d"):format(math.floor(341 - 341 / 1.04 + 0.5)) .. " Intellect")
end)

T.test("secret spellID adds nothing without raising", function()
	local ns, cb = setup()
	StatLensDB.debug = true
	local function trap() error("secret spellID inspected", 2) end
	local secret = setmetatable({}, { __eq = trap, __lt = trap, __le = trap, __index = trap, __concat = trap })
	local seen = false
	_G.issecretvalue = function(v) if rawequal(v, secret) then seen = true return true end return false end
	cb(GameTooltip, { id = secret })
	T.truthy(seen, "checked with IsSecret")
	T.eq(#GameTooltip.lines, 0)
	for _, m in ipairs(S.chat) do T.truthy(not m:find("tooltip error", 1, true), m) end
end)

T.test("append checks IsSecret before testing spellID", function()
	local ns, cb = setup()
	local log = {}
	_G.issecretvalue = function(v) log[#log + 1] = v == nil and "nil" or v return false end
	cb(GameTooltip, { id = nil })
	T.eq(log[1], "nil", "IsSecret ran on the nil spellID first")
	T.eq(#GameTooltip.lines, 0)
end)
