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

  local parent = estore:newEntity({
    {'tag', {name='snowman'}},
    {'health', {hp=5,maxhp=5}},
  })

  -- head:
  local head = parent:newEntity({
    {'body', {debugDraw=debugDraw}},
		{'circleShape', {radius=25}},
    {'pic', {id="snowman_ball_1", sx=0.25, sy=0.25, centerx=0.5, centery=0.5}}, 
    {'pos', {x=600,y=400}},
    {'vel', {}},
    {'force', {}},
  })
  -- middle:
  local body = parent:newEntity({
    {'tag', {name='cannon_target'}},
    {'body', {debugDraw=debugDraw}},
		{'circleShape', {radius=50}},
    {'pic', {id="snowman_ball_1", sx=0.43, sy=0.43, centerx=0.5, centery=0.5}}, 
    {'pos', {x=600,y=500}},
    {'vel', {}},
    {'force', {}},
    {'joint', {kind='prismatic', toEntity=head.eid, lowerlimit=70, upperlimit=85, motorspeed=0, maxmotorforce=0}},
  })
  -- base:
  local base = parent:newEntity({
    {'tag', {name='upright_snowman'}}, -- signals the "upright" system to operate on this object
    {'body', {debugDraw=debugDraw}},
		{'circleShape', {radius=80}},
    {'pic', {id="snowman_ball_1", sx=0.7, sy=0.7, centerx=0.5, centery=0.5}}, 
    {'pos', {x=600,y=600}},
    {'vel', {}},
    {'force', {}},
    {'joint', {kind='prismatic', toEntity=body.eid, lowerlimit=120, upperlimit=140, motorspeed=0, maxmotorforce=0}},
  })

  -- Hat
  local hat = parent:newEntity({
    {'body', {debugDraw=debugDraw}},
		{'rectangleShape', {w=60,h=40}},
    {'pic', {id="hat", sx=0.55, sy=0.55, r=0.0, centerx=0.5, centery=0.5,drawbounds=false}}, 
    {'pos', {x=600,y=376}},
    {'vel', {}},
    {'force', {}},
    {'joint', {kind='prismatic', toEntity=head.eid, lowerlimit=50, upperlimit=60, motorspeed=0, maxmotorforce=0}},
  })
  -- Eyes
  local rightEye = parent:newEntity({
    {'pic', {id="coal3", sx=0.35, sy=0.35, r=0.0, centerx=0.5, centery=0.5,drawbounds=false}}, 
    {'body', {debugDraw=debugDraw}},
		{'circleShape', {radius=5}},
    {'pos', {x=602,y=388}},
    {'joint', {kind='weld', toEntity=head.eid}},
    {'vel', {}},
    {'force', {}},
  })
  local leftEye = parent:newEntity({
    {'pic', {id="coal1", sx=0.35, sy=0.35, r=0.0, centerx=0.5, centery=0.5,drawbounds=false}}, 
    {'body', {debugDraw=debugDraw}},
		{'circleShape', {radius=5}},
    {'pos', {x=580,y=388}},
    {'joint', {kind='weld', toEntity=head.eid}},
    {'vel', {}},
    {'force', {}},
  })
  local mouthCoals = {
    {-9,-5},
    {-3,-2},
    {3,-2},
    {9,-5},
  }
  local anchX=591
  local anchY=415
  for _,xy in ipairs(mouthCoals) do
    parent:newEntity({
      {'pic', {id="coal2", sx=0.3, sy=0.3, r=0.0, centerx=0.5, centery=0.5,drawbounds=false}}, 
      {'body', {debugDraw=debugDraw}},
      {'circleShape', {radius=2}},
      {'pos', {x=anchX+(xy[1]*1.5), y=anchY+(xy[2]*1.5)}},
      {'joint', {kind='weld', toEntity=head.eid}},
      {'vel', {}},
      {'force', {}},
    })
  end
  
  -- Nose
  local nose = parent:newEntity({
    {'pic', {id="carrot", sx=0.28, sy=0.28, r=0.0, centerx=0.5, centery=0.5,drawbounds=false}}, 
    {'body', {debugDraw=debugDraw}},
		{'rectangleShape', {w=45,h=7}},
    {'pos', {x=567,y=402}},
    {'joint', {kind='weld', toEntity=head.eid}},
    {'vel', {}},
    {'force', {}},
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
    {'tag', {name='gift'}},
    {'body', {}},
    {'rectangleShape', {w=scale*g.w,h=scale*g.h}},
    {'pic', {id=g.name, sx=scale, sy=scale, centerx=cx, centery=cy,r=-0.3}}, 
    {'pos', {}},
    {'vel', {}},
    {'force', {}},
  })
end

return Entities
