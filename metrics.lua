
local metrics = {}
local metrics_namespace_prefix = nil
local host = nil
local port = nil

function metrics.init(conf)
    metrics_namespace_prefix = conf.metrics_namespace_prefix
    host = conf.host
    port = conf.port
    ngx.log(ngx.NOTICE, "init metrics: prefix: ", metrics_namespace_prefix)
    ngx.log(ngx.NOTICE, "init metrics: host: ", host)
    ngx.log(ngx.NOTICE, "init metrics: port: ", port)
end

function metrics.send(req)
    local msgpack = require 'cmsgpack'
    msg = msgpack.pack(req)
    local udp = ngx.socket.udp()
    udp:setpeername(host, port)
    udp:send(msg)
end

function metrics.c(name, prefix)
    if prefix then
        return string.format('%s.%s', prefix, name)
    else
        return string.format('%s.%s', metrics_namespace_prefix, name)
    end
end

function metrics.emit_counter(name, value, prefix)
    local cname = metrics.c(name, prefix)
    req = {'emit', 'counter', cname, tostring(value), '', ''}
    metrics.send(req)
end

return metrics
