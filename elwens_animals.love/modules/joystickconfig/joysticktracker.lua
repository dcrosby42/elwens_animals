local Debug = require('mydebug').sub('JoystickTracker')
local Joystick = require('modules.joystickconfig.joystick')
local Tracker = {}

local function joystickKey(jAction)
  return "" .. tostring(jAction.joystickId) .. "_" ..
             tostring(jAction.instanceId)
end

function Tracker:new()
  local o = {all = {}, byId = {}}
  setmetatable(o, self)
  self.__index = self
  return o
end

-- joystick action{joystickId, instanceId, controlType[axis|button], control[int], value[number]}
function Tracker:update(jAction, res)
  local name = jAction.name
  local key = joystickKey(jAction)
  local joystick = self.all[key]
  if not joystick then
    local conf = self:getJoystickConfigFrom(res, name)
    joystick = Joystick:new({
      name = name,
      joystickId = jAction.joystickId,
      instanceId = jAction.instanceId,
      mapping = conf.controlMap,
    })
    self.all[key] = joystick
  end
  self.byId[jAction.joystickId] = joystick -- track as the official instance for this id
  joystick:update(jAction)
end

function Tracker:getJoystick(joystickId)
  return self.byId[joystickId]
end

function Tracker:getJoystickConfigFrom(res, name)
  assert(res and res.data.joysticks and res.data and res.data.joysticks,
         "Expected res.data.joysticks to exist!")
  local joystickConfig = res.data.joysticks[name]
  if not joystickConfig then joystickConfig = res.data.joysticks["DEFAULT"] end
  assert(joystickConfig,
         "No joystick config named " .. tostring(name) .. " in joysticks=" ..
             inspect(res.data.joysticks))
  return joystickConfig
end

return Tracker
