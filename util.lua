uv = require "uv"

local function table_patch(table, patches)
    for k, v in pairs(patches) do
        if type(table[k]) == "table" then
            if (not next(table)) or #table ~= 0 then
                table[k] = v
            else
                table_patch(table[k], patches[k])
            end
        else
            table[k] = v
        end
    end
    return table
end

_G.response_types = {
    json = "application/json"
}

function _G.errorcode(res, code, msg)
    res.code = code
    if msg then
        res.headers["Content-Type"] = "text/plain"
        res.body = msg
    end
end

function _G.unavailable(_, res)
    errorcode(res, 503, "503 Service Unavailable")
end

table.patch = table_patch

function table.v2k(t)
	local new = {}
	for k, v in pairs(t) do
		new[v] = k
	end
	return new
end

function table.keyof(t, v)
    for k, w in pairs(t) do
        if v == w then
            return k
        end
    end
    return nil
end

function table.indexof(t, v)
    for i, _, w in ipairs(t) do
        if v == w then
            return i
        end
    end
    return nil
end

function table.indexofkey(t,k)
    for i, l in ipairs(t) do
        if l == k then
            return i
        end
    end
end

function table.keylist(t)
    local u = {}
    for k in pairs(t) do
        table.insert(u, k)
    end
    return u
end

function table.hasleftinright(t,u)
    for _, v in pairs(t) do
        for _, w in pairs(u) do
            if v == w then
                return true
            end
        end
    end
    return false
end

-- Properly clones tree(table) in first argument, and returns it.
-- In another words, ProperTree!
-- Normally, if you use new = oldtable, it will clone table ID as well.
-- Because the ID is same, both table will be same. If you edit one, the other one will change.
-- This will effectively clone the table, while getting a new ID.
function table.clone(tbl)
    local t = {}
    for k, v in pairs(tbl) do
        local v = v
        if type(v) == "table" then
            v = table.clone(v)
        end
        t[k] = v
    end
    return t
end

function _G.setTimeout(timeout, callback)
  local timer = uv.new_timer()
  timer:start(timeout, 0, function ()
    timer:stop()
    timer:close()
    callback()
  end)
  return timer
end

function _G.setInterval(interval, callback)
  local timer = uv.new_timer()
  timer:start(interval, interval, function ()
    callback()
  end)
  return timer
end

function _G.clearInterval(timer)
  timer:stop()
  timer:close()
end