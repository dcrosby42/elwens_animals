local Debug = require('mydebug').sub("PhysScratch",true,true)
local R = require 'resourceloader'
local A = require 'animalpics'
local P = love.physics
local M={}

function M.newWorld()
  love.physics.setMeter(64)

  local w = {}
    -- {'pos', {x=512,y=798}},
  -- f:setUserData(e.body.cid)
  -- return {body=b, shapes={s}, fixtures={f}, componentId=cid} 

  local phw = love.physics.newWorld(0, 9.81*64, true)
  w.physicsWorld = phw
  w.objects = {}
  
  -- floor
  do
    local b = P.newBody(phw,512,700,"static")
    local s = P.newRectangleShape(1024,50)
    local f = P.newFixture(b,s)
    f:setUserData("floor")
    w.objects.floor={"floor",b,{s},{f}}
  end

  do
    local b = P.newBody(phw,400,500,"dynamic")
    local s = P.newCircleShape(80)
    local f = P.newFixture(b,s)
    f:setUserData("ball1")
    w.objects.ball1={"ball1",b,{s},{f}}
  end
  do
    local b = P.newBody(phw,400,400,"dynamic")
    local s = P.newCircleShape(50)
    local f = P.newFixture(b,s)
    f:setUserData("ball2")
    w.objects.ball2={"ball2",b,{s},{f}}
  end


  return w
end

local function pickFixtures(objs,x,y,fn)
  for _,obj in pairs(objs) do
    local fixtures = obj[4]
    for i=1,#fixtures do
      local f = fixtures[i]
      if f:testPoint(x,y) then
        local r = fn(f)
        if r == true then
          return
        end
      end
    end
  end
end

local MJ

function M.updateWorld(w,action,res)
  if action.type == "tick" then
    if MJ then
      MJ:setTarget(love.mouse.getPosition())
    end
    w.physicsWorld:update(action.dt)


  elseif action.type == "mouse" then
    if action.state == "pressed" and action.button == 1 then
      local x = action.x
      local y = action.y
      pickFixtures(w.objects, x,y, function(f)
        Debug.println("Clicked: "..f:getUserData())
        local b = f:getBody()
        MJ = P.newMouseJoint(b,x,y)
        return true
      end)
    elseif action.state == "released" and action.button == 1 then
      if MJ then
        Debug.println("Letting go")
        MJ:destroy()
        MJ = nil
        collectgarbage()
      end
    end
  end
  return w
end

local function drawObject(name,body,shapes,fixtures)
  love.graphics.setColor(1,1,1,1)
  love.graphics.setLineWidth(1)
  for i=1,#shapes do
    local shape = shapes[i]
    if shape:type() == "CircleShape" then
      local x,y = body:getWorldPoints(shape:getPoint())
      local r = shape:getRadius()
      love.graphics.circle("line", x,y,r)
      love.graphics.line(body:getWorldPoints(0,0,r,0))

    elseif shape:type() == "ChainShape" then
      love.graphics.line(body:getWorldPoints(shape:getPoints()))

    else
      love.graphics.polygon("line", body:getWorldPoints(shape:getPoints()))
    end
    local x,y = body:getWorldPoint(0,0)
    love.graphics.points(x,y)
    love.graphics.print(name,x+3,y-6)
  end
end

function M.drawWorld(w)
  love.graphics.setBackgroundColor(0,0,0,1)
  for _,obj in pairs(w.objects) do
    drawObject(unpack(obj))
  end
end

return M

