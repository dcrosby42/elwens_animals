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
    {'img', {imgId='aquarium', sx=1, sy=1}}, 
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
    {'img', {imgId="fish", sx=0.5, sy=0.5, centerx=0.5, centery=0.5}}, 
    {'pos', {}},
    {'vel', {}},
    {'body', {kind="animal", group=0, debugDraw=false}},
  })
end
--
-- function Entities.animal(estore, res, kind)
--   return estore:newEntity({
--     {'tag',{name="animal"}},
--     {'img', {imgId=kind, sx=0.5, sy=0.5, centerx=0.5, centery=0.5}}, 
--     {'pos', {}},
--     {'vel', {}},
--     {'body', {kind="animal", group=0, debugDraw=false}},
--   })
-- end
--
-- function Entities.floor(estore, res)
--   return estore:newEntity({
--     {'body', {kind="floor", group=0, debugDraw=false}},
--     {'pos', {x=512,y=798}},
--     {'vel', {}},
--   })
-- end
--
-- function Entities.quitButton(estore, res)
--   return estore:newEntity({
--     {'img', {imgId='power-button-outline', sx=0.25,sy=0.25,centerx=0.5, centery=0.5, color={1,1,1,0.25}}},
--     {'pos', {x=980,y=720}},
--     {'button', {eventtype='QUIT', holdTime=1, radius=40}},
--   })
-- end


return Entities
