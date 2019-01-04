local Comp = require 'ecs/component'
local Rng = require 'parkmiller'
local G =love.graphics

Comp.define("snowfield", {'seed',1,'small',1,'big',1,'dx',0,'dy',100,'coverage',0.0001,'screenw',0,'screenh',0})

Snow = {}

Snow.SnowfieldDefaults = {
  seed=1,
  small=1,
  big=3,
  dx=0,
  dy=100,
  coverage=0.0001,
  screenw=G.getWidth(),
  screenh=G.getHeight(),
}

Snow.newSnowField = function(estore, opts)
  local opts = tcopy(opts,Snow.SnowfieldDefaults)
  local name = opts.name or "snowfield?"
  opts.name=nil
  return estore:newEntity({
    {'name', {name=name}},
    {'snowfield', opts},
    {'timer', {name='snow', countDown=false}},
    {'pos', {}},
  })
end

local TileW = 400
local TileH = 400

local function drawSnowField(e)
  local comp = e.snowfield
  local t = e.timers.snow.t

  local offx = t * comp.dx
  local offy = t * comp.dy

  G.setColor(1,1,1,1)

  local txLo = math.floor(-offx / TileW)
  local tyLo = math.floor(-offy / TileH)
  local txHi = math.floor((comp.screenw - offx) / TileW)
  local tyHi = math.floor((comp.screenh - offy) / TileH)
  for ty=tyLo,tyHi do
    for tx=txLo,txHi do
      -- screen coords of tile upper-left
      local x = offx + tx*TileW 
      local y = offy + ty*TileH 

      -- number of flakes to draw in this tile:
      local count = math.floor(comp.coverage * TileW*TileH)

      local s = Rng.localRandom(comp.seed,tx,ty)
      local px,py,r
      for i=1,count do
        -- random location and size of flake inside the tile:
        px,s = Rng.randomFloat(s,0,TileW)
        py,s = Rng.randomFloat(s,0,TileH)
        r,s = Rng.randomFloat(s,comp.small, comp.big)
        -- Draw:
        G.circle("fill",x+px,y+py,r)
      end

    end
  end

end

Snow.drawingPlugin = function(e,estore,res)
  if e.snowfield then
    drawSnowField(e)
  end
end

return Snow
