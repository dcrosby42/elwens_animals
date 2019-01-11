--
-- ECS module adapter
--
-- A function that converts an "ECS Module" into a "crozeng Module"
-- 

require 'ecs.ecshelpers'
local Debug = require('mydebug').sub("EcsDev2",true,true)
local Editor = require('ecs.editorgui')
local G = love.graphics
local soundmanager = require('crozeng.soundmanager')

local function newWorld(ecsMod)
  local res = ecsMod.loadResources()
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
  if action.state == 'pressed' and action.key == 'r' and action.gui then
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

  elseif action.type == 'keyboard' and action.state == "pressed" then
    Editor.keypressed(action.key)
  elseif action.type == 'textinput' then
    Editor.textinput(action.text)

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
  Editor.draw(world.editor,{rect={0,0,w,h}})
end

local function drawWorld(ecsMod, world)
  local paused = world.editor.ui.pausedCheckbox.checked
  if paused and world.editor.historyIndex > 0 then
    ecsMod.draw(Editor.getEstore(world.editor), world.resources)
  else
    ecsMod.draw(world.estore, world.resources)
  end

  if world.editor.on then
    drawEditor(ecsMod,world)
  end

  if paused then
    soundmanager.pause()
  else
    soundmanager.unpause()
  end
end

--
-- ecsMod is an "ECS Module" which is a Table with three keys to functions:
--   loadResources() -> resources
--   create(resources) -> estore
--   update(estore, action, resources) -> estore,sidefx
--   draw(estore,resources) -> nil
--  
return function(ecsMod)
  return {
    newWorld=   function()             return newWorld(ecsMod)                 end,
    updateWorld=function(world,action) return updateWorld(ecsMod,world,action) end,
    drawWorld=  function(world)        return drawWorld(ecsMod,world)          end,
  }
end
