require 'ecs.ecshelpers' -- composeSystems, composeDrawSystems 
local EcsAdapter =  require 'ecs.moduleadapter'

local Debug = require('mydebug').sub("Downhill",true,true)
local Resources = require 'modules.downhill.resources'
local Entities = require 'modules.downhill.entities'
local DrawStuff = require 'systems.drawstuff'
local DrawSound = require 'systems.drawsound'

-- DrawStuff.addPlugin(Snow.drawingPlugin, "drawSnow")

local UPDATE = composeSystems({
  'systems.timer',
  'systems.selfdestruct',
  'systems.physics',
  'systems.sound',
  'systems.touchbutton',
})

local DRAW = composeDrawSystems({
  DrawStuff.drawSystem,
  DrawSound.new("downhill"),
  'systems.physicsdraw',
})

return EcsAdapter({
  loadResources=Resources.load,
  create=Entities.initialEntities,
  update=UPDATE,
  draw=DRAW,
})
