require 'ecs.ecshelpers'
local EcsAdapter = require 'ecs.moduleadapter'
local Entities = require 'modules.sungirl.entities'
local Resources = require 'modules.sungirl.resources'
-- local DrawSound = require 'systems.drawsound'

local UPDATE = composeSystems({
  'systems.timer',
  -- 'systems.physics',
  -- 'systems.sound',
  -- 'systems.touchbutton',
  'modules.sungirl.devsystem',
  'modules.sungirl.touch_system',
  'modules.sungirl.player_control_system',
  -- 'modules.sungirl.touch_player_control_system',
  'modules.sungirl.touch_nav_player_control_system',
  'modules.sungirl.catgirl_system',
  'modules.sungirl.puppygirl_system',
  'systems.follow',
  'systems.viewport',
  -- 'modules.farmgame.manipsystem',
  -- 'modules.farmgame.boundarysystem',
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
