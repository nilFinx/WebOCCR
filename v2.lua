json = require "deps.json"
return function(data)
local sections = {}
local order = {}
local returns, data = OCCR.run(data)
local function show(name, tbl)
	local ts = ""
	local i = 0
	if next(tbl) then
		local t = ""
		for k in pairs(tbl) do
			i = i + 1
			ts = ts..k.."  "
			if i >= 4 then
				t = t .. ("  "..ts) .. "\n"
				i = 0
				ts = ""
			end
		end
		if i ~= 0 then
			t = t .. ("  "..ts) .. "\n"
		end
		sections[name] = {text = t}
		table.insert(order, name)
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
	local t = ""
	for k, v in pairs(data.plist.DeviceProperties.Add) do
		t = t .. ("  "..k) .. "\n"
		for l, w in pairs(v) do
			local symbol = "   |"
			t = t .. (symbol..l..string.rep(" ", (maxlen - l:len())).."| "..tostring(w)) .. "\n"
		end
	end
	sections["DeviceProperties"] = {text = t}
	table.insert(order, "DeviceProperties")
end

---@diagnostic disable-next-line: param-type-mismatch
for _, k in pairs(returns.order) do
	local t = returns.result[k]
	local txt = ""
	if t and next(t.result) then
		for _, v in pairs(t.result) do
			txt = txt .. (" "..v) .. "\n"
		end
		txt = txt .. "\n"
		sections[k] = {text = txt, checked = t.checked, total = t.total}
	else
		sections[k] = {text = txt}
	end
	table.insert(order, k)
end

return json.encode({sections = sections, errors = returns.errormsges, order = order})
end