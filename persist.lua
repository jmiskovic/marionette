local persist = {}

local serpent = require('serpent')

function persist.store(data, filename)
    local content = 'return ' .. serpent.block(data, {comment=false})
    success, message = love.filesystem.write(filename, content)
    if not success then
        print(message)
    end
end

function persist.load(filename)
    local content, errormsg = love.filesystem.read(filename)
    if not content then
        print(errormsg)
        return content
    end
    local ok, data = serpent.load(content, {safe=true})
    return data
end

return persist