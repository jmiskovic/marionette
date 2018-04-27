function love.conf(t)
  local resolutions = {
    [0] = {360, 640},
    [1] = {480, 854},
    [2] = {576, 1024},
    [3] = {720, 1280},  -- most common Android resolution
    [4] = {768, 1280},  -- Nexus4
    [5] = {900, 1600},
    [6] = {1080, 1920}, -- most common desktop full screen
    [7] = {1440, 2960}, -- Samsung Galaxy S8
    [8] = {1280, 720},  -- most common Android resolution
  }
  t.window.title = "Marionette"
  t.window.fullscreen = false
  t.window.resizable = true
  t.window.vsync = false
  t.window.width, t.window.height = unpack(resolutions[3])
  -- for android need to use:
  -- t.window.height, t.window.width = unpack(resolutions[3])

  love.filesystem.setIdentity('marionette')
end
