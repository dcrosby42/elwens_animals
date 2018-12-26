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
  local b = P.newBody(pw,400,500,"dynamic")
  local s = P.newCircleShape(r)
  local f = P.newFixture(b,s)
  f:setUserData(e.body.cid)
  return {body=b, shapes={s}, fixtures={f}}
end

-- (physicsWorld, entity) -> { body, shapes, fixtures }
function M.newObject(pw, e)
  if e == nil or e.body == nil then
    error("newObject requires an entity with a body component")
  end

  if e.body.kind == "snowman_ball_1" then
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
  local doCollide=false
  local lower
  local upper

  -- FIXME this is TOTALLY JANK!! 
  if fromComp.kind == "snowman_ball_1" then
    lower=120
    upper=140
  else -- snoman_ball_2 (body) connecting to snowman_ball_3 (head)
    lower=65
    upper=85
  end
  
  local joint = P.newPrismaticJoint(
    from.body,
    to.body,
    fromCenterX,fromCenterY,
    toCenterX,toCenterY,
    vx,vy,
    doCollide
  )
  joint:setLimits(lower,upper)
  joint:setMotorEnabled(true)
  joint:setMotorSpeed(-1000)
  joint:setMaxMotorForce(1000)
  return {joint=joint}
end

return M
