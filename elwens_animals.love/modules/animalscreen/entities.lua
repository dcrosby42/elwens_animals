local Comps = require 'comps'
local Estore = require 'ecs.estore'

local Entities={}

function Entities.initialEntities(res)
  local estore = Estore:new()

  Entities.zooKeeper(estore,res)

  Entities.floor(estore,res)

  Entities.nextModeButton(estore,res)
  Entities.quitButton(estore,res)
  -- local lion = Entities.animal(sp,"lion")
  -- lion.pos.x = 100
  -- lion.pos.y = 200

  return estore
end

function Entities.zooKeeper(estore,res)
  return estore:newEntity({
    {'tag',{name="zookeeper"}},
    {'pic', {id='background1', sx=1, sy=1.05}}, -- zoo_keeper.png is 731px tall, we want to stretch it to 768
    {'pos', {}},
    {'debug', {name='nextAnimal',value=1}},
    {'sound', {sound='bgmusic',loop=true,duration=res.sounds.bgmusic.duration}},
    {'physicsWorld', {gy=9.8*64,allowSleep=false}},
  })
end

function Entities.animal(estore, res, kind)
  return estore:newEntity({
    {'tag',{name="animal"}},
    {'pic', {id=kind, sx=0.5, sy=0.5, centerx=0.5, centery=0.5}}, 
    {'pos', {}},
    {'vel', {}},
    {'body', {}},
    {'circleShape', {radius=50}},
  })
end

function Entities.floor(estore,res)
  return estore:newEntity({
    {'tag', {name='floor'}},
    {'body', {debugDraw=true, dynamic=false}},
		{'rectangleShape', {w=1024,h=50}},
    {'pos', {x=512,y=793}},
	})
end

function Entities.quitButton(estore, res)
  return estore:newEntity({
    {'pic', {id='power-button-outline', sx=0.25,sy=0.25,centerx=0.5, centery=0.5, color={1,1,1,0.25}}},
    {'pos', {x=980,y=50}},
    {'button', {eventtype='POWER', holdtime=0.5, radius=40}},
  })
end

function Entities.nextModeButton(estore, res)
  return estore:newEntity({
    {'pic', {id='skip-button-outline', sx=0.25,sy=0.25,centerx=0.5, centery=0.5, color={1,1,1,0.25}}},
    {'pos', {x=900,y=50}},
    {'button', {eventtype='SKIP', holdtime=0.5, radius=40}},
  })
end


return Entities
