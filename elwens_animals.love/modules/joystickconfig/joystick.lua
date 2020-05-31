local Joystick = {}
local Debug = require('mydebug').sub('Joystick')

local function initZeros(n)
  local obj = {}
  for i = 1, n do obj[i] = 0 end
  return obj
end

local function getMapping()
  return {
    -- axes = {
    --   [1] = "leftx",
    --   [2] = "lefty",
    --   [3] = "unknown",
    --   [4] = "rightx",
    --   [5] = "righty",
    -- },o
    axes = {leftx = 1, lefty = 2, unknown = 3, rightx = 4, righty = 5},
    buttons = {
      face1 = 1,
      face2 = 2,
      face3 = 3,
      face4 = 4,
      l2 = 5,
      r2 = 6,
      l1 = 7,
      r1 = 8,
      select = 9,
      start = 10,
      l3 = 11,
      r3 = 12,
    },
  }
end

function Joystick:new(opts)
  local numAxes = 5
  local numButtons = 12
  local o = {
    joystickId = opts.joystickId,
    instanceId = opts.instanceId,
    name = opts.name,
    axes = initZeros(numAxes),
    buttons = initZeros(numButtons),
    mapping = getMapping(),
  }
  setmetatable(o, self)
  self.__index = self
  return o
end

function Joystick:update(jAction)
  if jAction.controlType == "axis" then
    self.axes[jAction.control] = jAction.value
    Debug.println("Axes: " .. inspect(self.axes))
  elseif jAction.controlType == "button" then
    self.buttons[jAction.control] = jAction.value
    Debug.println("Buttons: " .. inspect(self.buttons))
  end
end

function Joystick:buttonValue(buttonId)
  if self.mapping.buttons[buttonId] then
    return self.buttons[self.mapping.buttons[buttonId]] or 0
  end
  return 0
end

function Joystick:axisValue(axisId)
  if self.mapping.axes[axisId] then
    return self.axes[self.mapping.axes[axisId]] or 0
  end
  return 0
end

return Joystick
