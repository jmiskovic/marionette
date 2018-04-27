console = {}

local l = require('lume')

local entry = ''
local color = {l.hsl(0.08, 0.20, 0.20)}
local font = love.graphics.newFont('Komika_display.ttf', 40)
local fontStats = love.graphics.newFont('DejaVuSansMono-Bold.ttf', 20)

love.keyboard.setKeyRepeat(true)

local stimulusCallbacks = {}
local response = nil

function console.addStimulusCallback(f)
  table.insert(stimulusCallbacks, f)
end

function console.draw()
  color[4] = 0.2
  love.graphics.setColor(color)
  love.graphics.rectangle('fill', 0, 0, love.graphics.getWidth(), 60)
  color[4] = 1
  love.graphics.setColor(color)
  love.graphics.setFont(font)
  love.graphics.print(entry, 50, 5)
  --love.graphics.setFont(fontStats)
  --love.graphics.print(inspect(), 5, 60)
end

function console.interpret(s)
  if string.find(s, "^%a") then
    for i, callback in ipairs(stimulusCallbacks) do
      response = callback(s)
     end
  elseif string.find(s, "!") then
    addExpression(adamHead.pose)
  elseif string.find(s, ">(%a+) ([%+%-%d.]+)") and response then
    local axis, change = string.match(s, ">(%a+) ([%+%-%d.]+)")
    local v = tonumber(change)
    if v then
      response.vector[axis] = (response.vector[state] or 0) + v
      adam.state[axis] = (adam.state[axis] or 0) + v
      print(response.vector[axis], adam.state[axis])
    else
      print('could not parse', axis, change, value, type(v))
    end
  end

end

function console.keypressed(key)
  if key == 'return' or key == 'kpenter' then
    console.interpret(entry)
    entry = ''
  elseif key == 'backspace' then
    entry = string.sub(entry, 1, #entry-1)
  end
end


function love.textinput(t)
  entry = entry .. t
end


return console