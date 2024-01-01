require 'ecs.ecshelpers' -- composeSystems, composeDrawSystems 
local EcsAdapter =  require 'ecs.moduleadapter'

local Debug = require('mydebug').sub("Snowman",true,true)
local Resources = require 'modules.snowman.resources'
local Entities = require 'modules.snowman.entities'
local Snow = require 'modules.snowman.snow'
local DrawStuff = require 'systems.drawstuff'
-- local DrawSound = require 'systems.drawsound'

DrawStuff.addPlugin(Snow.drawingPlugin)

local UPDATE = composeSystems({
  'systems.timer',
  'systems.selfdestruct',
  'systems.physics',
  'systems.sound',
  'systems.touchbutton',
  'modules.snowman.cannonsystem',
  'modules.snowman.upright',
})

-- local DRAW = composeDrawSystems({
--   DrawStuff.drawSystem,
--   DrawSound.new("snowman"),
--   'systems.physicsdraw',
-- })
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
