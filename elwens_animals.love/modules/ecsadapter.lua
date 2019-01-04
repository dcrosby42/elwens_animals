-- local Estore = require 'ecs.estore'
require 'ecs.ecshelpers'
local EstoreModule = require 'modules.snowman2.estoremodule'
local Resources = require 'modules.snowman2.resources'
local Debug = require('mydebug').sub("EcsDev2",true,true)

local function newWorld(ecsMod)
  local res = Resources.load()
  local world={
    estore = ecsMod.create(res),
    input = {
      dt=0,
      events={},
    },
    resources = res,
  }
  return world
end

local function updateWorld(ecsMod, world, action)
  -- Reload game?
  if action.state == 'pressed' and action.key == 'r' then
    return world, {{type="crozeng.reloadRootModule"}}
  end

  local sidefx = nil
  if action.type == 'tick' then
    -- Update the ECS world
    world.input.dt = action.dt
    EstoreModule.update(world.estore, world.input, world.resources)
    sidefx = world.input.events -- return events as potential sidefx

    -- reset input
    world.input.dt=0
    world.input.events={}

  elseif action.type == 'mouse' then
    -- convert mouse events to touch events
    local evt = shallowclone(action)
    evt.type = "touch"
    evt.id = 1
    table.insert(world.input.events, evt)

  elseif action.type == 'touch' or action.type == 'keyboard' then
    -- pass touch and keyboard events through
    table.insert(world.input.events, shallowclone(action))

  end
  return world, sidefx
end

local function drawWorld(ecsMod, world)
  ecsMod.draw(world.estore, world.resources)
end

return function(ecsMod)
  return {
    newWorld=   function()             return newWorld(ecsMod)                 end,
    updateWorld=function(world,action) return updateWorld(ecsMod,world,action) end,
    drawWorld=  function(world)        return drawWorld(ecsMod,world)          end,
  }
end
