-- local Estore = require 'ecs.estore'
require 'ecs.ecshelpers'
local Entities = require 'modules.stackinggame.entities'
local Resources = require 'modules.stackinggame.resources'
local SoundManager = require 'soundmanager'
local Debug = require 'mydebug'

local UPDATE = composeSystems(requireModules({
  'systems.timer',
  'systems.physics',
  'systems.sound',
  'systems.touchbutton',
  'modules.stackinggame.manipsystem',
  'modules.stackinggame.boundarysystem',
}))

local DRAW = composeDrawSystems(requireModules({
  'systems.drawstuff',
  'systems.physicsdraw',
}))

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
    soundmgr = SoundManager:new(),
    mute = true,
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

  elseif action.type == 'touch' then
    table.insert(w.input.events, shallowclone(action))

  elseif action.type == 'keyboard' and action.state == "pressed" then
    local x = love.math.random(0,1024) 
    local y = love.math.random(0,500) 
    local kind= pickRandom(w.resources.animalNames)
    local e = Entities.animal(w.estore,w.resources,kind)
    e.pos.x = x
    e.pos.y = y
    Entities.addSound(e, kind, w.resources)

  elseif action.type == 'mouse' then
    local evt = shallowclone(action)
    evt.type = "touch"
    evt.id = 1
    table.insert(w.input.events, evt)

  end
  return w, sidefx
end

function M.drawWorld(w)
  if not w.mute then
    w.soundmgr:update(w.estore, nil, w.resources)
  end
  DRAW(w.estore, w.resources)
end

return M
