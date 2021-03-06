local Comps = require 'comps'
local Estore = require 'ecs.estore'
local AnimalEnts = require 'modules.animalscreen.entities'
local Snow = require 'modules.snowman.snow'

local Entities={}

function Entities.initialEntities(res)
  local estore = Estore:new()

  local bg = Entities.background(estore,res)

  Entities.snowBack(bg,res)

  Entities.snowman(bg,res)

  Entities.snowFore(bg,res)

	AnimalEnts.buttons(bg,res)

  local floor = AnimalEnts.floor(bg,res)
  
  return estore
end

function Entities.background(parent,res)
  return parent:newEntity({
    {'name', {name="background"}},
    {'pic', {id='woodsbg', sx=1, sy=1}}, 
    {'pos', {}},
    {'sound', {sound='bgmusic', loop=true, duration=res.sounds.bgmusic.duration}},
    {'physicsWorld', {gy=9.8*64,allowSleep=false}},
  })
end 

function Entities.snowBack(parent,res)
  Snow.newSnowField(parent, {name="snowfield3", seed=1, small=1, big=2, dy=30,dx=-10})
  Snow.newSnowField(parent, {name="snowfield2", seed=2, small=1, big=3, dy=60,dx=-20})
end

function Entities.snowFore(parent,res)
  Snow.newSnowField(parent, {name="snowfield1", seed=3, small=3, big=4, dy=120,dx=-40})
end

function Entities.snowman(parent,res)
  local motor = -1000
  local maxForce = 1000
	local physicsDebug = false
	local drawPicBounds = false

  local parent = parent:newEntity({
    {'name', {name='snowman'}},
    {'tag', {name='snowman'}},
    {'health', {hp=5,maxhp=5}},
  })

  -- head:
  local head = parent:newEntity({
    {'name', {name='snowman_head'}},
    {'body', {debugDrawphysicsDebug}},
		{'circleShape', {radius=25}},
    {'pic', {id="snowman_ball_1", sx=0.25, sy=0.25, centerx=0.5, centery=0.5, drawbounds=drawPicBounds}}, 
    {'pos', {x=600,y=400}},
    {'vel', {}},
    {'force', {}},
  })
  -- middle:
  local body = parent:newEntity({
    {'name', {name='snowman_body'}},
    {'tag', {name='cannon_target'}},
    {'body', {debugDrawphysicsDebug}},
		{'circleShape', {radius=50}},
    {'pic', {id="snowman_ball_1", sx=0.43, sy=0.43, centerx=0.5, centery=0.5, drawbounds=drawPicBounds}}, 
    {'pos', {x=600,y=500}},
    {'vel', {}},
    {'force', {}},
    {'joint', {kind='prismatic', toEntity=head.eid, lowerlimit=70, upperlimit=85, motorspeed=0, maxmotorforce=0}},
  })
  -- base:
  local base = parent:newEntity({
    {'name', {name='snowman_base'}},
    {'tag', {name='upright_snowman'}}, -- signals the "upright" system to operate on this object
    {'body', {debugDrawphysicsDebug}},
		{'circleShape', {radius=80}},
    {'pic', {id="snowman_ball_1", sx=0.7, sy=0.7, centerx=0.5, centery=0.5, drawbounds=drawPicBounds}}, 
    {'pos', {x=600,y=600}},
    {'vel', {}},
    {'force', {}},
    {'joint', {kind='prismatic', toEntity=body.eid, lowerlimit=120, upperlimit=140, motorspeed=0, maxmotorforce=0}},
  })

  -- Hat
  local hat = head:newEntity({
    {'name', {name='snowman_hat'}},
    {'body', {debugDrawphysicsDebug}},
		{'rectangleShape', {w=60,h=40}},
    {'pic', {id="hat", sx=0.55, sy=0.55, r=0.0, centerx=0.5, centery=0.5,drawbounds=false}}, 
    {'pos', {x=600,y=376}},
    {'vel', {}},
    {'force', {}},
    {'joint', {kind='prismatic', toEntity=head.eid, lowerlimit=50, upperlimit=60, motorspeed=0, maxmotorforce=0}},
  })
  -- Eyes
  local rightEye = head:newEntity({
    {'name', {name='righteye'}},
    {'pic', {id="coal3", sx=0.35, sy=0.35, r=0.0, centerx=0.5, centery=0.5,drawbounds=false}}, 
    {'body', {debugDrawphysicsDebug}},
		{'circleShape', {radius=5}},
    {'pos', {x=602,y=388}},
    {'joint', {kind='weld', toEntity=head.eid}},
    {'vel', {}},
    {'force', {}},
  })
  local leftEye = head:newEntity({
    {'name', {name='lefteye'}},
    {'pic', {id="coal1", sx=0.35, sy=0.35, r=0.0, centerx=0.5, centery=0.5,drawbounds=false}}, 
    {'body', {debugDrawphysicsDebug}},
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
  for i,xy in ipairs(mouthCoals) do
    head:newEntity({
      {'name',{name="mouthcoal_"..i}},
      {'pic', {id="coal2", sx=0.3, sy=0.3, r=0.0, centerx=0.5, centery=0.5,drawbounds=false}}, 
      {'body', {debugDrawphysicsDebug}},
      {'circleShape', {radius=2}},
      {'pos', {x=anchX+(xy[1]*1.5), y=anchY+(xy[2]*1.5)}},
      {'joint', {kind='weld', toEntity=head.eid}},
      {'vel', {}},
      {'force', {}},
    })
  end
  
  -- Nose
  local nose = parent:newEntity({
      {'name',{name="nose"}},
    {'pic', {id="carrot", sx=0.28, sy=0.28, r=0.0, centerx=0.5, centery=0.5,drawbounds=false}}, 
    {'body', {debugDrawphysicsDebug}},
		{'rectangleShape', {w=45,h=7}},
    {'pos', {x=567,y=402}},
    {'joint', {kind='weld', toEntity=head.eid}},
    {'vel', {}},
    {'force', {}},
  })

end

function Entities.gift(parent,res,name)
  local g = res.gifts[name]
  if not g then error("No gift resource named "..tostring(name)) end
  local scale = g.scale
  local w = scale
  local cx = g.centerx or 0.5
  local cy = g.centery or 0.5
  local e =  parent:newEntity({
    {'name',{name="gift"}},
    {'tag', {name='gift'}},
    {'tag', {name='self_destruct'}},
    {'body', {}},
    {'rectangleShape', {w=scale*g.w,h=scale*g.h}},
    {'pic', {id=g.name, sx=scale, sy=scale, centerx=cx, centery=cy,r=-0.3}}, 
    {'pos', {}},
    {'vel', {}},
    {'force', {}},
    {'timer', {t=4, name='self_destruct'}},
  })
  e.parent.order = 1000
  return e
end

return Entities
