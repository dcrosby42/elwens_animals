require 'ecs.ecshelpers'
local Snowman = require('modules.snowman')
local Debug = require('mydebug').sub("EcsDev",true,true)
local suit = require 'SUIT'

local M = {}

local function getSubWorld(w)
  local subWorld = w.sub.world
  if w.ui.on and w.ui.pausedCheckbox.checked then
    local stateNum = w.ui.timeNavSlider.value
    local pw = w.sub.pastWorlds[stateNum]
    if pw then
      subWorld = pw
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
      recordEveryNth=1,
      tick=0,
    },
    ui={
      on=true,
      topPanel=topPanel,
      estorePanel=estorePanel,
      bgOpacity={value=0.8,min=0,max=1},
      timeSpeedSlider={value=1, min=0,max=2},
      historyCheckbox={text="Record", checked=false},
      pausedCheckbox={text="Paused", checked=true},
      estoreCheckbox={text="Entities", checked=true},
      timeNavSlider={value=1, min=1,max=1,step=1},
      ents={},
      pinnedEnts={},
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

local round = math.round
local function updateCompGui(c)
  local function name()
    local str = c.type
    str = string.sub(str,1,13)
    suit.Label("  ", suit.layout:row(10,h))
    suit.Button(str, {id=c.cid,align='right'}, suit.layout:col(100,h))
  end
  local h = 15
  local w = 1000
  if c.type == "pos" then
    name()
    
    local str = "("..round(c.x,3)..", "..round(c.y,3)..") r: "..round(c.r,3)
    suit.Label(str, {align='left'}, suit.layout:col(w,h))

  elseif c.type == "tag" then
    name()
    suit.Label(c.name, {align='left'}, suit.layout:col(w,h))
  elseif c.type == "name" then
    -- name()
    -- suit.Label(c.name, {align='left'}, suit.layout:col(w,h))
  else
    name()
    local str=""
    for key,val in pairs(c) do
      if key ~= "name" and key ~= "cid" and key ~= "eid" and key ~= "type" then
        if type(val) == "number" then
          val = round(val,3)
        end
        str = str .. key .. ": " .. tostring(val) .. " "
      end
    end
    suit.Label(str, {align='left'}, suit.layout:col(w,h))
  end

  suit.layout:returnLeft()
end

local function compareEids(a,b)
	return tonumber(string.sub(a,2)) < tonumber(string.sub(b,2))
end

local function updateEstoreGui(w,estore)
  local x = w.ui.estorePanel[1]
  local y = w.ui.estorePanel[2]
  local h = 15
  suit.layout:reset(x,y,5,2)

	-- For each Entity (sorted ascend by numeric eid)
  for eid,e in pairsByKeys(estore.ents, compareEids) do
		-- Entity name button
    local name = eid
    if e.name then name = e.name.name end
    if suit.Button(name, {id=eid, align='left'}, suit.layout:row(100,h)).hit then
      if w.ui.ents[eid] then
        w.ui.ents[eid] = nil
      else
        w.ui.pinnedEnts[eid] = true
        w.ui.ents[eid] = true
      end
    end

    -- Entity "pinned" checkbox
    local pinned = w.ui.pinnedEnts[eid] == true
    if suit.Checkbox({checked=pinned}, {id=eid.."_keep", align='right'}, suit.layout:col(100,15)).hit then
      if not pinned then
        w.ui.pinnedEnts[eid] = true
      else
        w.ui.pinnedEnts[eid] = false
      end
    end
    suit.layout:returnLeft()

    -- If Entity is "opened", show the components
    if w.ui.ents[eid] then
      local comps = {}
      for _,comp in pairs(estore.comps) do
        if eid == comp.eid then
          table.insert(comps, comp)
        end
      end
      for _,comp in ipairs(comps) do
        updateCompGui(comp)
      end
    end
  end
end

local function updateGui(w)
  local ret = {}

  w.ui.timeNavSlider.max = #w.sub.pastWorlds
  local x = 0
  local y = 0
  local h = 25
  suit.layout:reset(x,y,5,2)

  suit.Label("Opacity",{align='left'}, suit.layout:row(100,h))
  suit.Slider(w.ui.bgOpacity, suit.layout:col(100,h))
  suit.Label(tostring(w.ui.bgOpacity.value), suit.layout:col(50,h))
  if suit.Button("Reset", {id='reset2'}, suit.layout:col(50,h)).hit then
    w.ui.bgOpacity.value = 0.8
  end

  suit.layout:returnLeft()
  suit.Label("Time Dilation",{align='left'}, suit.layout:row(100,h))
  suit.Slider(w.ui.timeSpeedSlider, suit.layout:col(100,h))
  suit.Label(tostring(w.ui.timeSpeedSlider.value), suit.layout:col(50,h))
  if suit.Button("Reset", suit.layout:col(50,h)).hit then
    w.ui.timeSpeedSlider.value = 1
  end

  suit.layout:returnLeft()
  suit.Checkbox(w.ui.historyCheckbox, suit.layout:row(100,h))
  if w.ui.historyCheckbox.checked then
  end

  suit.layout:returnLeft()
  suit.Checkbox(w.ui.pausedCheckbox, suit.layout:row(100,h))
  if w.ui.pausedCheckbox.checked then
    suit.Label("History:",{align='left'}, suit.layout:col(50,h))
    suit.Slider(w.ui.timeNavSlider, suit.layout:col(100,h))
    roundSliderValue(w.ui.timeNavSlider)
    suit.Label(tostring(w.ui.timeNavSlider.value), suit.layout:col(50,h))
    if suit.Button("<", suit.layout:col(20,h)).hit then
      adjSliderValue(w.ui.timeNavSlider, -1)
    end
    if suit.Button(">", suit.layout:col(20,h)).hit then
      adjSliderValue(w.ui.timeNavSlider, 1)
    end
    if w.ui.timeNavSlider.value == w.ui.timeNavSlider.max then
      if suit.Button("Step 1", suit.layout:col(50,h)).hit then
        ret.step = true
      end
    end
  end

  suit.layout:returnLeft()
  suit.Checkbox(w.ui.estoreCheckbox, suit.layout:row(100,25))
  -- Figure our which snapshot of the world we're using:
  local subW = getSubWorld(w)
  if w.ui.estoreCheckbox.checked then
    updateEstoreGui(w,subW.estore)
    ret.toDraw = subW
  end


  return ret
end

local function appendRolling(list,item,max)
  table.insert(list,item)
  while #list > max do
    table.remove(list,1)
  end
end

local cloneId = 1
local function passThruUpdate(w,action)
  local sidefx
  w.sub.world, sidefx = w.sub.module.updateWorld(w.sub.world, action)
  if action.type == "tick" then
    if w.ui.historyCheckbox.checked then
      if w.sub.tick == 0 then
        local clonedInput = tcopydeep(w.sub.world.input)
        clonedInput.dt = action.dt
        local clonedEstore = w.sub.world.estore:clone({keepCaches=false})
        local clonedWorld = {
          cloneId=cloneId,
          input=clonedInput,
          estore=clonedEstore,
          resources=w.sub.world.resources,
          soundmgr=w.sub.world.soundmgr,
        }
        cloneId = cloneId+1
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
    --
    -- PAUSED
    --
    if action.type == "tick" then
      local ret = updateGui(w)
      if ret.step then
        action.dt = action.dt * w.ui.timeSpeedSlider.value
        return passThruUpdate(w,action)
      end
    end
  else
    --
    -- PLAYING
    --
    if action.type == "tick" then
      updateGui(w)
      action.dt = action.dt * w.ui.timeSpeedSlider.value
      return passThruUpdate(w,action)

    elseif action.type == "mouse" or action.type == "touch" then
      -- Make sure mouse/touch events that hit the admin UI get absorbed:
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
    print("uncontrolled update")
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
  local toDraw = getSubWorld(w)
  w.sub.module.drawWorld(toDraw)

  if w.ui.on then
    drawGui(w)
  end
end

return M
