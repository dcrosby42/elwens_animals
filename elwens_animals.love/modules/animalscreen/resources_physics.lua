local P = love.physics

local M = {}

local function newAnimal(w,e)
  local b = P.newBody(w,0,0,"dynamic")
  b:setMass(0.1)
  local s = P.newCircleShape(50)
  local f = P.newFixture(b,s)
  f:setUserData(e.body.cid)
  return {body=b, shapes={s}, fixtures={f}, componentId=cid} 
end

local function newFloor(w,e)
  local b = P.newBody(w,0,0,"static")
  local s = P.newRectangleShape(1024,50)
  local f = P.newFixture(b,s)
  f:setUserData(e.body.cid)
  return {body=b, shapes={s}, fixtures={f}, componentId=cid} 
end

-- (physicsWorld, entity) -> { body, shapes, fixtures }
function M.newObject(w, e)
  if e == nil or e.body == nil then
    error("newObject requires an entity with a body component")
  end

  if e.body.kind == "animal" then
    return newAnimal(w,e)

  elseif e.body.kind == "floor" then
    return newFloor(w,e)

  else
    error("newObject doesn't know how to build a phyics objcet for kind '"..e.body.kind.."'")
  end
end

return M
