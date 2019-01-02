local Debug = require('mydebug').sub("SnowScratch",true,true)
-- local R = require 'resourceloader'
-- local A = require 'animalpics'
local Rng = require 'parkmiller'
local M={}

function M.newWorld()
  return {
    screen={
      w=1024,
      h=768,
    },
    snow={
      t=0,
      layers={
        {
          vx=10,
          vy=200,
          coverage=0.0001,
          small=2,
          big=3,
        },
        {
          vx=7,
          vy=120,
          coverage=0.0005,
          small=1,
          big=2,
        },
        {
          vx=4,
          vy=70,
          coverage=0.0001,
          small=1,
          big=1,
        },
      },
    },
  }
end

function M.updateWorld(w,action,res)
  if action.type == "tick" then
    w.snow.t = w.snow.t + action.dt
  end
  return w
end

local G =love.graphics
local Seed = 12345678

local function drawTile(tx,ty,tw,th,offx,offy,coverage,small,big)
  local x = offx + tx*tw 
  local y = offy + ty*th 

  local s = Rng.localRandom(Seed,tx,ty)

  local num = math.floor(coverage * tw*th)
  local px,py
  for i=1,num do
    px,s = Rng.randomInt(s,0,tw)
    py,s = Rng.randomInt(s,0,th)
    r,s = Rng.randomInt(s,small,big)
    G.circle("fill",x+px,y+py,r)
  end
  -- G.rectangle("line",x,y,tw,th)
end

function M.drawWorld(w)
  local tw=400
  local th=400

  for i=1,#w.snow.layers do 
    local layer=w.snow.layers[i]
    local offx = w.snow.t * layer.vx
    local offy = w.snow.t * layer.vy
    local txLo = math.floor(-offx / tw)
    local tyLo = math.floor(-offy / th)
    local txHi = math.floor((w.screen.w - offx) / tw)
    local tyHi = math.floor((w.screen.h - offy) / th)
    local cov = layer.coverage
    local small = layer.small
    local big = layer.big
    G.setColor(1,1,1,1)
    for ty=tyLo,tyHi do
      for tx=txLo,txHi do
        drawTile(tx,ty, tw,th,offx,offy,cov,small,big)
      end
    end
  end
end

return M
