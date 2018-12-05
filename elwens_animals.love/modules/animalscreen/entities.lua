local Comps = require 'comps'
local Estore = require 'ecs.estore'

local Entities={}

function Entities.initialEntities(res)
  local estore = Estore:new()

  Entities.zooKeeper(estore,res)

  Entities.floor(estore,res)

  Entities.quitButton(estore,res)
  -- local lion = Entities.animal(sp,"lion")
  -- lion.pos.x = 100
  -- lion.pos.y = 200

  return estore
end

function Entities.zooKeeper(estore,res)
  return estore:newEntity({
    {'tag',{name="zookeeper"}},
    {'img', {imgId='background1', sx=1, sy=1.05}}, -- zoo_keeper.png is 731px tall, we want to stretch it to 768
    {'pos', {}},
    {'debug', {name='nextAnimal',value=1}},
    {'sound', {sound='bgmusic',loop=true,duration=res.sounds.bgmusic.duration}},
    {'physicsWorld', {gy=9.8*64,allowSleep=false}},
  })
end

function Entities.animal(estore, res, kind)
  return estore:newEntity({
    {'tag',{name="animal"}},
    {'img', {imgId=kind, sx=0.5, sy=0.5, centerx=0.5, centery=0.5}}, 
    {'pos', {}},
    {'vel', {}},
    {'body', {kind="animal", group=0, debugDraw=false}},
  })
end

function Entities.floor(estore, res)
  return estore:newEntity({
    {'body', {kind="floor", group=0, debugDraw=false}},
    {'pos', {x=512,y=798}},
    {'vel', {}},
  })
end

function Entities.quitButton(estore, res)
  return estore:newEntity({
    {'img', {imgId='power-button-outline', sx=0.25,sy=0.25,centerx=0.5, centery=0.5, color={1,1,1,0.25}}},
    {'pos', {x=980,y=720}},
    {'button', {eventtype='QUIT', holdTime=1, radius=40}},
  })
end


return Entities
