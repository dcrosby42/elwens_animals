local ResourceLoader = require 'resourceloader'
local G = love.graphics

local ButtonsById = {
  face1 = "faceUp",
  face2 = "faceRight",
  face3 = "faceDown",
  face4 = "faceLeft",
  select = "select",
  start = "start",
  r1 = "rightBumper",
  r2 = "rightTrigger",
  r3 = "rightStick",
  l1 = "leftBumper",
  l2 = "leftTrigger",
  l3 = "leftStick",
}
local ButtonsByName = invertMap(ButtonsById)

local AxesByName = {
  leftStick = {x = "leftx", y = "lefty"},
  rightStick = {x = "rightx", y = "righty"},
}
local DpadByName = {
  dpadUp = {axis = "lefty", dir = -1},
  dpadDown = {axis = "lefty", dir = 1},
  dpadLeft = {axis = "leftx", dir = -1},
  dpadRight = {axis = "leftx", dir = 1},
}

-- local ButtonsById = keyBy(ButtonIdsAndNames, function(pair)
--   return pair[1]
-- end)

-- local ButtonsByName = keyBy(ButtonIdsAndNames, function(pair)
--   return pair[2]
-- end)
-- print(inspect(ButtonsByName))

local function indexTiles(tilesets)
  local full = {}
  for _, tileset in ipairs(tilesets) do
    for i = 1, #tileset.tiles do
      -- local idx = tileset.tiles[i].id + tileset.firstgid
      local idx = tileset.tiles[i].id + 1
      full[idx] = tileset.tiles[i]
    end
  end
  return full
end

local function fixImagePaths(tiles, pat, repl)
  -- for i = 1, #tiles do tiles[i].image = string.gsub(tiles[i].image, pat, repl) end
  for _, tile in pairs(tiles) do
    tile.image = string.gsub(tile.image, pat, repl)
  end
  return tiles
end

local J = {}

function J.newJoystickView(tiledmap)
  local tiles = fixImagePaths(indexTiles(tiledmap.tilesets), "^..",
                              "modules/joystickconfig")
  local layers = groupThenKeyBy(tiledmap.layers, 'type', 'name')
  return {tiles = tiles, buttonsLayer = layers.objectgroup.buttons}
end

function J.drawJoystickView(view, joystick)
  -- Name and id
  G.print(joystick.name .. " (" .. joystick.mapping.name .. ")", 0, 0)
  G.print("Joystick Id: " .. joystick.joystickId, 0, 12)
  G.print("Instance Id: " .. joystick.instanceId, 0, 24)

  -- -- Print the axis values
  -- local w = 35
  -- local h = 12
  -- local x = 0
  -- local y = 0
  -- G.push()
  -- G.translate(0, 40)
  -- for i = 1, #joystick.axes do
  --   y = 0
  --   x = (i - 1) * w
  --   G.rectangle("fill", x, y, w, h)
  --   G.rectangle("line", x, y, w, 2 * h)
  --   G.setColor(0, 0, 0)
  --   G.print("" .. i, x, y)
  --   y = y + h
  --   G.setColor(1, 1, 1)
  --   if joystick.axes[i] == nil then print("NIL axes # " .. i) end
  --   G.print("" .. math.round(joystick.axes[i], 2), x, y)
  -- end
  -- G.pop()

  -- G.push()
  -- G.translate(#joystick.axes * w + 10, 40)
  -- w = 20
  -- for i = 1, #joystick.buttons do
  --   y = 0
  --   x = (i - 1) * w
  --   G.rectangle("fill", x, y, w, h)
  --   G.rectangle("line", x, y, w, 2 * h)
  --   G.setColor(0, 0, 0)
  --   G.print("" .. i, x, y)
  --   y = y + h
  --   -- G.rectangle("line", x, y, w, h)
  --   G.setColor(1, 1, 1)
  --   G.print("" .. math.round(joystick.buttons[i], 2), x, y)
  -- end
  -- G.pop()

  -- Draw the buttons
  for _, obj in ipairs(view.buttonsLayer.objects) do
    local tile = view.tiles[obj.gid]
    local file = tile.image
    local offx = 0 -- for moving the stick controls 
    local offy = 0
    if joystick then
      if obj.type == "button" or obj.type == "stick" then
        local buttonId = ButtonsByName[obj.name]
        local value = joystick:buttonValue(buttonId)
        if value ~= 0 then
          -- HIGHLIGHT BUTTONS WHITE WHEN ACTIVE:
          file = string.gsub(file, "Dark", "Light")
        end
      end
      if obj.type == "dpad" then
        if ((obj.name == "dpadLeft" and joystick:axisValue("leftx") < 0) or
            (obj.name == "dpadRight" and joystick:axisValue("leftx") > 0) or
            (obj.name == "dpadUp" and joystick:axisValue("lefty") < 0) or
            (obj.name == "dpadDown" and joystick:axisValue("lefty") > 0)) then
          -- HIGHLIGHT DPAD BUTTONS WHITE WHEN ACTIVE:
          file = string.gsub(file, "Dark", "Light")
        end
      end
      local stickMove = 50
      if obj.type == "stick" then
        local a = AxesByName[obj.name]
        if a then
          local xval = joystick:axisValue(a.x)
          offx = xval * stickMove
          local yval = joystick:axisValue(a.y)
          offy = yval * stickMove
        end
      end
    end
    local img = ResourceLoader.getImage(file)
    local sx = obj.width / tile.width
    local sy = obj.height / tile.height
    G.draw(img, obj.x, obj.y, obj.rotation, sx, sy, -offx, -offy)
  end
end

return J
