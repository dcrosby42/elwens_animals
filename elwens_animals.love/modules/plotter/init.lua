-- local Estore = require 'ecs.estore'
local Debug = require('mydebug').sub("plotter",true,true)
local G = love.graphics
local Viewport = require('modules.plotter.viewport')
local draw = require('modules.plotter.draw')

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
  print("xaxis")
  for x=left,right,intx do
    xpts[i] = x
    xpts[i+1] = y
    print(tostring(i)..": "..xpts[i]..", "..xpts[i+1])
    i = i + 2
  end

  local x = 0
  local ypts = {}
  i = 1
  print("yaxis")
  for y=bottom,top,inty do
    ypts[i] = x
    ypts[i+1] = y
    print(tostring(i)..": "..ypts[i]..", "..ypts[i+1])
    i = i + 2
  end

  w.drawables.xaxis.pts = xpts
  w.drawables.yaxis.pts = ypts
end

function M.newWorld()
  local vp = Viewport:new()
  vp.scale.w = 50
  vp.scale.h = 50
  local world={
    viewport=vp,
    drawables={
      xaxis={
        kind="pointsAndLines",
        pts={},
        style={
          pointSize=4,
          color={0,1,0},
        },
      },
      yaxis={
        kind="pointsAndLines",
        pts={},
        style={
          pointSize=4,
          color={1,0,0},
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
    w.viewport.focus.x = w.viewport.focus.x + 0.01
    w.viewport.focus.y = w.viewport.focus.y + 0.1
    rebuildAxes(w)
  end

  return w, sidefx
end

function M.drawWorld(w)
  G.setBackgroundColor(0,0,0)
  G.setColor(1,1,1,1)

  for _,d in pairs(w.drawables) do
    draw(d, w.viewport)
  end
end

return M
