local P = love.physics
local Debug=require('mydebug').sub("SnowmanPhysicsResources",true,true)
local AnimalPhys = require 'modules.animalscreen.resources_physics'

local M = {}

local BubbleRadius=40
local function newBubble(pw,e)
  local b = P.newBody(pw,0,0,"dynamic")
  b:setMass(0.01)

  local scale = 1
  if e.pic and e.pic.sx ~= 1 then
    scale = e.pic.sx
  elseif e.anim and e.anim.sx ~= 1 then
    scale = e.anim.sx
  end
  local rad = BubbleRadius * scale
  local s = P.newCircleShape(rad)

  local f = P.newFixture(b,s)
  f:setUserData(e.body.cid)
  return {body=b, shapes={s}, fixtures={f}}
end

local function newSnowball(pw,e,r)
  local b = P.newBody(pw,400,500,"dynamic") -- FIXME pos?
  local s = P.newCircleShape(r)
  local f = P.newFixture(b,s)
  f:setUserData(e.body.cid)
  return {body=b, shapes={s}, fixtures={f}}
end

local function newGeneric(pw,e)
  if not (e.rectangleShape or e.polygonShape or e.circleShape) then
    error("newGeneric() requires the Entity have rectangleShape, polygonShape or circleShape component(s)")
  end
  local x,y = getPos(e)
  local dyn = "dynamic"
  if not e.body.dynamic then dyn="static" end
  local b = P.newBody(pw,x,y,dyn)
  b:setBullet(e.body.bullet)

  local shapes={}
  local fixtures={}

  local function addShape(s) 
    local f = P.newFixture(b,s)
    f:setUserData(e.body.cid)
    table.insert(shapes,s)
    table.insert(fixtures,f)
  end

  for _,r in pairs(e.rectangleShapes or {}) do
    local s = P.newRectangleShape(r.x,r.y, r.w,r.h, r.angle)
    addShape(s)
  end
  for _,poly in pairs(e.polygonShapes or {}) do
    local s = P.newPolygonShape(poly.vertices)
    addShape(s)
  end
  for _,c in pairs(e.circleShapes or {}) do
    local s = P.newCircleShape(c.x,c.y, c.radius)
    addShape(s)
  end

  if type(e.body.mass) == "number" then
    b:setMass(e.body.mass)
  end

  return {body=b, shapes=shapes, fixtures=fixtures}
end

-- (physicsWorld, entity) -> { body, shapes, fixtures }
function M.newObject(pw, e)
  if e == nil or e.body == nil then
    error("newObject requires an entity with a body component")
  end

  if e.body.kind == '' or e.body.kind == 'generic'  then
    return newGeneric(pw, e)

  elseif e.body.kind == "snowman_ball_1" then
    return newSnowball(pw,e, 80)

  elseif e.body.kind == "snowman_ball_2" then
    return newSnowball(pw,e, 50)

  elseif e.body.kind == "snowman_ball_3" then
    return newSnowball(pw,e, 25)

  else
    return AnimalPhys.newObject(pw,e)
    -- error("newObject doesn't know how to build a phyics objcet for kind '"..e.body.kind.."'")
  end
end

function M.newJoint(pw, jointComp, e, estore, objCache)
  if e == nil or jointComp == nil then
    error("newJoint requires an entity with a joint component")
  end
  Debug.println("jointComp: "..tflatten(jointComp))

  local fromComp = e.body
  Debug.println("fromComp: "..tflatten(fromComp))

  local toEnt, toComp
  estore:seekEntity(hasTag(jointComp.to), function(e) 
    toEnt = e
    toComp = e.body
    return true
  end)
  Debug.println("toComp: "..tflatten(toComp))

  local from = objCache[fromComp.cid]
  local to = objCache[toComp.cid]

  local fromCenterX = from.body:getX()
  local fromCenterY = from.body:getY()
  local toCenterX = to.body:getX()
  local toCenterY = to.body:getY()
  Debug.println("fromCenterX="..fromCenterX.." fromCenterY="..fromCenterY)
  Debug.println("toCenterX="..toCenterX.." toCenterY="..toCenterY)
  local vx = toCenterX - fromCenterX
  local vy = toCenterY - fromCenterY
  
  local joint = P.newPrismaticJoint(
    from.body,
    to.body,
    fromCenterX,fromCenterY,
    toCenterX,toCenterY,
    vx,vy,
    fromComp.docollide
  )
  if jointComp.upperlimit ~= '' and jointComp.lowerlimit ~= '' then
    joint:setLimits(jointComp.lowerlimit, jointComp.upperlimit)
  end
  if jointComp.motorspeed ~= '' and jointComp.maxmotorforce ~= '' then
    joint:setMotorEnabled(true)
    joint:setMotorSpeed(jointComp.motorspeed) -- -1000
    joint:setMaxMotorForce(jointComp.maxmotorforce) -- 1000
  end
  return {joint=joint}
end

return M
