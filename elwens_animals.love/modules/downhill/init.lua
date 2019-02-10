require 'ecs.ecshelpers' -- composeSystems, composeDrawSystems 
local EcsAdapter =  require 'ecs.moduleadapter'

local Debug = require('mydebug').sub("Downhill",true,true)
local Resources = require 'modules.downhill.resources'
local Entities = require 'modules.downhill.entities'
local DrawStuff = require 'systems.drawstuff'
local DrawSound = require 'systems.drawsound'

local UPDATE = composeSystems({
  'systems.timer',
  'modules.downhill.mapsystem',
  'systems.selfdestruct',
  'systems.physics',
  'systems.sound',
  'systems.touchbutton',
  'modules.downhill.ballcontrollersystem', -- XXX ?
  'modules.downhill.manipsystem',
  'modules.downhill.trackersystem',
  -- 'modules.animalscreen.boundarysystem',
  'systems.viewport',
})

local DRAW = composeDrawSystems({
  'modules.downhill.drawsystem',
  -- DrawStuff.drawSystem,
  DrawSound.new("downhill"),
})

return EcsAdapter({
  loadResources=Resources.load,
  create=Entities.initialEntities,
  update=UPDATE,
  draw=DRAW,
})
