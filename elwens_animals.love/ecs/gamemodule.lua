local ResourceLoader = require "resourceloader"
local EcsAdapter = require "ecs.moduleadapter"

local function newFromConfigs(configs, loaders)
  loaders = loaders or require('ecs/loaders')
  local res = ResourceLoader.buildResourceRoot(configs, loaders)
  return EcsAdapter({
    create = res.ecs.main.entities.initialEntities,
    update = res.ecs.main.update,
    draw = res.ecs.main.draw,
    loadResources = function()
      return res
    end,
  })
end

local function newFromFile(path, loaders)
  local configs = loadfile(path)()
  return newFromConfigs(configs, loaders)
end

return {
  new = newFromConfigs,
  newFromConfigs = newFromConfigs,
  newFromFile = newFromFile,
}
