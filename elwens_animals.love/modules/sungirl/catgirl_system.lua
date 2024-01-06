local EventHelpers = require 'eventhelpers'
local Debug = require('mydebug').sub("CatGirl")
local Entities = require("modules.sungirl.entities")
local Vec = require 'vector-light'

-- TODO: dedup w puppygirl
local function applyNavControl(e, estore, input, res)
  local bufferZone = 20

  local speed = 10
  if e.speed then
    speed = e.speed.pps
  end

  local gx = e.nav_goal.x
  local gy = e.nav_goal.y
  -- vector from player to goal
  local dx, dy = Vec.sub(gx, gy, e.pos.x, e.pos.y)
  if Vec.len(dx,dy) > bufferZone then
    -- compute motion vector based on player speed
    e.vel.dx, e.vel.dy = Vec.mul(speed, Vec.normalize(dx, dy))
  else
    -- halt
    e.vel.dx, e.vel.dy = 0,0
  end
end

-- TODO: dedup w puppygirl
local function updateDir(e)
  -- Update facing left/right:
  if e.vel.dx < 0 then
    e.states.dir.value = "left"
  elseif e.vel.dx > 0 then
    e.states.dir.value = "right"
  end
end

-- TODO: dedup w puppygirl
local function applyMotion(e, estore, input, res)
  -- VELOCITY -> POSITION
  e.pos.x = e.pos.x + (input.dt * e.vel.dx)
  e.pos.y = e.pos.y + (input.dt * e.vel.dy)
end

local function applyPlayerControl(e, estore, input, res)
  local speed = 10
  if e.speed then
    speed = e.speed.pps
  end
  e.vel.dx = 0
  e.vel.dy = 0

  if e.player_control.right then
    e.vel.dx = e.vel.dx + speed
  end
  if e.player_control.left then
    e.vel.dx = e.vel.dx - speed
  end
end

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
  

--   -- MOVE
--   e.pos.x = e.pos.x + (input.dt * e.vel.dx)
--   e.pos.y = e.pos.y + (input.dt * e.vel.dy)
-- end

return defineUpdateSystem(hasTag('catgirl'),
  function(e, estore, input,res)
    -- TODO dedup w puppygirl:
    if e.nav_goal then
      applyNavControl(e,estore,input,res)
    elseif e.player_control and e.player_control.any then
      applyPlayerControl(e,estore,input,res)
    else
      e.vel.dx = 0
      e.vel.dy = 0
    end
    updateDir(e)
    
    e.vel.dy = 0
    applyMotion(e,estore,input,res)

    updateVisuals(e,estore,input,res)


    -- manageWaypoint(e,estore,input,res)

    -- handleNavigation(e,estore,input,res)


  end
)
