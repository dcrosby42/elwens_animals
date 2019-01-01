require 'ecs.ecshelpers'
local Debug = require('mydebug').sub("EcsDev",true,true)
local Entities = require 'modules.ecsdev.entities'
local Resources = require 'modules.ecsdev.resources'
local SoundManager = require 'soundmanager'

local UPDATE = composeSystems({
  'systems.timer',
  'systems.selfdestruct',
  'systems.touchbutton',
  -- 'systems.physics',
  'systems.sound',
})

local DRAW = composeDrawSystems({
  'systems.drawstuff',
  'systems.physicsdraw',
})

love.physics.setMeter(64) --the height of a meter our worlds will be 64px

local M = {}

function M.newWorld(args)
  local m = args.module
  local res = Resources.load()
  local world={
    sub={
      module=m,
      world=m.newWorld(),
    },

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
  w.sub.module.stopWorld(w.sub.world)
end

local function resetInput(i) i.dt=0 i.events={} end

function M.updateWorld(w,action)
  local sidefx = nil
  if action.type == 'tick' then
    w.input.dt = action.dt
    UPDATE(w.estore, w.input, w.resources)
    sidefx = w.input.events -- return events as potential sidefx
    resetInput(w.input)

    -- shove input events into the subworld:
    for i=1,#sidefx do
      w.sub.module.updateWorld(w.sub.world, sidefx[i])
    end
    -- tick
    action.dt = action.dt * slider.value
    w.sub.world, sidefx = w.sub.module.updateWorld(w.sub.world, action)

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
  w.sub.module.drawWorld(w.sub.world)

  w.soundmgr:update(w.estore, nil, w.resources)
  DRAW(w.estore, w.resources)
end

return M
