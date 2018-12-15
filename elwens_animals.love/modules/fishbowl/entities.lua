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
  local spawnInterval = 5
  return estore:newEntity({
    {'tag',{name="fishbowl"}},
    {'pic', {id='aquarium', sx=1, sy=1}}, 
    {'pos', {}},
    {'sound', {name="bubbles",sound='underwater', loop=true, duration=res.sounds.underwater.duration}},
    {'sound', {name="bgm", sound='fishmusic', loop=true, duration=res.sounds.fishmusic.duration}},
    {'physicsWorld', {gy=0,allowSleep=false}},
    {'fishspawner', {}},
    {'timer',{name='fishspawner',reset=spawnInterval,t=spawnInterval,loop=true,countdown=true}},
  })
end

function Entities.fish(estore, res)
  return estore:newEntity({
    {'tag',{name="animal"}},
    {'tag',{name="fish"}},
    {'pos', {}},
    {'vel', {}},
    {'body', {kind="animal", group=0, debugDraw=false}},

    {'anim',   {name="fishy", id="fish_black_idle", sx=0.5, sy=0.5, centerx=0.5, centery=0.5}}, 
    {'timer', {name="fishy", countup=true}},
  })
end

return Entities
