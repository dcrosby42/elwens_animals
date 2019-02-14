local Comps = require 'comps'
local Estore = require 'ecs.estore'
-- local AnimalEnts = require 'modules.animalscreen.entities'
local F = require 'modules.plotter.funcs'
local G = love.graphics

local Entities={}

function Entities.initialEntities(res)
  local estore = Estore:new()

  Entities.mario(estore)

  -- local vp = Entities.viewport(estore)
  -- local bg = Entities.background(vp,res)
  -- Entities.map(vp)
  -- Entities.tracker(vp)
  --

  -- local ui = Entities.ui(estore,res)
	-- AnimalEnts.buttons(ui,res)

  return estore
end

function Entities.mario(parent,res)
  return parent:newEntity({
    {'name',{name="mario"}},
    {'mario',{mode="standing",dir="right"}},
    {'controller',{id="joystick1"}},
    {'anim', {name="mario", id="mario_big_stand_right", offx=12, offy=32, drawbounds=false}}, 
    {'timer', {name="mario", countDown=false}},
    {'pos', {x=100,y=love.graphics.getHeight()-50}},
    {'vel', {}},
  })
end

-- function Entities.ui(parent,res)
--   return parent:newEntity({
--     {'name',{name="ui"}},
--   })
-- end

function Entities.viewport(estore,res)
  return estore:newEntity({
    {'name',{name="viewport"}},
    {'viewport',{x=0,y=0,sx=1,sy=1, w=G.getWidth(),h=G.getHeight()}},
  })
end

function Entities.tracker(parent,res)
  parent:newEntity({
    {'name',{name="tracker"}},
    {'viewportTarget', {offx=-love.graphics.getWidth()/2, offy=-love.graphics.getHeight()/2 - 000}},
    {'pos', {x=0,y=0}},
    -- {'vel', {dx=0,dy=0}},
  })
end


function Entities.background(estore,res)
  return estore:newEntity({
    {'name',{name="background"}},
    -- {'pic', {id='background1', sx=1, sy=1.05}}, -- zoo_keeper.png is 731px tall, we want to stretch it to 768
    {'pos', {}},
    -- {'sound', {sound='bgmusic',loop=true,duration=res.sounds.bgmusic.duration}},
    {'physicsWorld', {gy=9.8*64,allowSleep=false}},
  })
end


function Entities.map(parent,res)
  parent:newEntity({
    {'name',{name="map"}},
    {'map',{slices={}}},
  })
end

-- function Entities.slice(parent,res,num)
--   parent:newEntity({
--     {'name',{name="slice-"..num}},
--     {'slice',{number=num}},
--   })
-- end


return Entities
