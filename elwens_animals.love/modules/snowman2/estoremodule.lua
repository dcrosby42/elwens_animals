require 'ecs.ecshelpers' -- composeSystems, composeDrawSystems 

-- local Debug = require('mydebug').sub("Snowman2",true,true)
local Entities = require 'modules.snowman2.entities'
local Snow = require 'modules.snowman2.snow'
local DrawStuff = require 'systems.drawstuff'
local SoundManager = require 'soundmanager'

DrawStuff.addPlugin(Snow.drawingPlugin, "drawSnow")

local UPDATE = composeSystems({
  'systems.timer',
  'systems.selfdestruct',
  'systems.physics',
  'systems.sound',
  'systems.touchbutton',
  'modules.snowman2.cannonsystem',
  'modules.snowman2.upright',
})

local DRAW = composeDrawSystems({
  DrawStuff.drawSystem,
  -- 'systems.physicsdraw',
})

soundmgr=SoundManager:new() -- TODO FIXME THIS IS NO GOOD

-- FIXME HOW ? soundmgr:clear()

return {
  create=Entities.initialEntities,
  update=UPDATE,
  draw=DRAW,
}
