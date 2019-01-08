local Comps = require 'comps'
local Estore = require 'ecs.estore'
local AnimalEnts = require 'modules.animalscreen.entities'
local Snow = require 'modules.snowman.snow'

local Entities={}

function Entities.initialEntities(res)
  local estore = Estore:new()

  Entities.scene(estore,res)

  AnimalEnts.floor(estore,res)

  AnimalEnts.buttons(estore,res)
  
  return estore
end

function Entities.scene(estore,res)
  local bubbleInt = 0.3
  local scene = estore:newEntity({
    {'tag',{name="christmas"}},
    {'pic', {id='reindeer_fireplace', sx=1, sy=1}}, 
    {'pos', {x=-80}},
    {'sound', {sound='bgmusic', loop=true, duration=res.sounds.bgmusic.duration}},
    {'physicsWorld', {gy=9.8*64,allowSleep=false}},
    -- {'timer',{name='fishspawner',reset=1,t=1,loop=true}},
    --100
  })
  -- scene:addChild(Snow.newSnowMachine(estore, {large=2, small=1, dy=15}))
  -- scene:addChild(Snow.newSnowMachine(estore, {large=3, small=1, dy=30}))
  -- scene:addChild(Snow.newSnowMachine(estore, {large=5, small=3, dy=60}))
  Snow.newSnowField(estore, {seed=1, small=1, big=2, dy=15,dx=0})
  Snow.newSnowField(estore, {seed=2, small=1, big=3, dy=30,dx=0})
  Snow.newSnowField(estore, {seed=3, small=1, big=3, dy=60,dx=0})
  --
  -- Snow.newSnowMachine(estore, {large=2, small=1, dy=15})
  -- Snow.newSnowMachine(estore, {large=3, small=1, dy=30})
  -- Snow.newSnowMachine(estore, {large=5, small=3, dy=60})
  return scene
end

function Entities.ornament(estore, res, kind)
  return estore:newEntity({
    {'tag',{name="ornament"}},
    {'pic', {id=kind, sx=0.5, sy=0.5, centerx=0.5, centery=0.5}}, 
    {'pos', {}},
    {'vel', {}},
    {'body', {}},
    {'circleShape', {radius=50}},
  })
end

return Entities
