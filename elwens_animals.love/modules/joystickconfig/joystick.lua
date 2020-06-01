local Joystick = {}
local Debug = require('mydebug').sub('Joystick')

local function initZeros(n)
  local obj = {}
  for i = 1, n do obj[i] = 0 end
  return obj
end

--
-- opts: { 
--   joystickId,
--   instanceId,
--   name,        -- joystick identifier name, eg "Generic   USB  Joystick "
--   mapping      -- ControlMap from crozeng.joystick 
-- }
function Joystick:new(opts)
  assert(opts.mapping, "opts.mapping required")
  Debug.println(function()
    return "Joystick:new opts=" .. inspect(opts)
  end)
  local o = {
    joystickId = opts.joystickId,
    instanceId = opts.instanceId,
    name = opts.name,
    axes = {},
    buttons = {},
    mapping = opts.mapping,
  }
  setmetatable(o, self)
  self.__index = self
  return o
end

-- Update internal button or axis state.
function Joystick:update(jAction)
  if jAction.controlType == "axis" then
    if self.axes[jAction.controlName] ~= jAction.value then
      self.axes[jAction.controlName] = jAction.value
      Debug.println(function()
        return "Axes: " .. inspect(self.axes) .. ", CHANGED: " ..
                   jAction.controlName .. " => " .. tostring(jAction.value)
      end)
      return true
    end
  elseif jAction.controlType == "button" then
    if self.buttons[jAction.controlName] ~= jAction.value then
      self.buttons[jAction.controlName] = jAction.value
      Debug.println(function()
        return "Buttons: " .. inspect(self.buttons) .. ", CHANGED: " ..
                   jAction.controlName .. " => " .. tostring(jAction.value)
      end)
      return true
    end
  end
  -- no actual change
  return false
end

-- Get last known button state.
-- Returns 0 or 1.
-- buttonId can be a string name like "face1" or a control number like 4.
function Joystick:buttonValue(buttonId)
  if type(buttonId) == 'number' and self.mapping.buttonNames[buttonId] then
    return self.buttons[self.mapping.buttonNames[buttonId]] or 0
  else
    return self.buttons[buttonId] or 0
  end
  return 0
end

-- Get last known axis state.
-- Returns number between -1 and 1.
-- buttonId can be a string name like "leftx" or a control number like 1.
function Joystick:axisValue(axisId)
  if type(axisId) == 'number' and self.mapping.axisNames[axisId] then
    return self.axes[self.mapping.axisNames[axisId]] or 0
  else
    return self.axes[axisId] or 0
  end
  return 0
end

return Joystick
