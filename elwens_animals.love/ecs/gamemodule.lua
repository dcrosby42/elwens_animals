local ResourceLoader = require "resourceloader"
local EcsAdapter = require "ecs.moduleadapter"

local function newFromConfigs(configs)
  local loaders = require 'ecs/loaders'
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

local function newFromFile(path)
  local configs = loadfile(path)()
  return newFromConfigs(configs)
end

return {
  new = newFromConfigs,
  newFromConfigs = newFromConfigs,
  newFromFile = newFromFile,
}
