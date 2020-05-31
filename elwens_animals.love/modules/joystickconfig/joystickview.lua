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
  G.print(joystick.name)
  for _, obj in ipairs(view.buttonsLayer.objects) do
    local tile = view.tiles[obj.gid]
    local file = tile.image
    -- if obj.name == "faceLeft" then file = string.gsub(file, "Dark", "Light") end
    local offx = 0
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
