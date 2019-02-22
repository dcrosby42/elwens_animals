local Comps = require 'comps'
local Estore = require 'ecs.estore'
-- local AnimalEnts = require 'modules.animalscreen.entities'
local F = require 'modules.plotter.funcs'
local G = love.graphics

local Entities={}

function Entities.initialEntities(res)
  local estore = Estore:new()

  Entities.background(estore)
  Entities.mario(estore)
  Entities.floor(estore)

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
    {'mario',{mode="standing",facing="right"}},
    {'controller',{id="joystick1"}},
    {'anim', {name="mario", id="mario_big_stand_right", centerx=0.5, centery=0.5, drawbounds=false}}, 
    {'timer', {name="mario", countDown=false}},
    {'pos', {x=100,y=love.graphics.getHeight()-50}},
    -- {'pos', {x=100,y=}},
    {'vel', {}},
    {'body', {fixedrotation=true, debugDraw=false, friction=0, debugDrawColor={1,.5,.5}}},
    {'force', {}},
    {'rectangleShape', {x=0,y=8,w=45,h=80}},
  })
end

function Entities.floor(estore,res)
  return estore:newEntity({
    {'name', {name="floor"}},
    {'tag', {name='floor'}},
    {'body', {debugDraw=true, dynamic=false,friction=1}},
		{'rectangleShape', {w=1024,h=50}},
    {'pos', {x=512,y=743}},
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
