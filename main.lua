local head = require('head')
local persist = require('persist')
local model = require('model')
local console = require('console')

local l = require('lume')
handles = require('handles')

local sw, sh = love.graphics.getDimensions()
local editModes = {
  'none',
  'model',
  'form',
  'pose',
}
local mode = 1

adamHead = head.new()
adamHead:loadForm()
console.addStimulusCallback(respond)

function love.resize()
  if love.system.getOS() == 'Android' then
    sh, sw = love.graphics.getDimensions()
  else
    sw, sh = love.graphics.getDimensions()
  end
end

function love.load()
  love.graphics.setBackgroundColor({l.hsl(0.08, 0.05, 0.52)})
  love.resize()
  style = {
      font = love.graphics.newFont('Komika_display.ttf', 13),
      showBorder = true,
      bgColor = {0.208, 0.220, 0.222}
  }
end

local time = 0
function love.update(dt)
  time = time + dt

  love.graphics.origin()
  --love.graphics.translate(200, 200)
  --love.graphics.scale(200, 200)
  handles.update(dt)
end

function love.draw()
  love.graphics.translate(sw/2, sh*0.6)
  love.graphics.scale(sw/2, sw/2)
  love.graphics.scale(0.8,0.8)
  love.graphics.setColor(0.6, 0.6, 0.6, 0.3)
  --love.graphics.rectangle('fill', -1, -1, 2, 2)
  if mode ~= 4 then
    local pose = express()
    if pose then


      for k,v in pairs(pose) do
        adamHead.pose[k] = v
        --print(k)
        if k == 'rightLip' then print('rl', v[2]) end
      end
    end
  end
  head.draw(adamHead)
  love.graphics.origin()
--  if editModes[mode] == 'form' or editModes[mode] == 'pose' then
    handles.draw()
--  elseif editModes[mode] == 'model' then
--    local y = sh/10
--    local x = sw/10
--    for k,v in pairs(model.feel) do
--      print('adam.feel.happy', k, x, y)
--      love.graphics.print(k, x, y)
--    end
--  end
  love.graphics.origin()
  console.draw()
end

function love.touchpressed()
end

function center()
  if love.system.getOS() == 'Android' then
    love.graphics.translate(sh/2, sw/2)
    love.graphics.scale(sw/2 * 0.9, sw/2 * 0.9)
    love.graphics.rotate(-math.pi/2)
  else
    love.graphics.translate(sw/2, sh/2)
    love.graphics.scale(sw/2 * 0.9, sw/2 * 0.9)
  end
end

function love.keypressed(key)
  if key == 'tab' or key == 'escape' then
    mode = mode % #editModes + 1
    if editModes[mode] == 'form' then
      handles.release()
      handles.color = {l.hsl(0.06, 1.00, 0.94, 0.8)}
      handles.set(adamHead, 'form')
    elseif editModes[mode] == 'pose' then
      handles.release()
      handles.color = {l.hsl(0.56, 1.00, 0.94, 0.8)}
      handles.set(adamHead, 'pose')
    elseif editModes[mode] == 'model' then
      handles.release()
      handles.color = {l.hsl(0.76, 1.00, 0.94, 0.8)}
      model.edit = {happy={200, 10}, tired={100, 40}}
      handles.set(model, 'edit')
      model.edit.happy[2] = 1 * sh / 10
      model.edit.tired[2] = 2 * sh / 10
    elseif editModes[mode] == 'none' then
      handles.release()
    end
  elseif key == 'f2' then
    print('saving')
    persist.store(adamHead.form, 'headform_adam')
  else
    console.keypressed(key)
  end
end

function rescueData(sufix)
  --handles.releaseTarget(adamHead, 'form')
  sufix = sufix or 'rescued'
  io.write("Trying to save head to 'head_"..sufix.."' file.. ")
  if pcall(persist.store, adamHead, 'head_'..sufix) then
    print("success")
  else
    print("failure")
  end
end

function love.quit()
  --rescueData('unsaved')
end

local utf8 = require("utf8")
local function error_printer(msg, layer)
  print((debug.traceback("Error: " .. tostring(msg), 1+(layer or 1)):gsub("\n[^\n]+$", "")))
end

function love.errorhandler(msg)
  rescueData('rescued')
  msg = tostring(msg)

  error_printer(msg, 2)

  if not love.window or not love.graphics or not love.event then
    return
  end

  if not love.graphics.isCreated() or not love.window.isOpen() then
    local success, status = pcall(love.window.setMode, 800, 600)
    if not success or not status then
      return
    end
  end

  -- Reset state.
  if love.mouse then
    love.mouse.setVisible(true)
    love.mouse.setGrabbed(false)
    love.mouse.setRelativeMode(false)
    if love.mouse.isCursorSupported() then
      love.mouse.setCursor()
    end
  end
  if love.joystick then
    -- Stop all joystick vibrations.
    for i,v in ipairs(love.joystick.getJoysticks()) do
      v:setVibration()
    end
  end
  if love.audio then love.audio.stop() end

  love.graphics.reset()
  local font = love.graphics.setNewFont(14)

  love.graphics.setColor(1, 1, 1, 1)

  local trace = debug.traceback()

  love.graphics.origin()

  local sanitizedmsg = {}
  for char in msg:gmatch(utf8.charpattern) do
    table.insert(sanitizedmsg, char)
  end
  sanitizedmsg = table.concat(sanitizedmsg)

  local err = {}

  table.insert(err, "Error\n")
  table.insert(err, sanitizedmsg)

  if #sanitizedmsg ~= #msg then
    table.insert(err, "Invalid UTF-8 string in error message.")
  end

  table.insert(err, "\n")

  for l in trace:gmatch("(.-)\n") do
    if not l:match("boot.lua") then
      l = l:gsub("stack traceback:", "Traceback\n")
      table.insert(err, l)
    end
  end

  local p = table.concat(err, "\n")

  p = p:gsub("\t", "")
  p = p:gsub("%[string \"(.-)\"%]", "%1")

  local function draw()
    local pos = 70
    love.graphics.clear(189/255, 157/255, 220/255)
    love.graphics.printf(p, pos, pos, love.graphics.getWidth() - pos)
    love.graphics.present()
  end

  local fullErrorText = p
  local function copyToClipboard()
    if not love.system then return end
    love.system.setClipboardText(fullErrorText)
    p = p .. "\nCopied to clipboard!"
    draw()
  end

  if love.system then
    p = p .. "\n\nPress Ctrl+C or tap to copy this error"
  end

  return function()
    love.event.pump()

    for e, a, b, c in love.event.poll() do
      if e == "quit" then
        return 1
      elseif e == "keypressed" and a == "escape" then
        return 1
      elseif e == "keypressed" and a == "c" and love.keyboard.isDown("lctrl", "rctrl") then
        copyToClipboard()
      elseif e == "touchpressed" then
        local name = love.window.getTitle()
        if #name == 0 or name == "Untitled" then name = "Game" end
        local buttons = {"OK", "Cancel"}
        if love.system then
          buttons[3] = "Copy to clipboard"
        end
        local pressed = love.window.showMessageBox("Quit "..name.."?", "", buttons)
        if pressed == 1 then
          return 1
        elseif pressed == 3 then
          copyToClipboard()
        end
      end
    end

    draw()

    if love.timer then
      love.timer.sleep(0.1)
    end
  end

end

function love.run()
  if love.load then love.load(love.arg.parseGameArguments(arg), arg) end

  -- We don't want the first frame's dt to include time taken by love.load.
  if love.timer then love.timer.step() end

  local dt = 0

  -- Main loop time.
  return function()
    -- Process events.
    if love.event then
      love.event.pump()
      for name, a,b,c,d,e,f in love.event.poll() do
        if name == "quit" then
          if not love.quit or not love.quit() then
            return a or 0
          end
        end
        love.handlers[name](a,b,c,d,e,f)
      end
    end

    -- Update dt, as we'll be passing it to update
    if love.timer then dt = love.timer.step() end

    -- Call update and draw
    if love.update then love.update(dt) end -- will pass 0 if love.timer is disabled

    if love.graphics and love.graphics.isActive() then
      love.graphics.origin()
      love.graphics.clear(love.graphics.getBackgroundColor())

      if love.draw then love.draw() end

      love.graphics.present()
    end

    if love.timer then love.timer.sleep(0.02) end
  end
end