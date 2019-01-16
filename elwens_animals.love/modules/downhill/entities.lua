local Comps = require 'comps'
local Estore = require 'ecs.estore'
local AnimalEnts = require 'modules.animalscreen.entities'
local Snow = require 'modules.snowman.snow'
local F = require 'modules.plotter.funcs'

local Entities={}

function Entities.initialEntities(res)
  local estore = Estore:new()

  local bg = Entities.background(estore,res)

  Entities.ground(estore)
  Entities.ball(estore)
  Entities.viewport(estore)

	-- TODO AnimalEnts.buttons(bg,res)
	AnimalEnts.buttons(estore,res)

  return estore
end

local debugDraw = true

function Entities.viewport(estore,res)
  return estore:newEntity({
    {'name',{name="viewport"}},
    {'viewport',{}},
  })
end

function Entities.background(estore,res)
  return estore:newEntity({
    {'name',{name="background"}},
    -- {'pic', {id='background1', sx=1, sy=1.05}}, -- zoo_keeper.png is 731px tall, we want to stretch it to 768
    {'pos', {}},
    -- {'sound', {sound='bgmusic',loop=true,duration=res.sounds.bgmusic.duration}},
    {'physicsWorld', {gy=9.8*64,allowSleep=false}},
  })
end

function Entities.ground(parent,res)
  local verts = F.genSeries(0, 1024, 10, function(x)
    return x/2 + math.sin(x/50)*50
  end)
  parent:newEntity({
    {'name',{name="ground"}},
    {'body', {dynamic=false, debugDraw=debugDraw}},
		{'chainShape', {vertices=verts}},
    {'pos', {x=0,y=0}},
  })

  local verts2 = F.genSeries(1020, 2048, 10, function(x)
    return x/2 + math.sin(x/50)*50
  end)
  parent:newEntity({
    {'name',{name="ground2"}},
    {'body', {dynamic=false, debugDraw=debugDraw}},
		{'chainShape', {vertices=verts2}},
    {'pos', {x=0,y=0}},
  })
end

function Entities.ball(estore, res, kind)
  return estore:newEntity({
    {'name',{name="ball"}},
    -- {'pic', {id=kind, sx=0.5, sy=0.5, centerx=0.5, centery=0.5}}, 
    {'pos', {x=10,y=0}},
    {'vel', {}},
    {'body', {debugDraw=debugDraw}},
    {'circleShape', {radius=25}},
    {'viewportTarget', {offx=-love.graphics.getWidth()/2, offy=-love.graphics.getHeight()/2}},
  })
end
-- function Entities.background(parent,res)
--   return parent:newEntity({
--     {'name', {name="background"}},
--     {'pic', {id='woodsbg', sx=1, sy=1}}, 
--     {'pos', {}},
--     {'sound', {sound='bgmusic', loop=true, duration=res.sounds.bgmusic.duration}},
--     {'physicsWorld', {gy=9.8*64,allowSleep=false}},
--   })
-- end 

-- local function mkslice(x1,y1,x2,y2,y3)
--   local pts = {x1,y1, x2,y2, x2,y3, x1,y3}
-- end

-- function Entities.slice(e,x1,y1,x2,y2,y3)
  -- local pts = mkslice(x1,y1,x2,y2,y3)
  -- return e:newEntity({
  --   {'pos', {x=100,y=200}},
  --   {'polygonShape', {vertices=pts}},
  --   {'lineStyle', {draw=true, color={.2,.2,.5}, closepolygon=true}},
  -- })
-- end

return Entities
