local S = require("wow_stubs")

local function load()
	S.reset()
	local ns = {}
	S.loadAddonFile("Core.lua", ns)
	return ns
end

T.test("ns.On dispatches to multiple handlers with args", function()
	local ns = load()
	local got = {}
	ns.On("PLAYER_LOGIN", function(...) got[#got + 1] = { "a", ... } end)
	ns.On("PLAYER_LOGIN", function(...) got[#got + 1] = { "b", ... } end)
	S.fire("PLAYER_LOGIN", 1, 2)
	T.eq(#got, 2, "both handlers ran")
	T.eq(got[1][1], "a"); T.eq(got[1][3], 2, "args forwarded")
	T.eq(got[2][1], "b")
end)

T.test("failing RegisterEvent is recorded, not fatal", function()
	S.reset()
	S.failRegister.BOGUS_EVENT = true
	local ns = {}
	S.loadAddonFile("Core.lua", ns)
	local ok = pcall(ns.On, "BOGUS_EVENT", function() end)
	T.truthy(ok, "no error thrown")
	T.truthy(ns.failedEvents.BOGUS_EVENT, "recorded in failedEvents")
end)

T.test("ns.IsSecret", function()
	local ns = load()
	_G.issecretvalue = nil
	T.eq(ns.IsSecret(5), false, "false without issecretvalue")
	_G.issecretvalue = function(v) return v == "s" end
	T.eq(ns.IsSecret("s"), true, "delegates (true)")
	T.eq(ns.IsSecret("x"), false, "delegates (false)")
end)

T.test("slash dispatch and help fallback", function()
	local ns = load()
	local called
	ns.commands.foo = function(args) called = args end
	SlashCmdList.STATLENS("foo bar baz")
	T.eq(called, "bar baz", "command receives args")
	S.chat = {}
	SlashCmdList.STATLENS("nope")
	T.truthy(#S.chat > 0, "help printed for unknown")
	T.eq(SLASH_STATLENS1, "/statlens"); T.eq(SLASH_STATLENS2, "/sl")
end)

T.test("ADDON_LOADED inits db; debug toggles", function()
	local ns = load()
	S.fire("ADDON_LOADED", "StatLens")
	T.eq(StatLensDB.debug, false, "default")
	SlashCmdList.STATLENS("debug")
	T.eq(StatLensDB.debug, true, "toggled")
end)
