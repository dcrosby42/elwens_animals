local R = require "resourceloader"
local EcsLoaders = require "ecs.loaders"

local Loaders = shallowclone(EcsLoaders)

local function toCustomMap(data)
  local layers = groupThenKeyBy(data.layers, 'type', 'name')
  for key, tlayer in pairs(layers.tilelayer) do
    tlayer.grid = array2grid(tlayer.data, tlayer.width, tlayer.height)
  end
  return {tiled = data, layers = layers}
end

function Loaders.custommap(res, mConfig)
  local data = Loaders.getData(mConfig)
  local mapfile = toCustomMap(data)
  res:get('maps'):put(mConfig.name, mapfile)
end

-- 0 empty
-- 1 brick
-- 2 block
-- 3 qblock
-- 4 ground1l
-- 5 ground1
-- 6 ground1r

return Loaders
