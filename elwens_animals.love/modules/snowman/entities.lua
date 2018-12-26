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
  floor.pos.y = 793
  
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
  -- head:
  local ball3 = estore:newEntity({
    {'tag', {name='snowman_head'}},
    {'body', {kind="snowman_ball_3", group=0, debugDraw=false}},
    {'pic', {id="snowman_ball_1", sx=0.25, sy=0.25, centerx=0.5, centery=0.5}}, 
    {'pos', {x=600,y=400}},
    {'vel', {}},
    {'force', {}},
  })
  -- middle:
  local ball2 = estore:newEntity({
    {'tag', {name='snowman_body'}},
    {'body', {kind="snowman_ball_2", group=0, debugDraw=false}},
    {'pic', {id="snowman_ball_1", sx=0.43, sy=0.43, centerx=0.5, centery=0.5}}, 
    {'pos', {x=600,y=500}},
    {'vel', {}},
    {'force', {}},
    {'joint', {kind='snowman', to='snowman_head'}},
  })
  -- base:
  local ball1 = estore:newEntity({
    {'tag', {name='snowman_base'}},
    {'tag', {name='upright_snowman'}}, -- signals the "upright" system to operate on this object
    {'body', {kind="snowman_ball_1", group=0, debugDraw=false}},
    {'pic', {id="snowman_ball_1", sx=0.7, sy=0.7, centerx=0.5, centery=0.5}}, 
    {'pos', {x=600,y=600}},
    {'vel', {}},
    {'force', {}},
    {'joint', {kind='snowman', to='snowman_body'}},
  })

end

function Entities.box(estore, res)
  return estore:newEntity({
    {'tag', {name='box'}},
    -- {'pic', {id=kind, sx=0.5, sy=0.5, centerx=0.5, centery=0.5}}, 
    {'body', {kind="rect", name="box", group=0, debugDraw=true}},
    {'rect', {name="box", w=20,h=20,draw=false}},
    {'pos', {}},
    {'vel', {}},
    {'force', {}},
  })
end

return Entities
