local EventHelpers = require 'eventhelpers'
local Debug = require('mydebug').sub("CatGirl")
local Entities = require("modules.sungirl.entities")
local C = require("modules.sungirl.common")
local Vec = require 'vector-light'

-- -- TODO: dedup w puppygirl
-- local function applyNavControl(e, estore, input, res)
--   local bufferZone = 20

--   local speed = 10
--   if e.speed then
--     speed = e.speed.pps
--   end

--   local gx = e.nav_goal.x
--   local gy = e.nav_goal.y
--   -- vector from player to goal
--   local dx, dy = Vec.sub(gx, gy, e.pos.x, e.pos.y)
--   if Vec.len(dx,dy) > bufferZone then
--     -- compute motion vector based on player speed
--     e.vel.dx, e.vel.dy = Vec.mul(speed, Vec.normalize(dx, dy))
--   else
--     -- halt
--     e.vel.dx, e.vel.dy = 0,0
--   end
-- end

local function updateVisuals(e, estore, input, res)
  -- SELECT ANIM
  local anim = e.anims.catgirl
  if e.vel.dx == 0 then
    anim.id = "sungirl_stand"
  else
    anim.id = "sungirl_run"
  end
  if e.vel.dx < 0 then
    e.states.dir.value = "left"
  else
    e.states.dir.value = "right"
  end

  -- ORIENT
  if e.states.dir.value == "left" then
    if anim.sx > 0 then
      anim.sx = -1 * anim.sx
    end
  else
    if anim.sx < 0 then
      anim.sx = -1 * anim.sx
    end
  end
end


-- use bounds and pos to detect overlap of entities
local function entitiesIntersect(e1,e2)
  if e1.bounds and e2.bounds and e1.pos and e2.pos then
    return math.rectanglesintersect(
      e1.pos.x - e1.bounds.offx, e1.pos.y - e1.bounds.offy, e1.bounds.w, e1.bounds.h,
      e2.pos.x - e2.bounds.offx, e2.pos.y - e2.bounds.offy, e2.bounds.w, e2.bounds.h)
  end
end

local function doPickups(myEnt, estore, res)
  local hits = findEntities(estore, function(e)
    return e.item and e.eid ~= myEnt.eid and entitiesIntersect(myEnt,e)
  end)
  for _, e in ipairs(hits) do
    print("pickup: "..e.item.kind)
    estore:transferComp(e, myEnt, e.item)
    estore:destroyEntity(e)
  end
  if #hits > 0 then
    C.addSoundComp(myEnt, "pickup_item", res)
    print("I've got "..tcount(myEnt.items).." items")
  end
end


return defineUpdateSystem(hasTag('catgirl'),
  function(e, estore, input,res)

    if e.touch and e.touch.state == "pressed" then
      C.assignAsPlayer(e, estore)
    end

    C.applyTouchNav(e)

    if e.nav_goal then
      -- applyNavControl(e,estore,input,res)
      C.accelTowardNavGoal(e)

    elseif e.player_control and e.player_control.any then
      C.applyPlayerControls(e, {vertical=false})
    else
      C.stopMoving(e)
    end

    C.updateLRDirFromVel(e)

    C.applyMotion(e,input, {vertical=false})

    doPickups(e, estore, res)

    updateVisuals(e,estore,input,res)

  end
)
