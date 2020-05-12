local ResourceLoader = require "resourceloader"
local EcsAdapter = require "ecs.moduleadapter"

return {
  new = function(configs)
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
  end,
}
