-- Run from repo root: lua5.1 tests/run.lua
package.path = "tests/?.lua;" .. package.path

local T = { passed = 0, failed = 0 }

local function fail(msg, detail)
	T.failed = T.failed + 1
	print(("  FAIL %s: %s"):format(msg or "?", detail))
end

local function pass() T.passed = T.passed + 1 end

function T.eq(actual, expected, msg)
	if actual == expected then return pass() end
	fail(msg, ("expected %s, got %s"):format(tostring(expected), tostring(actual)))
end

function T.near(a, b, eps, msg)
	if type(a) == "number" and type(b) == "number" and math.abs(a - b) <= eps then return pass() end
	fail(msg, ("expected %s ~= %s (eps %s)"):format(tostring(a), tostring(b), tostring(eps)))
end

function T.truthy(v, msg)
	if v then return pass() end
	fail(msg, "expected truthy, got " .. tostring(v))
end

function T.test(name, fn)
	local before = T.failed
	local ok, err = pcall(fn)
	if not ok then
		T.failed = T.failed + 1
		print(("  ERROR %s: %s"):format(name, tostring(err)))
	elseif T.failed == before then
		print("  ok " .. name)
	end
end

_G.T = T

local p = io.popen("ls tests/test_*.lua")
local files = {}
for line in p:lines() do files[#files + 1] = line end
p:close()

for _, file in ipairs(files) do
	print(file)
	local chunk, err = loadfile(file)
	if not chunk then
		T.failed = T.failed + 1
		print("  ERROR load: " .. tostring(err))
	else
		local ok, runErr = pcall(chunk)
		if not ok then
			T.failed = T.failed + 1
			print("  ERROR " .. tostring(runErr))
		end
	end
end

print(("\n%d passed, %d failed"):format(T.passed, T.failed))
if T.failed > 0 then os.exit(1) end
