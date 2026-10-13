local ADDON, ns = ...

ns.failedEvents = {}
ns.commands = {}

local PREFIX = "|cff33ccffStatLens:|r "
local handlers = {}
local frame = CreateFrame("Frame")

frame:SetScript("OnEvent", function(_, event, ...)
	local list = handlers[event]
	if not list then return end
	for i = 1, #list do
		list[i](...)
	end
end)

function ns.On(event, fn)
	local list = handlers[event]
	if not list then
		list = {}
		handlers[event] = list
		local ok, err = pcall(frame.RegisterEvent, frame, event)
		if not ok then ns.failedEvents[event] = tostring(err) end
	end
	list[#list + 1] = fn
end

function ns.IsSecret(v)
	return issecretvalue ~= nil and issecretvalue(v) or false
end

function ns.Print(msg)
	DEFAULT_CHAT_FRAME:AddMessage(PREFIX .. tostring(msg))
end

ns.On("ADDON_LOADED", function(name)
	if name ~= ADDON then return end
	StatLensDB = StatLensDB or {}
	if StatLensDB.debug == nil then StatLensDB.debug = false end
end)

ns.commands.help = function()
	local names = {}
	for name in pairs(ns.commands) do names[#names + 1] = name end
	table.sort(names)
	ns.Print("commands: " .. table.concat(names, ", "))
end

ns.commands.debug = function()
	StatLensDB = StatLensDB or {}
	StatLensDB.debug = not StatLensDB.debug
	ns.Print("debug " .. (StatLensDB.debug and "on" or "off"))
end

SLASH_STATLENS1 = "/statlens"
SLASH_STATLENS2 = "/sl"
SlashCmdList.STATLENS = function(input)
	local cmd, args = (input or ""):match("^%s*(%S*)%s*(.-)%s*$")
	local fn = ns.commands[cmd:lower()]
	if fn then fn(args) else ns.commands.help() end
end
