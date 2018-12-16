local P = love.physics

local AnimalPhys = require 'modules.animalscreen.resources_physics'

local M = {}

-- local function newAnimal(w,e)
--   local b = P.newBody(w,0,0,"dynamic")
--   b:setMass(0.1)
--   local s = P.newCircleShape(50)
--   local f = P.newFixture(b,s)
--   f:setUserData(e.body.cid)
--   return {body=b, shapes={s}, fixtures={f}, componentId=cid} 
-- end
--
-- local function newFloor(w,e)
--   local b = P.newBody(w,0,0,"static")
--   local s = P.newRectangleShape(1024,50)
--   local f = P.newFixture(b,s)
--   f:setUserData(e.body.cid)
--   return {body=b, shapes={s}, fixtures={f}, componentId=cid} 
-- end
--

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
  return {body=b, shapes={s}, fixtures={f}, componentId=cid} 
end

-- (physicsWorld, entity) -> { body, shapes, fixtures }
function M.newObject(pw, e)
  if e == nil or e.body == nil then
    error("newObject requires an entity with a body component")
  end

  if e.body.kind == "bubble" then
    return newBubble(pw,e)

  else
    return AnimalPhys.newObject(pw,e)
    -- error("newObject doesn't know how to build a phyics objcet for kind '"..e.body.kind.."'")
  end
end

return M
