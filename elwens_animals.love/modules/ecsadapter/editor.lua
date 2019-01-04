local History = require('modules.ecsadapter.estorehistory')
local suit = require 'SUIT'

local Editor = {}

function Editor.init()
  local editor={
    on = false,
    recording = false,
    history = History:new(10*60),
    historyIndex = 0,
    ui={
      bgOpacity={value=0.8,min=0,max=1},
      timeSpeedSlider={value=1, min=0,max=2},
      historyCheckbox={text="Record", checked=false},
      pausedCheckbox={text="Paused", checked=false},
      estoreCheckbox={text="Entities", checked=true},
      timeNavSlider={value=0, min=0,max=0,step=1},
      ents={},
      pinnedEnts={},
    },
  }
  return editor 
end

local function getEstore(editor)
  if editor.historyIndex > 0 then
    local es = editor.history:get(editor.historyIndex)
    if es == nil then
      print("SHIT: editor.historyIndex="..editor.historyIndex.." but len is "..editor.history:length())
      return editor.estore
    end
    return es
  else
    return editor.estore
  end
end
Editor.getEstore = getEstore

local round,round0 = math.round, math.round0

local function roundSliderValue(sl)
  sl.value = round0(sl.value)
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

local function updateEstoreGui(ui, estore)
  -- local x = ui.estorePanel[1]
  -- local y = ui.estorePanel[2]
  local h = 15
  -- suit.layout:reset(x,y,5,2)

	-- For each Entity (sorted ascend by numeric eid)
  for eid,e in pairsByKeys(estore.ents, compareEids) do
		-- Entity name button
    local name = eid
    if e.name then name = e.name.name end
    if suit.Button(name, {id=eid, align='left'}, suit.layout:row(100,h)).hit then
      if ui.ents[eid] then
        ui.ents[eid] = nil
      else
        ui.pinnedEnts[eid] = true
        ui.ents[eid] = true
      end
    end

    -- Entity "pinned" checkbox
    local pinned = ui.pinnedEnts[eid] == true
    if suit.Checkbox({checked=pinned}, {id=eid.."_keep", align='right'}, suit.layout:col(100,15)).hit then
      if not pinned then
        ui.pinnedEnts[eid] = true
      else
        ui.pinnedEnts[eid] = false
      end
    end
    suit.layout:returnLeft()

    -- If Entity is "opened", show the components
    if ui.ents[eid] then
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

function Editor.update(editor)
  local ret = {}
  local ui = editor.ui

  local x = 0
  local y = 0
  local h = 25
  suit.layout:reset(x,y,5,2)

  suit.Label("Opacity",{align='left'}, suit.layout:row(100,h))
  suit.Slider(ui.bgOpacity, suit.layout:col(100,h))
  suit.Label(tostring(ui.bgOpacity.value), suit.layout:col(50,h))
  if suit.Button("Reset", {id='reset2'}, suit.layout:col(50,h)).hit then
    ui.bgOpacity.value = 0.8
  end

  suit.layout:returnLeft()
  suit.Label("Time Dilation",{align='left'}, suit.layout:row(100,h))
  suit.Slider(ui.timeSpeedSlider, suit.layout:col(100,h))
  suit.Label(tostring(ui.timeSpeedSlider.value), suit.layout:col(50,h))
  if suit.Button("Reset", suit.layout:col(50,h)).hit then
    ui.timeSpeedSlider.value = 1
  end

  suit.layout:returnLeft()
  suit.Checkbox(ui.historyCheckbox, suit.layout:row(100,h))
  editor.recording = ui.historyCheckbox.checked

  suit.layout:returnLeft()
  suit.Checkbox(ui.pausedCheckbox, suit.layout:row(100,h))

  ui.timeNavSlider.min = 1
  ui.timeNavSlider.max = editor.history:length()
  ui.timeNavSlider.value = editor.historyIndex

  suit.Label("History:",{align='left'}, suit.layout:col(50,h))
  if editor.history:length() > 0 then
    suit.Slider(ui.timeNavSlider, suit.layout:col(100,h))
    roundSliderValue(ui.timeNavSlider)
    suit.Label(tostring(ui.timeNavSlider.value), suit.layout:col(50,h))
    if suit.Button("<", suit.layout:col(20,h)).hit then
      adjSliderValue(ui.timeNavSlider, -1)
    end
    if suit.Button(">", suit.layout:col(20,h)).hit then
      adjSliderValue(ui.timeNavSlider, 1)
    end
    if ui.timeNavSlider.value == ui.timeNavSlider.max then
      if suit.Button("Step 1", suit.layout:col(50,h)).hit then
        ret.step = true
      end
    end
    editor.historyIndex = ui.timeNavSlider.value
  end

  suit.layout:returnLeft()
  suit.Checkbox(ui.estoreCheckbox, suit.layout:row(100,25))
  if ui.estoreCheckbox.checked then
    updateEstoreGui(ui, getEstore(editor))
  end

  return ret
end

function Editor.draw(editor)
  suit.draw()
end

return Editor
