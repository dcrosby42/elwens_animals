require 'ecs.ecshelpers'
local EcsAdapter = require 'ecs.moduleadapter'
local Entities = require 'modules.farmgame.entities'
local Resources = require 'modules.farmgame.resources'
-- local DrawSound = require 'systems.drawsound'

local UPDATE = composeSystems({
  'systems.timer',
  'systems.physics',
  'systems.sound',
  'systems.touchbutton',
  'modules.farmgame.devsystem',
  'modules.farmgame.manipsystem',
  'modules.farmgame.boundarysystem',
})

local DRAW = composeSystems({
  'systems.drawsound2',
  'systems.drawstuff',
  'systems.physicsdraw',
})

return EcsAdapter({
  loadResources=Resources.load,
  create=Entities.initialEntities,
  update=UPDATE,
  draw=DRAW,
})
