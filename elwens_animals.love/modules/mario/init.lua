require 'ecs.ecshelpers' 
local EcsAdapter =  require 'ecs.moduleadapter'

local Debug = require('mydebug').sub("Mario",true,true)
local Resources = require 'modules.mario.resources'
local Entities = require 'modules.mario.entities'
local DrawStuff = require 'systems.drawstuff'
local DrawSound = require 'systems.drawsound'

local UPDATE = composeSystems({
  'systems.timer',
  'systems.selfdestruct',
  'systems.physics',
  'systems.sound',
  'systems.touchbutton',
  'modules.mario.mariosystem',
  'modules.mario.playertrackersystem',
  'systems.viewport',
})

local DRAW = composeDrawSystems({
  'modules.mario.drawsystem',
  -- DrawStuff.drawSystem,
  DrawSound.new("mario"),
})

return EcsAdapter({
  loadResources=Resources.load,
  create=Entities.initialEntities,
  update=UPDATE,
  draw=DRAW,
})
