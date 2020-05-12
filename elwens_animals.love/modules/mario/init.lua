require "ecs.ecshelpers"
local R = require "resourceloader"
local Loaders = require 'ecs/loaders'

local EcsAdapter = require "ecs.moduleadapter"
local Entities = require "modules.mario.entities"
local DrawSound2 = require "systems.drawsound2"
local inspect = require "inspect"

-- Wrap the Viewport drawing system around all the others:
local DRAW = require("systems.viewportdraw").wrap(
                 composeDrawSystems({
      "modules.mario.drawsystem",
      "systems.physicsdraw",
      "systems.debugdraw",
      DrawSound2.new("mario"),
    }))

local configs = loadfile('modules/mario/resources.lua')()
local res = R.buildResourceRoot(configs, Loaders)

return EcsAdapter({
  create = Entities.initialEntities,
  update = res.ecs.main.update,
  draw = DRAW,
  loadResources = function()
    return res
  end,
})
