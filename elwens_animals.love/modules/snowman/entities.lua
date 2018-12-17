local Comps = require 'comps'
local Estore = require 'ecs.estore'
local AnimalEnts = require 'modules.animalscreen.entities'
local Snow = require 'modules.christmas.snow'

local Entities={}

function Entities.initialEntities(res)
  local estore = Estore:new()

  Entities.scene(estore,res)

  AnimalEnts.nextModeButton(estore,res)
  AnimalEnts.quitButton(estore,res)

  local floor = AnimalEnts.floor(estore,res)
  floor.pos.y = 750
  
  return estore
end

function Entities.scene(estore,res)
  local bubbleInt = 0.3
  local scene = estore:newEntity({
    {'pic', {id='woodsbg', sx=1, sy=1}}, 
    {'pos', {}},
    -- {'sound', {sound='bgmusic', loop=true, duration=res.sounds.bgmusic.duration}},
    {'physicsWorld', {gy=9.8*64,allowSleep=false}},
  })
  
  -- Snow.newSnowMachine(estore, {large=2, small=1, dy=15,dx=-5})
  -- Snow.newSnowMachine(estore, {large=3, small=1, dy=30,dx=-10})
  -- Snow.newSnowMachine(estore, {large=5, small=3, dy=60,dx=-20})

  Snow.newSnowMachine(estore, {interval=0.1, large=2, small=1, dy=30,dx=-10})
  Snow.newSnowMachine(estore, {interval=0.1,large=3, small=1, dy=60,dx=-20})
  Snow.newSnowMachine(estore, {interval=0.1, large=5, small=3, dy=120,dx=-40})

  return scene
end

function Entities.ornament(estore, res, kind)
  return estore:newEntity({
    {'tag',{name="ornament"}},
    {'pic', {id=kind, sx=0.5, sy=0.5, centerx=0.5, centery=0.5}}, 
    {'pos', {}},
    {'vel', {}},
    {'body', {kind="animal", group=0, debugDraw=false}},
  })
end

return Entities
