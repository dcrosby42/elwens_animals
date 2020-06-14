require 'crozeng.helpers'

local Const = require "modules.mario.const"
local BlockW = Const.BlockW
local BlockW2 = Const.BlockW2
local BlockW4 = Const.BlockW4

local function convertMap(data)
  local layers = groupThenKeyBy(data.layers, 'type', 'name')
  for key, tlayer in pairs(layers.tilelayer) do
    tlayer.grid = array2grid(tlayer.data, tlayer.width, tlayer.height)
  end
  local map = {tiled = data, layers = layers}
  map.width = data.width * BlockW
  map.widthInTiles = data.width
  map.heightInTiles = data.height
  return map
end

-- 0 empty
-- 1 brick
-- 2 block
-- 3 qblock
-- 4 ground1l
-- 5 ground1
-- 6 ground1r

return {convertMap = convertMap}
