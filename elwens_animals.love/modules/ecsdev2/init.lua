require 'ecs.ecshelpers'
local Snowman = require('modules.snowman')
local Debug = require('mydebug').sub("EcsDev2",true,true)
local suit = require 'SUIT'

local M = {}

function M.newWorld(args)
  local m = args.module
  if not m then m = Snowman end
  local world={
    sub={
      module=m,
      world=m.newWorld(),
      pastWorlds={},
      maxPastWorlds=5*60,
    },
    ui={
      on=true,
      topPanel={0,0,1024,100},
      timeSpeedSlider={value=1, min=0,max=2},
      bgOpacity={value=0.7,min=0,max=1},
      pausedCheckbox={text="Paused", checked=false},
      timeNavSlider={value=1, min=1,max=1,step=1},
    },
  }
  love.audio.setVolume(0)
  return world
end

function M.stopWorld(w)
  w.sub.module.stopWorld(w.sub.world)
end


local function roundSliderValue(sl)
  sl.value = math.round0(sl.value)
end

local function adjSliderValue(sl,x)
  sl.value = sl.value + x
  if sl.value < sl.min then
    sl.value = sl.min
  elseif sl.value > sl.max then
    sl.value = sl.max
  else
    roundSliderValue(sl)
  end
end

local function updateGui(w)
  w.ui.timeNavSlider.max = #w.sub.pastWorlds
  local x = 0
  local y = 0
  local h = 15
  suit.layout:reset(x,y,5,2)

  suit.Label("Opacity",{align='left'}, suit.layout:row(100,h))
  suit.Slider(w.ui.bgOpacity, suit.layout:col(100,h))
  suit.Label(tostring(w.ui.bgOpacity.value), suit.layout:col(50,h))
  if suit.Button("Reset", {id='reset2'}, suit.layout:col(50,h)).hit then
    w.ui.bgOpacity.value = 0.7
  end

  suit.layout:returnLeft()
  suit.Label("Time Dilation",{align='left'}, suit.layout:row(100,h))
  suit.Slider(w.ui.timeSpeedSlider, suit.layout:col(100,h))
  suit.Label(tostring(w.ui.timeSpeedSlider.value), suit.layout:col(50,h))
  if suit.Button("Reset", suit.layout:col(50,h)).hit then
    w.ui.timeSpeedSlider.value = 1
  end

  suit.layout:returnLeft()
  suit.Checkbox(w.ui.pausedCheckbox, suit.layout:row(100,25))
  if w.ui.pausedCheckbox.checked then
    suit.Label("Time",{align='left'}, suit.layout:col(100,h))
    suit.Slider(w.ui.timeNavSlider, suit.layout:col(100,h))
    roundSliderValue(w.ui.timeNavSlider)
    suit.Label(tostring(w.ui.timeNavSlider.value), suit.layout:col(50,h))
    if suit.Button("<", suit.layout:col(20,h)).hit then
      adjSliderValue(w.ui.timeNavSlider, -1)
    end
    if suit.Button(">", suit.layout:col(20,h)).hit then
      adjSliderValue(w.ui.timeNavSlider, 1)
    end
  end
end

-- local function recordSubHistory(w,action)
--   local clonedInput = tcopydeep(w.sub.world.input)
--   clonedInput.dt = action.dt
--   local clonedEstore = w.sub.world.estore:clone({keepCaches=true})
--   local hframe = {
--     input=clonedInput,
--     estore=clonedEstore,,
--     res: w.sub.world.res,
--     soundmgr: w.sub.world.soundmgr,
--   }
--   table.insert(w.sub.history, hframe)
-- end

local function appendRolling(list,item,max)
  table.insert(list,item)
  while #list > max do
    table.remove(list,1)
  end
end

local function passThruUpdate(w,action)
  local sidefx
  w.sub.world, sidefx = w.sub.module.updateWorld(w.sub.world, action)
  if action.type == "tick" then
    -- recordSubHistory(w,action)
    local clonedInput = tcopydeep(w.sub.world.input)
    clonedInput.dt = action.dt
    local clonedEstore = w.sub.world.estore:clone({keepCaches=true})
    local clonedWorld = {
      input=clonedInput,
      estore=clonedEstore,
      res=w.sub.world.res,
      soundmgr=w.sub.world.soundmgr,
    }
    appendRolling(w.sub.pastWorlds, clonedWorld, w.sub.maxPastWorlds)
  end
  return w,sidefx
end

local function controlledUpdate(w,action)
  if w.ui.pausedCheckbox.checked then
    if action.type == "tick" then
      updateGui(w)
    end
  else
    if action.type == "tick" then
      updateGui(w)
      action.dt = action.dt * w.ui.timeSpeedSlider.value
      return passThruUpdate(w,action)
    elseif action.type == "mouse" or action.type == "touch" then
      if not math.pointinrect(action.x,action.y, unpack(w.ui.topPanel)) then
        return passThruUpdate(w,action)
      end
    end
  end
  return w,action
end

function M.updateWorld(w,action)
  if w.ui.on then
    return controlledUpdate(w,action)
  else
    return passThruUpdate(w,action)
  end
end


local G = love.graphics

local function drawGui(w)
  G.setColor(0,0,0,w.ui.bgOpacity.value)
  G.rectangle("fill",unpack(w.ui.topPanel))
  suit.draw()
end

function M.drawWorld(w)
  local subWorld = w.sub.world
  if w.ui.on then
    drawGui(w)
    if w.ui.pausedCheckbox.checked then
      local stateNum = w.ui.timeNavSlider.value
      subWorld = w.sub.history[stateNum]
    end
  end
  w.sub.module.drawWorld(subWorld)
end

return M
