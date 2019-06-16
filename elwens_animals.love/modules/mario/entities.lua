local Comps = require 'comps'
local Estore = require 'ecs.estore'
-- local AnimalEnts = require 'modules.animalscreen.entities'
local F = require 'modules.plotter.funcs'
local G = love.graphics
local Res = require 'modules.mario.resources'
local Scale = Res.Scale

local Entities={}

function Entities.initialEntities(res)
  local estore = Estore:new()

  Entities.background(estore)
  Entities.mario(estore)
  Entities.floor(estore)
  Entities.viewport(estore,res)

  -- local vp = Entities.viewport(estore)
  -- local bg = Entities.background(vp,res)
  -- Entities.map(vp)
  -- Entities.tracker(vp)
  --

  -- local ui = Entities.ui(estore,res)
	-- AnimalEnts.buttons(ui,res)

  return estore
end

local function verts_forRect(w,h)
  return {0,0, w,0, w,h, 0,h}
end
local function verts_forCorneredRect(w,h,s)
  local hs=s
  local vs=s
  return {hs,0, w-hs,0, w,vs, w,h-vs, w-hs,h, hs,h, 0,h-vs, 0,vs}
end

local function verts_move(verts,x,y)
  print(#verts)
  for i=1,#verts,2 do
    print("verts["..i.."]")
    verts[i] = verts[i] + x
    verts[i+1] = verts[i+1] + y
  end
end

function Entities.mario(parent,res)
  local w = 45
  local h = 80
  -- local verts = verts_forCorneredRect(w,h,10)
  local verts = verts_forRect(w,h)
  verts_move(verts, -w/2, -h/2)
  verts_move(verts, 0, 8)
  
  return parent:newEntity({
    {'name',{name="mario"}},
    {'mario',{mode="standing",facing="right"}},
    {'controller',{id="joystick1"}},
    {'anim', {name="mario", id="mario_big_stand_right", centerx=0.5, centery=0.5, drawbounds=false}}, 
    {'timer', {name="mario", countDown=false}},
    {'body', {fixedrotation=true, debugDraw=true, friction=0, debugDrawColor={1,.5,.5}}},
    -- {'rectangleShape', {x=0,y=8,w=45,h=80}},
    -- {'polygonShape', {vertices={0,0, 45,0, 45,80, 0,80}}},
    {'polygonShape', {vertices=verts}},
    {'force', {}},
    {'pos', {x=100,y=love.graphics.getHeight()-90}},
    {'vel', {}},

    {'viewportTarget', {offx=-love.graphics.getWidth()/2, offy=-love.graphics.getHeight()/2 - 000}},
  })
end

local BlockW = 16 * Scale
function newBlock(parent,opts)
  return parent:newEntity({
    {'body', {debugDraw=true,dynamic=false,friction=1}},
		{'rectangleShape', {w=BlockW,h=BlockW}},
    {'pos', {x=(opts.col*BlockW) + (BlockW/2),y=(opts.row*BlockW) + (BlockW/2)}},
  })
end

function emptyGrid(w,c)
end


function Entities.floor(estore,res)
  -- local floor =  estore:newEntity({
  --   {'name', {name="floor"}},
  --   {'tag', {name='floor'}},
  --   {'body', {debugDraw=true, dynamic=false,friction=1}},
	-- 	{'rectangleShape', {w=1024,h=50}},
  --   {'pos', {x=512,y=743}},
	-- })

  -- estore:newEntity({
  --   {'name', {name="block1"}},
  --   {'tag', {name='block'}},
  --   {'body', {debugDraw=true, dynamic=false,friction=1}},
	-- 	{'rectangleShape', {w=48,h=48}},
  --   {'pos', {x=512,y=600}},
	-- })
  -- estore:newEntity({
  --   {'name', {name="block2"}},
  --   {'tag', {name='block'}},
  --   {'body', {debugDraw=true, dynamic=false,friction=1}},
	-- 	{'rectangleShape', {w=48,h=48}},
  --   {'pos', {x=554,y=600}},
	-- })
  for c=0,20 do
    newBlock(estore, {row=15,col=c})
  end
  for c=16,20 do
    newBlock(estore, {row=14,col=c})
  end
  for c=17,20 do
    newBlock(estore, {row=13,col=c})
  end
  for c=10,12 do
    newBlock(estore, {row=12,col=c})
  end
  newBlock(estore, {row=9,col=11})

  return floor
end

-- function Entities.ui(parent,res)
--   return parent:newEntity({
--     {'name',{name="ui"}},
--   })
-- end

function Entities.viewport(estore)
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
