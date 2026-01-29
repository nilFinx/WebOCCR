require "string-extensions"

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

fs = require "fs"

cfg = require "cfg_default"
if fs.existsSync "cfg.lua" then
    if not pcall(function() require "cfg" end) then
        print "cfg.lua failed to load"
        os.exit(1)
    end
    cfg = table_patch(_G.cfg, require "cfg")
end

l = require "logger" (cfg.log_level)

app = require('weblit-app')
	.bind({
		host = cfg.host,
		port = cfg.port,
		tls = cfg.tls
	})

	.use(require "weblit-logger")
	.use(require "weblit-auto-headers")
	.use(require "weblit-etag-cache")
	.use(require "weblit-static" ("static/v2"))
	.use(require "weblit-static" ("static"))

package.path = package.path .. ";occr/src/?.lua"
_G.OCCR = require "occr.src"

local v1 = require "v1"
app.route({
		method = "POST",
		path = "/api/v1/check"
	}, function (req, res, go)
		res.body = v1(req.body)
		res.code = 200
	end)

local v2 = require "v2"
app.route({
		method = "POST",
		path = "/api/v2/check"
	}, function (req, res, go)
		res.body = v2(req.body)
		res.code = 200
	end)


	.start()
