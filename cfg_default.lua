local c = {
    log_level = "info",
    port = 8080,
    host = "0.0.0.0",

    --[[
    tls = { TLS
        host = "0.0.0.0".
        port = 8443,
        tls = {
            cert = file.read("cert.pem"),
            key = file.read("key.pem")
        }
    },
    ]]
    tlsonly = false,
}

return c