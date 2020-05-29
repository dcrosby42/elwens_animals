local ResourceLoader = require 'resourceloader'
local Debug = require('mydebug').sub('joyconfig', false, true)
local G = love.graphics

local M = {}

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

function M.newWorld()
  local res = ResourceLoader.buildResourceRootFromFile(
                  "modules/joystickconfig/resources.lua")

  local gpl = res.data.gamepad_layout
  local tiles = fixImagePaths(indexTiles(gpl.tilesets), "^..",
                              "modules/joystickconfig")
  local layers = groupThenKeyBy(gpl.layers, 'type', 'name')
  local blayer = layers.objectgroup.buttons
  print(inspect(blayer))

  return {
    joysticks = {},
    joystickNames = {},
    buttonsLayer = blayer,
    tiles = tiles,
    res = res,
  }
end

function M.updateWorld(w, action)
  -- Debug.println(inspect(action))
  if action.type == 'joystick' then
    tsetdeep(w.joysticks, {
      action.joystickId,
      action.instanceId,
      action.controlType,
      action.control,
    }, tostring(action.value))
    tsetdeep(w.joystickNames, {action.joystickId, action.instanceId},
             tostring(action.name))
  end
  return w
end

local panelW = 200
local lineH = 12
local function drawPanelT(i, joyId, instId, name, controlTypes)
  local left = i * panelW
  local x = left
  local y = 50
  G.print(name, x, y)
  local y = y + lineH
  G.print(
      "JoystickId " .. tostring(joyId) .. " InstanceId " .. tostring(instId), x,
      y)
  y = y + lineH
  for ct, controls in pairs(controlTypes) do
    for control, value in pairs(controls) do
      G.print(tostring(ct) .. "_" .. tostring(control) .. ": " ..
                  tostring(value), x, y)
      y = y + lineH
    end
  end
end

local BSize = 0.5
local function drawButton(x, y, pic, drawBox)
  G.draw(pic.image, pic.quad, x, y, 0, BSize, BSize)
  if drawBox then
    G.rectangle("line", x, y, pic.rect.w * BSize, pic.rect.h * BSize)
  end
end

local function drawSprite(s, scale)
  scale = scale or 1
  local w = s.pic.rect.w * scale
  local h = s.pic.rect.h * scale
  local ox = (s.cx or 0) * w
  local oy = (s.cy or 0) * h
  G.draw(s.pic.image, s.pic.quad, s.x * scale, s.y * scale, 0, scale, scale, ox,
         oy)
end

local panelW = 400
local lineH = 12
local function drawPanel(i, joyId, instId, name, controls, res)
  local panelX = i * panelW
  local panelY = 50
  local panelw = 400
  local panelh = 200

  local x = panelx
  local y = 50
  G.print(name, x, y)
  local y = y + lineH
  G.print(
      "JoystickId " .. tostring(joyId) .. " InstanceId " .. tostring(instId), x,
      y)
  y = y + lineH

end

local function drawGamepadLayout(layer, tiles)
  for _, obj in ipairs(layer.objects) do
    local tile = tiles[obj.gid]
    local file = tile.image
    -- if obj.name == "faceLeft" then file = string.gsub(file, "Dark", "Light") end
    local img = ResourceLoader.getImage(file)
    local sx = obj.width / tile.width
    local sy = obj.height / tile.height
    G.draw(img, obj.x, obj.y, obj.rotation, sx, sy)
  end
end

function M.drawWorld(w, action)
  -- drawGamepad(0, 0, 400, 200, {}, w.res)
  drawGamepadLayout(w.buttonsLayer, w.tiles)
  local i = 1
  for joyId, t1 in pairs(w.joysticks) do
    for instId, controlTypes in pairs(t1) do
      local name = tgetdeep(w.joystickNames, {joyId, instId})
      drawPanelT(i, joyId, instId, name, controlTypes, w.res)
      i = i + 1
    end
  end
end

return M
