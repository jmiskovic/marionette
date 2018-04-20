local handles = {}

local l = require('lume')

handles.size = 13 -- todo: scale to resolution: sw / 20
handles.color = {l.hsl(0.06, 1.00, 0.94, 0.8)}
handles.background = {0.2, 0.2, 0.2, 0.6}
handles.current = {}
local showNames = true
local handled = {}  -- table with values in local coordinates
local points = {}  -- handle names -> {x, y} in screen coordinates
local grabs = {}   -- touchId -> handle names that are currently grabbed

local font = love.graphics.newFont('Komika_display.ttf', handles.size)

local reverseOrder = false

function handles.update()
  local touches = love.touch.getTouches()
  for _,id in ipairs(touches) do
    local x, y = love.touch.getPosition(id)
    x, y = love.graphics.inverseTransformPoint(x, y)
    if grabs[id] then
      points[grabs[id]] = {x, y}
      points[grabs[id]].moved = true
    else
      local pointNames = l.keys(points)
      local iterfunc = reverseOrder and l.ripairs or ipairs
      for i, mark in iterfunc(pointNames) do
        local pos = points[mark]
        if (x - pos[1])^2 + (y - pos[2])^2 < (handles.size)^2 * 1.5 then
          grabs[id] = mark
          points[mark] = {x, y}
          reverseOrder = not reverseOrder
          break
        end
      end
    end
  end
end

function handles.draw()
  love.graphics.setFont(font)
  local height = font:getHeight()
  for name, point in pairs(points) do
    -- draw background for handle text to be more visible
    if showNames then
      love.graphics.setColor(handles.background)
      local width = font:getWidth(name)
      love.graphics.rectangle('fill',
        point[1] + handles.size * 0.95, point[2],
        width * 1.1, height)
    end
    love.graphics.setColor(handles.color)
    love.graphics.circle('fill', point[1], point[2], handles.size)
    if showNames then
      love.graphics.print(name, point[1] + handles.size * 1.1, point[2])
    end
    point.updated = false
  end
end

-- create handles for table values
function handles.set(parent, child)
  points = {}
  handled = parent[child]
  handles.current = {parent, child}

  local handledTable = setmetatable({}, {
    __index = function (tbl, name)
      -- here handle points (screen coords) interact with form/pose points (local coords)
      -- it's important for transformPoint() and inverseTransformPoint() that they
      --  are called in context of metatable access, with correct current coodinate system
      if points[name] and points[name].moved then
        local x, y = love.graphics.inverseTransformPoint(unpack(points[name]))
        handled[name] = {x, y}
        points[name].moved = false
        points[name].updated = true
        return handled[name]
      elseif not (points[name] and points[name].updated) then
      -- set handle point to handled point, transformed to screen coordinates
        handled[name] = handled[name] or {0,0}
        local x, y = love.graphics.transformPoint(unpack(handled[name]))
        points[name] = {x, y}
        points[name].updated = true
        return handled[name]
      else
        return handled[name]
      end
    end,
    __serialize = function (t)
      return handled
    end,
    })
  parent[child] = handledTable
end

-- create handles for table values
function handles.release()
  if handles.current[1] and handles.current[2] and handled then
    local parent, child = unpack(handles.current)
    parent[child] = handled
  end
  points = {}
  handles.current = {}
end

function love.touchreleased(id)
  grabs[id] = nil
end

return handles