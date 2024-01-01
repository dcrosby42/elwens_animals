require 'ecs.ecshelpers'
-- local Debug = require 'mydebug'
local Entities = require 'modules.christmas.entities'
local Resources = require 'modules.christmas.resources'
local SoundManager = require 'soundmanager'

local Snow = require 'modules.snowman.snow'

local DrawStuff = require 'systems.drawstuff'

-- DrawStuff.addPlugin(Snow.drawingPlugin)

local UPDATE = composeSystems({
  'systems.timer',
  'systems.physics',
  'systems.sound',
  'systems.touchbutton',
  'modules.christmas.xmassystem',
  'modules.animalscreen.boundarysystem',
})

local DRAW = composeDrawSystems({
  'systems.drawstuff',
  'systems.physicsdraw',
})

love.physics.setMeter(64) --the height of a meter our worlds will be 64px

local M = {}

function M.newWorld()
  local res = Resources.load()
  local world={
    estore = Entities.initialEntities(res),
    input = {
      dt=0,
      events={},
    },
    resources = res,
    soundmgr=SoundManager:new(),
  }
  return world
end

function M.stopWorld(w)
  w.soundmgr:clear()
end

local function resetInput(i) i.dt=0 i.events={} end

function M.updateWorld(w,action)
  local sidefx = nil
  if action.type == 'tick' then
    w.input.dt = action.dt
    UPDATE(w.estore, w.input, w.resources)
    sidefx = w.input.events -- return events as potential sidefx
    resetInput(w.input)

  elseif action.type == 'mouse' then
    local evt = shallowclone(action)
    evt.type = "touch"
    evt.id = 1
    table.insert(w.input.events, evt)

  elseif action.type == 'touch' or action.type == 'keyboard' then
    table.insert(w.input.events, shallowclone(action))

  end
  return w, sidefx
end

function M.drawWorld(w)
  w.soundmgr:update(w.estore, nil, w.resources)
  DRAW(w.estore, w.resources)
end

return M
