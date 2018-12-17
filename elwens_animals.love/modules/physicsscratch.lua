local Debug = require('mydebug').sub("PhysScratch",true,true)
local GC= require 'garbagecollect'
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
  w.bulletCount = 0
  w.objects = {}
  w.joints = {}
  
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
    Debug.println("ball1 mass: "..b:getMass())
  end
  do
    local b = P.newBody(phw,400,400,"dynamic")
    local s = P.newCircleShape(50)
    local f = P.newFixture(b,s)
    f:setUserData("ball2")
    w.objects.ball2={"ball2",b,{s},{f}}
    Debug.println("ball2 mass: "..b:getMass())
  end
  do
    local b = P.newBody(phw,400,300,"dynamic")
    local s = P.newCircleShape(25)
    local f = P.newFixture(b,s)
    f:setUserData("ball3")
    w.objects.ball3={"ball3",b,{s},{f}}
    Debug.println("ball3 mass: "..b:getMass())
  end

  do
    local joint = P.newPrismaticJoint(
      w.objects.ball1[2],
      w.objects.ball2[2],
      400, 500,
      400, 400,
      0,-1,
      false
    )
    joint:setLimits(120,140)
    joint:setMotorEnabled(true)
    -- joint:setMotorSpeed(-1000)
    joint:setMotorSpeed(-1000)
    joint:setMaxMotorForce(1000)
    Debug.println("joint limits enabled"..tostring(joint:areLimitsEnabled()))
    local lower, upper  = joint:getLimits()
    Debug.println(" lower="..lower.." upper="..upper)
    Debug.println("joint motor enabled"..tostring(joint:isMotorEnabled()))
    w.joints.rail1 = joint
  end

  do
    local joint = P.newPrismaticJoint(
      w.objects.ball2[2],
      w.objects.ball3[2],
      400, 400,
      400, 300,
      0,-1,
      false
    )
    joint:setLimits(65,85)
    joint:setMotorEnabled(true)
    -- joint:setMotorSpeed(-1000)
    joint:setMotorSpeed(-1000)
    joint:setMaxMotorForce(1000)
    w.joints.rail2 = joint
  end

    

  do
    local b = P.newBody(phw,800,600,"dynamic")
    local s = P.newRectangleShape(60,150)
    local f = P.newFixture(b,s)
    f:setUserData("box1")
    w.objects.box1={"box1",b,{s},{f}}
  end
  do
    local b = P.newBody(phw,15,600,"dynamic")
    local s = P.newRectangleShape(60,150)
    local f = P.newFixture(b,s)
    f:setUserData("box2")
    w.objects.box2={"box2",b,{s},{f}}
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

local function fireBullet(w, x,y, vx,vy)
  local s = 20
  local power = 1000
  local b = P.newBody(w.physicsWorld,x,y,"dynamic")
  local sh = P.newRectangleShape(s,s)
  local f = P.newFixture(b,sh)
  f:setUserData("bullet")
  w.bulletCount = w.bulletCount + 1
  local name = "bullet"..w.bulletCount
  w.objects[name]={name,b,{sh},{f}}
  b:setMass(1)
  b:setBullet(true)
  b:setLinearVelocity(vx*power,vy*power)

end

local function uprightSnowman(w)
  _,body,_,_ = unpack(w.objects.ball1)
  local ta = 0
  local a = body:getAngle()
  local diff = a-ta
  local sign=1
  if diff == 0 then 
    return
  elseif math.abs(diff) < 0.01 and body:getAngularVelocity() < 0.01 then
    body:setAngle(ta)
    body:setAngularVelocity(0)
    return
  elseif diff < 0 then
    sign = -1
  end
  -- local f = -sign * 100000
  local f = -sign * (math.pow(math.abs(diff),0.5) * 500000)
  -- print("diff="..diff.." sign="..sign.." force="..f)
  body:applyTorque(f)
end

function M.updateWorld(w,action,res)
  if action.type == "tick" then
    if w.joints.MJ then
      w.joints.MJ:setTarget(love.mouse.getPosition())
    end

    uprightSnowman(w)

    w.physicsWorld:update(action.dt)

    GC.request()
    GC.ifNeeded(action.dt)

  elseif action.type == "mouse" then
    if action.state == "pressed" and action.button == 1 then
      local x = action.x
      local y = action.y
      pickFixtures(w.objects, x,y, function(f)
        Debug.println("Clicked: "..f:getUserData())
        local b = f:getBody()
        w.joints.MJ = P.newMouseJoint(b,x,y)
        return true
      end)
    elseif action.state == "released" and action.button == 1 then
      if w.joints.MJ then
        Debug.println("Letting go")
        w.joints.MJ:destroy()
        w.joints.MJ = nil
        collectgarbage()
      end
    end
  elseif action.type == "keyboard" then
    if action.state == "pressed" then
      if action.key == "d" then
        local x,y = love.mouse.getPosition()
        fireBullet(w,x,y,1,-0.2)
      elseif action.key == "a" then
        local x,y = love.mouse.getPosition()
        fireBullet(w,x,y,-1,0)
      elseif action.key == "w" then
        local x,y = love.mouse.getPosition()
        fireBullet(w,x,y,0,-1)
      elseif action.key == "s" then
        local x,y = love.mouse.getPosition()
        fireBullet(w,x,y,0,1)
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

local function drawJoint(joint)
  -- local x1,y1, x2,y2 = joint:getAnchors()
  love.graphics.setColor(0,0,1)
  love.graphics.line(joint:getAnchors())
  -- Debug.println(""..x1..","..y1.."    "..x2..","..y2)

end

function M.drawWorld(w)
  love.graphics.setBackgroundColor(0,0,0,1)
  for _,obj in pairs(w.objects) do
    drawObject(unpack(obj))
  end
  for _,j in pairs(w.joints) do
    drawJoint(j)
  end
  love.graphics.setColor(1,1,1)

  do 
    -- local a = w.objects.ball1[2]:getAngle()
    local a = w.objects.ball1[2]:getAngularVelocity()
    love.graphics.print("angle: "..a,0,0)
  end
end

return M

