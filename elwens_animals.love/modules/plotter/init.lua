-- local Estore = require 'ecs.estore'
local Debug = require('mydebug').sub("plotter",true,true)
local G = love.graphics
local Viewport = require('modules.plotter.viewport')
local draw = require('modules.plotter.draw')

local DefaultScaleW = 50
local DefaultScaleH = 50

local M = {}

function rebuildAxes(w)
  local top,left,bottom,right = w.viewport:getSpaceExtents()

  local intx = 1
  left = math.floor(left / intx) * intx
  right = math.ceil(right / intx) * intx
  local inty = 1
  top= math.ceil(top / inty) * inty
  bottom = math.floor(bottom / inty) * inty

  local y = 0
  local xpts = {}
  local i = 1
  for x=left,right,intx do
    xpts[i] = x
    xpts[i+1] = y
    i = i + 2
  end

  local x = 0
  local ypts = {}
  i = 1
  for y=bottom,top,inty do
    ypts[i] = x
    ypts[i+1] = y
    i = i + 2
  end

  w.drawables.xaxis.pts = xpts
  w.drawables.yaxis.pts = ypts
end

function M.newWorld()
  local vp = Viewport:new()
  vp.scale.w = DefaultScaleW
  vp.scale.h = DefaultScaleH
  local world={
    viewport=vp,
    controller={
      dragging=false,
    },
    drawables={
      xaxis={
        type="series",
        kind="pointsAndLines",
        pts={},
        style={
          pointSize=4,
          color={0,1,0},
        },
      },
      yaxis={
        type="series",
        kind="pointsAndLines",
        pts={},
        style={
          pointSize=4,
          color={1,0,0},
        },
      },
      f1={
        type="fn",
        kind="points",
        fn=math.sin,
        style={
          color={1,1,1},
        },
      },
      f2={
        type="fn",
        kind="points",
        fn=math.cos,
        style={
          color={.6,.6,1},
          pointSize=1,
        },
      },
    },
  }
  rebuildAxes(world)
  return world
end

function M.updateWorld(w,action)
  local sidefx = nil

  if action.type == "tick" then
    -- w.viewport.focus.x = w.viewport.focus.x + 0.01
    -- w.viewport.focus.y = w.viewport.focus.y + 0.1
    rebuildAxes(w)

  elseif action.type == "mouse" then
    if action.state == "pressed" then
      w.controller.dragging=true

    elseif action.state == "moved" then
      if w.controller.dragging then
        local fdx = action.dx / w.viewport.scale.w
        local fdy =  action.dy / w.viewport.scale.h
        local focus = w.viewport.focus 
        focus.x = focus.x - fdx
        focus.y = focus.y + fdy
      end

    elseif action.state == "released" then
      w.controller.dragging=false
    end

  elseif action.type == "keyboard" and action.state == "pressed" then
    if action.gui then
      if action.key == "left" then
        local s = w.viewport.scale.w 
        if s <= 10 then
          s = s - 1
          if s <= 0 then s = 1 end
        else
          s = s - 20
          if s <= 10 then s = 10 end
        end
        w.viewport.scale.w = s
      elseif action.key == "right" then
        local s = w.viewport.scale.w 
        if s < 10 then
          s = s + 1
        else
          s = s + 20
        end
        if s > 500 then s = 500 end
        w.viewport.scale.w = s
      elseif action.key == "up" then
        local s = w.viewport.scale.h 
        if s < 10 then
          s = s + 1
        else
          s = s + 20
        end
        if s > 500 then s = 100 end
        w.viewport.scale.h = s
      
      elseif action.key == "down" then
        local s = w.viewport.scale.h 
        if s <= 10 then
          s = s - 1
          if s <= 0 then s = 1 end
        else
          s = s - 20
          if s <= 10 then s = 10 end
        end
        w.viewport.scale.h = s
     
      elseif action.key == "0" then
        w.viewport.scale.w = DefaultScaleW
        w.viewport.scale.h = DefaultScaleH
      end
    else
      local amt = 1
      if action.shift then
        amt = 5
      end
      if action.key == "left" then
        w.viewport.focus.x = w.viewport.focus.x - amt
      elseif action.key == "right" then
        w.viewport.focus.x = w.viewport.focus.x + amt 
      elseif action.key == "up" then
        w.viewport.focus.y = w.viewport.focus.y + amt 
      elseif action.key == "down" then
        w.viewport.focus.y = w.viewport.focus.y - amt 
      elseif action.key == "0" then
        w.viewport.focus.x = 0
        w.viewport.focus.y = 0
      end
    end

  end

  return w, sidefx
end

function M.drawWorld(w)
  G.setBackgroundColor(0,0,0)
  G.setColor(1,1,1,1)

  for _,d in pairs(w.drawables) do
    draw(d, w.viewport)
  end

  G.setColor(1,1,1,1)
  G.print("Focus: "..math.round(w.viewport.focus.x,3)..", "..math.round(w.viewport.focus.y,3).." | Arrows or mouse to move, shift-arrows for large moves, 0 to reset",0,0)
  G.print("Scale: "..math.round(w.viewport.scale.w,3)..", "..math.round(w.viewport.scale.h,3).." | Cmd-arrows to change scale, Cmd-0 to reset",0,15)
end

return M
