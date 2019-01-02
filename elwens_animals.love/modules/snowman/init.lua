require 'ecs.ecshelpers'
local Debug = require('mydebug').sub("Snowman",true,true)
local Entities = require 'modules.snowman.entities'
local Resources = require 'modules.snowman.resources'
local SoundManager = require 'soundmanager'
local Snow = require 'modules.snowman.snow'
local DrawStuff = require 'systems.drawstuff'

DrawStuff.addPlugin(Snow.drawingPlugin)

local UPDATE = composeSystems({
  'systems.timer',
  'systems.selfdestruct',
  'systems.physics',
  'systems.sound',
  'systems.touchbutton',
  'modules.snowman.cannonsystem',
  'modules.snowman.upright',
})

local DRAW = composeDrawSystems({
  'systems.drawstuff',
  'systems.physicsdraw',
})

love.physics.setMeter(64) --the height of a meter our worlds will be 64px

local M = {}

function M.newWorld()
  local res = Resources.load()
  local world={
    estore = Entities.initialEntities(res),
    input = {
      dt=0,
      events={},
    },
    resources = res,
    soundmgr=SoundManager:new(),
  }
  return world
end

function M.stopWorld(w)
  w.soundmgr:clear()
end

local function resetInput(i) i.dt=0 i.events={} end

function M.updateWorld(w,action)
  local sidefx = nil
  if action.type == 'tick' then
    w.input.dt = action.dt
    UPDATE(w.estore, w.input, w.resources)
    sidefx = w.input.events -- return events as potential sidefx
    resetInput(w.input)

  elseif action.type == 'mouse' then
    local evt = shallowclone(action)
    evt.type = "touch"
    evt.id = 1
    table.insert(w.input.events, evt)

  elseif action.type == 'touch' or action.type == 'keyboard' then
    table.insert(w.input.events, shallowclone(action))

  end
  return w, sidefx
end


local G = love.graphics
local function drawPhysicsBody(body)
  G.setColor(1,1,1,1)
  -- G.setLineWidth(1)
  local fixtures = body:getFixtureList()
  for i=1,#fixtures do
    local fix = fixtures[i]
    local shape = fix:getShape()
    if shape:type() == "CircleShape" then
      local x,y = body:getWorldPoints(shape:getPoint())
      local r = shape:getRadius()
      G.circle("line", x,y,r)
      G.line(body:getWorldPoints(0,0,r,0))

    elseif shape:type() == "ChainShape" then
      G.line(body:getWorldPoints(shape:getPoints()))

    else
      G.polygon("line", body:getWorldPoints(shape:getPoints()))
    end
    local x,y = body:getWorldPoint(0,0)
    G.points(x,y)
    -- G.print(name,x+3,y-6)
  end
end
local function drawPhysicsBodies(list)
  if not list then return end
  for i=1,#list do
    drawPhysicsBody(list[i])
  end
end

function M.drawWorld(w)
  w.soundmgr:update(w.estore, nil, w.resources)
  DRAW(w.estore, w.resources)

  drawPhysicsBodies(w.bullets)
end

return M
