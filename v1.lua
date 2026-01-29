return function(data)
local tttt = ""
local function print(...)
	for _, v in pairs({...}) do
		tttt = tttt..tostring(v).."\n"
	end
end
local returns, data = OCCR.run(data)
local function show(name, tbl)
	local ts = ""
	local i = 0
	if next(tbl) then
		print(name..":")
		for k in pairs(tbl) do
			i = i + 1
			ts = ts..k.."  "
			if i >= 4 then
				print("  "..ts)
				i = 0
				ts = ""
			end
		end
		if i ~= 0 then
			print("  "..ts)
		end
		print("")
	end
end

show("Kexts", data.kexts.normal)
show("Kexts (plugin)", data.kexts.plugin)
show("Kexts (disabled)", data.kexts.disabled.normal)
show("Kexts (disabled plugins)", data.kexts.disabled.plugin)

show("SSDTs", data.ssdts.enabled)
show("SSDTs (disabled)", data.ssdts.disabled)

show("Drivers", data.drivers.enabled)
show("Drivers (disabled)", data.drivers.disabled)

local maxlen = 0
for _, v in pairs(data.plist.DeviceProperties.Add) do
	for k in pairs(v) do
		if k:len() > maxlen then
			maxlen = k:len()
		end
	end
end
if next(data.plist.DeviceProperties.Add) then
	print "DeviceProperties:"
	for k, v in pairs(data.plist.DeviceProperties.Add) do
		print("  "..k)
		for l, w in pairs(v) do
			local symbol = "   |"
			print(symbol..l..string.rep(" ", (maxlen - l:len())).."| "..tostring(w))
		end
	end
	print("")
end

---@diagnostic disable-next-line: param-type-mismatch
for _, k in pairs(returns.order) do
	local t = returns.result[k]
	if next(t.result) then
		print(("%s (%d/%d):"):format(k, t.checked, t.total))
		for _, v in pairs(t.result) do
			print(" "..v)
		end
		print("")
	end
end

if #returns.errormsges ~= 0 then
	print "Warning:"
	print(returns.errormsges)
end
return tttt
end