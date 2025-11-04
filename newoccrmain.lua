---@diagnostic disable: different-requires
local errormsges = ""
local entirefuckingmsgs = ""

-- Spit a warning without causing issues
function spit(msg)
	errormsges = errormsges..msg.."\n"
end

-- Assert spit
function aspit(condition, msg)
	if not condition then
		errormsges = errormsges..msg.."\n"
	end
	return condition
end

-- Spit that thang and return an empty table
function nulltable(msg)
	errormsges = errormsges..msg.."\n"
	return {}
end

function osxname(v)
	if v >= 10.12 then
		return "macOS "..tostring(v)
	elseif v >= 10.8 then
		return "OS X "..tostring(v)
	elseif v == 10.10 then
		return "OS X 10.10"
	else
		return "Mac OS X "..tostring(v)
	end
end

sblist = json.decode(fs.readFileSync("occonfigreader/occr/smbios.json"))
l:debug("smbios list loaded")

function occr_print(...)
    local m = {...}
    for _, v in pairs(m) do
        entirefuckingmsgs = entirefuckingmsgs..tostring(v).."\n"
    end
end

local mtblnew = {}
function mtblnew.__index(t, k)
	return setmetatable({}, mtblnew)
end

local mtblorg = {}
function mtblorg.__index(t, k)
	spit(k.." does not exist in the plist")
	return setmetatable({}, mtblnew)
end

local mtblapply
mtblapply = function(t)
	setmetatable(t, mtblorg)
	for _, v in pairs(t) do
		if type(v) == "table" then
			mtblapply(v)
		end
	end
end

local floxlist = require "occonfigreader.occr.floxlist"

return function(data)
errormsges = ""
entirefuckingmsgs = ""
local plist = floxlist(data)
mtblapply(plist)

plist.NVRAM.Add["7C"] = plist.NVRAM.Add["7C436110-AB2A-4BBB-A880-FE41995C9F82"] -- 7C exists now

local ssdts, drivers, kexts, tools, kextsarray, driversarray = {}, {}, {}, {}, {}, {}
local kextsshow = {normal = {}, plugin = {}, disabled = {}}
for _, v in pairs(plist.ACPI.Add) do
	local ssdtname = v.Path:match("(.+).aml")
	ssdts[ssdtname] = ssdtname
end

if type(plist.UEFI.Drivers[1]) == "string" then
	for _, v in pairs(plist.UEFI.Drivers) do
		local drvname = v:match("(.+).efi")
		drivers[drvname] = drvname
		table.insert(driversarray, drvname)
	end
else
	for _, v in pairs(plist.UEFI.Drivers) do
		local drvname = v.Path:match("(.+).efi")
		drivers[drvname] = drvname
		table.insert(driversarray, drvname)
	end
end

for _, v in pairs(plist.Kernel.Add) do
	local kextname = v.BundlePath:match "/?([-a-zA-Z0-9_]+).kext$"
	kexts[kextname] = v
	table.insert(kextsarray, kextname)
	table.insert(kextsshow[v.Enabled and (v.BundlePath:match("/") and "plugin" or "normal") or "disabled"], kextname)
end

for _, v in pairs(plist.Misc.Tools) do
	local toolname = v.Path:match("(.+).efi")
	tools[toolname] = toolname
end

local detections, order = require "occonfigreader.occr.detections"(plist, data, kexts, tools, drivers, ssdts, kextsshow, kextsarray, driversarray)
require "occonfigreader.occr.acpi_patch"(detections, order, plist)

local function load_plugin(name)
	pcall(function()require("occonfigreader.user."..name)(detections, order, plist, data, kexts, tools, drivers, ssdts, kextsshow, kextsarray, driversarray)end)
end

load_plugin "acpi_patch" -- Show ACPI patches

load_plugin "proppy" -- Proprietary checks

load_plugin "plugin" -- Default plugin name

print(order)

for _, k in pairs(order) do
	local total, checked = 0, 0
	local v = detections[k]
	local text = ""
	local function prnt(t)
		text = text .. t .. "\n"
	end
	local function show(name, tbl)
		occr_print(name..":")
		local ts = ""
		local i = 0
		for _, v in pairs(tbl) do
			i = i + 1
			ts = ts..v.." "
			if i >= 4 then
				occr_print(ts)
				i = 0
				ts = ""
			end
		end
		if i ~= 0 then
			occr_print(ts)
		end
		occr_print("")
	end
	if k == "Info" then
		show("Kexts", kextsshow.normal)
		show("Kexts (plugin)", kextsshow.plugin)
		show("Kexts (disabled)", kextsshow.disabled)

		show("SSDTs", ssdts)

		show("Drivers", drivers)

		occr_print("DeviceProperties: ")
		local maxlen = 0
		for _, v in pairs(plist.DeviceProperties.Add) do
			for k in pairs(v) do
				if k:len() > maxlen then
					maxlen = k:len()
				end
			end
		end
		local space = "                                                                                  "
		for k, v in pairs(plist.DeviceProperties.Add) do
			occr_print(k)
			for l, w in pairs(v) do
				local symbol = " |"
				occr_print(symbol..l..space:sub(l:len(), maxlen).."| "..tostring(w))
			end
		end
		text = text .. "\n"
	end
	if type(v) == "table" then -- Skip when empty
		for _, v in pairs(v) do
			local suc, msg, check = pcall(v)
			if suc then
				if msg then
					text = text .. msg .. "\n"
					if check ~= false then
						checked = checked + 1
					end
				end
				if check ~= false and msg ~= false then
					total = total + 1
				end
			else
				spit("check failed(please report!): " .. msg)
			end
		end
		occr_print(("%s"..((total > 1) and " (%i/%i):" or ":")):format(k, checked, total))
		occr_print(text)
	end
end

if errormsges ~= "" then
	occr_print "Warning:"
	occr_print(errormsges:sub(1, -1))
end

return entirefuckingmsgs
end