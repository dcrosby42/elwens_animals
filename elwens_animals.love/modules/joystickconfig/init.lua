local ResourceLoader = require 'resourceloader'
local Debug = require('mydebug').sub('JoystickConfig', false, true)
local Joystick = require "modules.joystickconfig.joystick"
local JoystickView = require "modules.joystickconfig.joystickview"
local JoystickTracker = require "modules.joystickconfig.joysticktracker"
local JoystickMappings = require('crozeng.joystick')
local G = love.graphics

local M = {}

function M.newWorld()
  local res = ResourceLoader.buildResourceRootFromFile(
                  "modules/joystickconfig/resources.lua")
  return {
    res = res,
    tracker = JoystickTracker:new(),
    views = {},
    -- dualstickView = JoystickView.newJoystickView(
    --     res.data.generic_dualstick_layout),
  }
end

function M.updateWorld(w, action)
  if action.type == 'joystick' then w.tracker:update(action, w.res) end
  return w
end

function M.drawWorld(w, action)
  local i = 1
  local vw = 650
  for _id, joystick in pairs(w.tracker.byId) do
    G.push()
    G.translate(vw * (i - 1), 0)

    local jview = w.views[joystick.name]
    if not jview then
      -- local joystickConfig = w.tracker:getJoystickConfigFrom(w.res,
      --                                                        joystick.name)
      -- local joystickConfig = w.res.data.joysticks[joystick.name]
      -- if not joystickConfig then
      --   joystickConfig = w.res.data.joysticks["FALLBACK"]
      -- end
      -- assert(joystickConfig,
      --        "No joystick config named " .. tostring(joystick.name) ..
      --            " in joysticks=" .. inspect(w.res.data.joysticks))
      local layout = w.res.data.joystickViews[joystick.mapping.name]
      if not layout then
        print("!! No layout named '" .. joystick.mapping.name .. "'")
        layout = w.res.data.joystickViews[JoystickMappings.ControlMaps.Default]
      end
      print("layout=" .. inspect(layout))

      jview = JoystickView.newJoystickView(layout)
      w.views[joystick.name] = jview
    end
    JoystickView.drawJoystickView(jview, joystick)

    G.pop()
    i = i + 1
  end
end

return M
