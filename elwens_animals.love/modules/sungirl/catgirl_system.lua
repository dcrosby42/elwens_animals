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

    updateVisuals(e,estore,input,res)

  end
)
