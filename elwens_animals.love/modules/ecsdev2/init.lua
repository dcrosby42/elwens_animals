require 'ecs.ecshelpers'
local Snowman = require('modules.snowman')
local Debug = require('mydebug').sub("EcsDev2",true,true)
local suit = require 'SUIT'

local M = {}

local function getSubWorld(w)
  local subWorld = w.sub.world
  if w.ui.on and w.ui.pausedCheckbox.checked then
    local stateNum = w.ui.timeNavSlider.value
    local w = w.sub.pastWorlds[stateNum]
    if w then
      subWorld = w
    end
  end
  return subWorld
end

function M.newWorld(args)
  local m = args.module
  if not m then m = Snowman end

  local topPanel={0,0,1024,130}
  local estorePanel={0,topPanel[4],400,668}
  local world={
    sub={
      module=m,
      world=m.newWorld(),
      pastWorlds={},
      maxPastWorlds=30*60,
      -- recordHistory=false,
      recordEveryNth=10,
      tick=0,
    },
    ui={
      on=true,
      topPanel=topPanel,
      estorePanel=estorePanel,
      bgOpacity={value=0.7,min=0,max=1},
      timeSpeedSlider={value=1, min=0,max=2},
      historyCheckbox={text="Record", checked=false},
      pausedCheckbox={text="Paused", checked=false},
      estoreCheckbox={text="Entities", checked=false},
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

local function updateEstoreGui(w)
  local x = w.ui.estorePanel[1]
  local y = w.ui.estorePanel[2]
  local h = 10
  suit.layout:reset(x,y,5,2)

  local estore = getSubWorld(w).estore
  -- for eid,ent in pairs(estore.ents) do
    suit.Label(""..estore.eidCounter, suit.layout:row(40,h))
    suit.Label(""..estore.cidCounter, suit.layout:row(40,h))
  -- end
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
  suit.Checkbox(w.ui.historyCheckbox, suit.layout:row(100,25))
  if w.ui.historyCheckbox.checked then
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

  suit.layout:returnLeft()
  suit.Checkbox(w.ui.estoreCheckbox, suit.layout:row(100,25))
  if w.ui.estoreCheckbox.checked then
    updateEstoreGui(w)
  end
end

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
    if w.ui.historyCheckbox.checked then
      if w.sub.tick == 0 then
        local clonedInput = tcopydeep(w.sub.world.input)
        clonedInput.dt = action.dt
        local clonedEstore = w.sub.world.estore:clone({keepCaches=true})
        local clonedWorld = {
          input=clonedInput,
          estore=clonedEstore,
          resources=w.sub.world.resources,
          soundmgr=w.sub.world.soundmgr,
        }
        appendRolling(w.sub.pastWorlds, clonedWorld, w.sub.maxPastWorlds)
        w.ui.timeNavSlider.value = #w.sub.pastWorlds
      end
      w.sub.tick = (w.sub.tick+1) % w.sub.recordEveryNth
    end
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
      local uiHit = false
      if w.ui.on and math.pointinrect(action.x,action.y, unpack(w.ui.topPanel)) then
        uiHit = true
      elseif w.ui.on and w.ui.estoreCheckbox.checked and math.pointinrect(action.x,action.y, unpack(w.ui.estorePanel)) then
        uiHit = true
      end
      if not uiHit then
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
  if w.ui.estoreCheckbox.checked then
    G.rectangle("fill",unpack(w.ui.estorePanel))
  end
  suit.draw()
end


function M.drawWorld(w)
  w.sub.module.drawWorld(getSubWorld(w))

  if w.ui.on then
    drawGui(w)
  end
end

return M
