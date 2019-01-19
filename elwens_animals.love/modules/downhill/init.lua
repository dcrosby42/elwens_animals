require 'ecs.ecshelpers' -- composeSystems, composeDrawSystems 
local EcsAdapter =  require 'ecs.moduleadapter'

local Debug = require('mydebug').sub("Downhill",true,true)
local Resources = require 'modules.downhill.resources'
local Entities = require 'modules.downhill.entities'
local DrawStuff = require 'systems.drawstuff'
local DrawSound = require 'systems.drawsound'
local Viewport = require 'systems.drawviewport'

local UPDATE = composeSystems({
  'systems.timer',
  'modules.downhill.mapsystem',
  'systems.selfdestruct',
  'systems.physics',
  'systems.sound',
  'systems.touchbutton',
  'modules.downhill.ballcontrollersystem', -- XXX ?
  Viewport.update,
})

local DRAW = composeDrawSystems({
  -- Viewport.drawIn, -- FIXME this isn't likely to extend well, this drawIn/drawOut trickery for bookending transforms
  
  'modules.downhill.drawsystem',
  -- DrawStuff.drawSystem,
  -- 'systems.physicsdraw',

  -- Viewport.drawOut, -- FIXME 

  DrawSound.new("downhill"),
})

return EcsAdapter({
  loadResources=Resources.load,
  create=Entities.initialEntities,
  update=UPDATE,
  draw=DRAW,
})
