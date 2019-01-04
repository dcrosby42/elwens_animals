-- local Estore = require 'ecs.estore'
require 'ecs.ecshelpers'
local Resources = require 'modules.snowman2.resources'
local Debug = require('mydebug').sub("EcsDev2",true,true)
local Editor = require('modules.ecsadapter.editor')
local G = love.graphics

local function newWorld(ecsMod)
  local res = Resources.load()
  local world={
    estore = ecsMod.create(res),
    input = {
      dt=0,
      events={},
    },
    resources = res,

    editor=Editor.init(),
  }
  return world
end

local function doTick(ecsMod,world,action)
  -- Update the ECS world
  world.input.dt = action.dt
  ecsMod.update(world.estore, world.input, world.resources)
  local sidefx = world.input.events -- return events as potential sidefx
  -- reset input
  world.input.dt=0
  world.input.events={}

  if world.editor.recording then
    local copy = world.estore:clone({keepCaches=true})
    world.editor.history:push(copy)
    world.editor.historyIndex = world.editor.history:length()
  end

  return world, sidefx
end

local function updateWorld(ecsMod, world, action)
  local sidefx
  local editing = world.editor.on
  local paused = world.editor.ui.pausedCheckbox.checked

  -- Reload game?
  if action.state == 'pressed' and action.key == 'r' then
    sidefx = {{type="crozeng.reloadRootModule"}}

  -- toggle editor?
  elseif action.state == 'pressed' and action.key == 'escape' then
    world.editor.on = not world.editor.on

  -- time passed?
  elseif action.type == "tick" then
    if not paused then
      world,sidefx = doTick(ecsMod,world,action)
    end
    if editing then
      world.editor.estore = world.estore
      Editor.update(world.editor)
    end

  -- convert mouse events to touch events:
  elseif action.type == 'mouse' then
    if not editing then
      local evt = shallowclone(action)
      evt.type = "touch"
      evt.id = 1
      table.insert(world.input.events, evt)
    end

  -- pass touch and keyboard events through:
  elseif action.type == 'touch' or action.type == 'keyboard' then
    if not editing then
      table.insert(world.input.events, shallowclone(action))
    end
  end
  
  return world, sidefx
end

local function drawEditor(ecsMod,world)
  local w = G.getWidth()
  local h = G.getHeight()
  G.setColor(0,0,0, world.editor.ui.bgOpacity.value)
  G.rectangle("fill", 0,0,w,h)
  G.setColor(1,1,1)
  Editor.draw(world.editor)
end

local function drawWorld(ecsMod, world)
  if world.editor.ui.pausedCheckbox.checked and world.editor.historyIndex > 0 then
    ecsMod.draw(Editor.getEstore(world.editor), world.resources)
  else
    ecsMod.draw(world.estore, world.resources)
  end

  if world.editor.on then
    drawEditor(ecsMod,world)
  end
end

return function(ecsMod)
  return {
  newWorld=   function()             return newWorld(ecsMod)                 end,
  updateWorld=function(world,action) return updateWorld(ecsMod,world,action) end,
  drawWorld=  function(world)        return drawWorld(ecsMod,world)          end,
}
end
