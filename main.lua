require "string-extensions"
require "util"

_G.fs = require "fs"
_G.json = require "json"

local rqluvit = require
_G.require = rqluvit

_G.cfg = require "cfg_default"
if fs.existsSync "cfg.lua" then
    if not pcall(function() require "cfg" end) then
        print "cfg.lua failed to load"
        os.exit(1)
    end
    cfg = table.patch(_G.cfg, require "cfg")
end

_G.l = require "logger" (cfg.log_level)

app = require('weblit-app')
	.bind({
		host = cfg.host,
		port = cfg.port,
		tls = cfg.tls
	})

	.use(require "weblit-logger")
	.use(require "weblit-auto-headers")
	.use(require "weblit-etag-cache")
	.use(require "weblit-static" ("static"))

occr = require "newoccrmain"

app.route({
		method = "POST",
		path = "/api/v1/check"
	}, function (req, res, go)
		res.body = occr(req.body)
		res.code = 200
	end)

	.start()
