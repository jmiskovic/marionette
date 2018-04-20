local bubbles = {}
bubbles.__index = bubbles

bubbles.wpm = 100    -- words per minute (used if timeout is not specified)
bubbles.wrap = 40    -- attempt to break line after this number of characters (only if input string is single line)
bubbles.margin = 15  -- distance in pixels from text boundaries to frame (also, roundness of frame)
bubbles.tail = 50    -- height of bubble tail in pixels

bubbles.fontsize = 18
bubbles.fontface = "Komika_display.ttf"
bubbles.colorFrame = {200/255, 230/255, 230/255, 200/255}
bubbles.colorFont  = {20/255, 20/255, 20/255, 255/255}

bubbles.font = love.graphics.newFont(bubbles.fontface, bubbles.fontsize)

local function countChars(text, pattern)
    local count = 0
    for w in string.gmatch(text, pattern) do
        count = count + 1
    end
    return count
end

function bubbles:create(text, originX, originY, timeout)
    local bubble = setmetatable({}, bubbles)
    local words = countChars(text, ' ')
    bubble.text = text
    bubble.x, bubble.y = originX, originY
    bubble.timeout = timeout
    bubble.dynamic = false
    bubbles:computeGeometry(bubble)
    table.insert(bubbles, bubble)
    return bubble
end

function bubbles:computeGeometry(bubble)
    bubble.lines = countChars(bubble.text, '\n') + 1
    bubble.frameWidth =  bubble.font:getWidth(bubble.text) + bubble.margin * 2
    bubble.frameHeight = bubble.font:getHeight() * bubble.lines + bubble.margin * 2
    if bubble.frameX then
        bubble.frameX = bubble.frameX + (bubble.x - bubble.frameX) * 0.05
        bubble.frameY = bubble.frameY + (bubble.y - bubble.tail - bubble.frameHeight - bubble.frameY) * 0.05
    else
        bubble.frameX = bubble.x
        bubble.frameY = bubble.y - bubble.tail - bubble.frameHeight
    end
    if (rawget(bubble, 'fontface') or rawget(bubble, 'fonttype')) and not rawget(bubble, 'font') then
        bubble.font = love.graphics.newFont('ComickBook_Simple.ttf', bubble.fontsize)
    end
end

function bubbles:draw(text, originx, originy)
    love.graphics.setLineWidth(4)
    for i,b in ipairs(bubbles) do
        if (b.dynamic) then
            bubbles:computeGeometry(b)
        end
        love.graphics.setFont(b.font)
--        love.graphics.setColor(b.colorFont)
--        love.graphics.rectangle('line',
--            b.frameX, b.frameY,
--            b.frameWidth, b.frameHeight,
--            b.margin)
--        love.graphics.polygon('line',
--            b.frameX + b.margin,     b.frameY + b.frameHeight,
--            b.frameX + b.margin * 2, b.frameY + b.frameHeight,
--            b.x, b.y)
        love.graphics.setColor(b.colorFrame)
        love.graphics.rotate(-math.pi/32)
        love.graphics.rectangle('fill',
            b.frameX, b.frameY,
            b.frameWidth, b.frameHeight,
            b.margin)
        love.graphics.polygon('fill',
            b.frameX + b.margin,     b.frameY + b.frameHeight,
            b.frameX + b.margin * 2, b.frameY + b.frameHeight,
            b.x, b.y - 2)
        love.graphics.setColor(b.colorFont)
        love.graphics.print(b.text, b.frameX + b.margin, b.frameY + b.margin)
    end
end

function love:draw()
    bubbles.draw()
end

-- work in progress on automatic text wrapping (should this even be here?)
--    if #text > bubbles.wrap and not string.find(text, '\n') then
--        local segment = string.sub(text, 1, bubbles.wrap)
--        local breaking = string.find(string.reverse(segment), ' ')
--        print('breaking into lines')
--        if breaking then
--            print(string.sub(segment, 1, #segment - breaking))
--            print(string.sub(segment, -breaking))
--        end
--    end

return bubbles