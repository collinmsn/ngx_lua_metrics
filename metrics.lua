
local metrics = {}
local metrics_namespace_prefix = nil
local udp = nil

function metrics.init(conf)
    metrics_namespace_prefix = conf.metrics_namespace_prefix
    local socket = require('socket')
    udp = socket.udp()
    udp:setpeername(conf.host, conf.port)
    ngx.log(ngx.NOTICE, "init metrics: prefix: ", metrics_namespace_prefix)
    ngx.log(ngx.NOTICE, "init metrics: host: ", conf.host)
    ngx.log(ngx.NOTICE, "init metrics: port: ", conf.port)
end

function metrics.send(req)
    local msgpack = require('cmsgpack')
    msg = msgpack.pack(req)
    udp:send(msg)
end

function metrics.c(name, prefix)
    if prefix then
        return string.format('%s.%s', prefix, name)
    else
        return string.format('%s.%s', metrics_namespace_prefix, name)
    end
end

function metrics.tagkv2str(tagkv)
    local tag_str = ''
    for k, v in pairs(tagkv) do
        if string.len(tag_str) > 0 then
            tag_str = tag_str .. '|'
        end
        tag_str = tag_str .. string.format('%s=%s', k, v)
    end
    return tag_str
end

function metrics.emit_counter(name, value, prefix, tagkv)
    local cname = metrics.c(name, prefix)
    local tag_str = metrics.tagkv2str(tagkv)
    req = {'emit', 'counter', cname, tostring(value), tag_str, ''}
    metrics.send(req)
end

function metrics.emit_timer(name, value, prefix, tagkv)
    local cname = metrics.c(name, prefix)
    local tag_str = metrics.tagkv2str(tagkv)
    req = {'emit', 'timer', cname, tostring(value), tag_str, ''}
    metrics.send(req)
end

function metrics.emit_store(name, value, prefix, tagkv)
    local cname = metrics.c(name, prefix)
    local tag_str = metrics.tagkv2str(tagkv)
    req = {'emit', 'store', cname, tostring(value), tag_str, ''}
    metrics.send(req)
end

return metrics
