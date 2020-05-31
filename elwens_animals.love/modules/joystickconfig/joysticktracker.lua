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
function Tracker:update(jAction)
  local key = joystickKey(jAction)
  local joystick = self.all[key]
  if not joystick then
    joystick = Joystick:new({
      name = jAction.name,
      joystickId = jAction.joystickId,
      instanceId = jAction.instanceId,
    })
    self.all[key] = joystick
  end
  self.byId[jAction.joystickId] = joystick -- track as the official instance for this id
  joystick:update(jAction)
end

function Tracker:getJoystick(joystickId)
  return self.byId[joystickId]
end

return Tracker
