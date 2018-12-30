local Comps = require 'comps'
local Estore = require 'ecs.estore'
local AnimalEnts = require 'modules.animalscreen.entities'

local Entities={}

function Entities.initialEntities(res)
  local estore = Estore:new()

  Entities.fishBowl(estore,res)

  AnimalEnts.floor(estore,res)

  AnimalEnts.nextModeButton(estore,res)
  AnimalEnts.quitButton(estore,res)
  
  -- local lion = Entities.animal(sp,"fish")
  --
  -- lion.pos.x = 100
  -- lion.pos.y = 200

  return estore
end

function Entities.fishBowl(estore,res)
  local bubbleInt = 0.3
  return estore:newEntity({
    {'tag',{name="fishbowl"}},
    {'pic', {id='aquarium', sx=1, sy=1}}, 
    {'pos', {}},
    {'sound', {name="bubbles",sound='underwater', loop=true, duration=res.sounds.underwater.duration}},
    {'sound', {name="bgm", sound='fishmusic', loop=true, duration=res.sounds.fishmusic.duration}},
    {'physicsWorld', {gy=0,allowSleep=false}},
    {'fishspawner', {}},
    {'timer',{name='fishspawner',reset=1,t=1,loop=true}},
    {'timer',{name='bubbler',reset=bubbleInt,t=bubbleInt,loop=true}},
  })
end

function Entities.fish(estore, res)
  return estore:newEntity({
    {'tag',{name="fish"}},
    {'fish', {kind='yellow',state="swim",targetspeed=0}},
    {'anim',   {name="fishy", id="", centerx=0.5, centery=0.5, drawbounds=false}}, 
    {'timer', {name="fishy", countDown=false}},
    {'body', {}},
    {'circleShape', {radius=50}},
    {'force', {}},
    {'pos', {}},
    {'vel', {}},
    {'timer', {name="brain", t=3, reset=3, loop=true}},
  })
end

function Entities.bubble(estore, opts)
  opts = opts or {x=0, y=0, size=0.5}
  return estore:newEntity({
    {'tag',{name="bubble"}},
    {'pic',   {id="bubble_white", sx=opts.size, sy=opts.size, centerx=0.5, centery=0.5, drawbounds=false}}, 
    {'body', {}},
    {'circleShape',{radius=opts.size*40}},
    {'force', {fx=0,fy=-50}},
    {'pos', {x=opts.x, y=opts.y}},
    {'vel', {}},
  })
end

return Entities
