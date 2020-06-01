local Debug = require('mydebug').sub('JoystickTracker')
local Joystick = require('modules.joystickconfig.joystick')
local JoystickMappings = require('crozeng.joystick')
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
    Debug.println(function()
      return "Gonna make a new Joystick based on jAction=" .. inspect(jAction)
    end)
    joystick = Joystick:new({
      name = name,
      joystickId = jAction.joystickId,
      instanceId = jAction.instanceId,
      mapping = JoystickMappings.ControlMaps[jAction.controlMapName],
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
