local Comps = require 'comps'
local Estore = require 'ecs.estore'
local AnimalEnts = require 'modules.animalscreen.entities'
local Snow = require 'modules.christmas.snow'

local Entities={}

function Entities.initialEntities(res)
  local estore = Estore:new()

  Entities.background(estore,res)

  Entities.snowBack(estore,res)

  Entities.snowman(estore,res)

  Entities.snowFore(estore,res)

  AnimalEnts.nextModeButton(estore,res)
  AnimalEnts.quitButton(estore,res)

  local floor = AnimalEnts.floor(estore,res)
  
  return estore
end

-- function Entities.floor(estore,res)
--   return estore:newEntity({
--     {'tag', {name='floor'}},
--     {'body', {debugDraw=true, dynamic=false}},
-- 		{'rectangleShape', {w=1024,h=50}},
--     {'pos', {x=512,y=793}},
-- 	})
-- end

function Entities.background(estore,res)
  estore:newEntity({
    {'pic', {id='woodsbg', sx=1, sy=1}}, 
    {'pos', {}},
    -- {'sound', {sound='bgmusic', loop=true, duration=res.sounds.bgmusic.duration}},
    {'physicsWorld', {gy=9.8*64,allowSleep=false}},
  })
end 

function Entities.snowBack(estore,res)
  Snow.newSnowMachine(estore, {interval=0.1, large=2, small=1, dy=30,dx=-10})
  Snow.newSnowMachine(estore, {interval=0.1,large=3, small=1, dy=60,dx=-20})
end

function Entities.snowFore(estore,res)
  Snow.newSnowMachine(estore, {interval=0.1, large=5, small=3, dy=120,dx=-40})
end

function Entities.snowman(estore,res)
  local motor = -1000
  local maxForce = 1000
	local debugDraw = false

  -- head:
  local ball3 = estore:newEntity({
    {'tag', {name='snowman_head'}},
    {'body', {debugDraw=debugDraw}},
		{'circleShape', {radius=25}},
    {'pic', {id="snowman_ball_1", sx=0.25, sy=0.25, centerx=0.5, centery=0.5}}, 
    {'pos', {x=600,y=400}},
    {'vel', {}},
    {'force', {}},
  })
  -- middle:
  local ball2 = estore:newEntity({
    {'tag', {name='snowman_body'}},
    {'tag', {name='cannon_target'}},
    {'body', {debugDraw=debugDraw}},
		{'circleShape', {radius=50}},
    {'pic', {id="snowman_ball_1", sx=0.43, sy=0.43, centerx=0.5, centery=0.5}}, 
    {'pos', {x=600,y=500}},
    {'vel', {}},
    {'force', {}},
    {'joint', {kind='snowman', to='snowman_head', lowerlimit=65, upperlimit=85, motorspeed=0, maxmotorforce=0}},
  })
  -- base:
  local ball1 = estore:newEntity({
    {'tag', {name='snowman_base'}},
    {'tag', {name='upright_snowman'}}, -- signals the "upright" system to operate on this object
    {'body', {debugDraw=debugDraw}},
		{'circleShape', {radius=80}},
    {'pic', {id="snowman_ball_1", sx=0.7, sy=0.7, centerx=0.5, centery=0.5}}, 
    {'pos', {x=600,y=600}},
    {'vel', {}},
    {'force', {}},
    {'joint', {kind='snowman', to='snowman_body', lowerlimit=120, upperlimit=140, motorspeed=0, maxmotorforce=0}},
  })

end

function Entities.gift(estore,res,name)
  local g = res.gifts[name]
  if not g then error("No gift resource named "..tostring(name)) end
  local scale = g.scale
  local w = scale
  local cx = g.centerx or 0.5
  local cy = g.centery or 0.5
  return estore:newEntity({
    {'body', {}},
    {'rectangleShape', {w=scale*g.w,h=scale*g.h}},
    {'pic', {id=g.name, sx=scale, sy=scale, centerx=cx, centery=cy,r=-0.3}}, 
    {'pos', {}},
    {'vel', {}},
    {'force', {}},
  })
end

return Entities
