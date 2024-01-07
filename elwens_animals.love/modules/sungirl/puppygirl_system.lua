local EventHelpers = require 'eventhelpers'
local Debug = require('mydebug').sub("PuppyGirl")
local Entities = require("modules.sungirl.entities")
local Vec = require 'vector-light'

local SHOW_TOUCH = false

-- TODO: dedup w catgirl
-- 
local function moveTowardNavGoal(e, estore, input, res)
  local startThreshold = 50
  local stopThreshold = 10

  local speed = 10
  if e.speed then
    speed = e.speed.pps
  end

  local gx = e.nav_goal.x
  local gy = e.nav_goal.y
  -- vector from player to goal
  local dx, dy = Vec.sub(gx, gy, e.pos.x, e.pos.y)
  local dist = Vec.len(dx,dy)

  if e.vel.dx == 0 and e.vel.dy == 0 then
    if dist > startThreshold then
      -- compute motion vector based on player speed
      e.vel.dx, e.vel.dy = Vec.mul(speed, Vec.normalize(dx, dy))
    end
  else
    if dist < stopThreshold then
      -- halt
      e.vel.dx, e.vel.dy = 0,0
    else
      e.vel.dx, e.vel.dy = Vec.mul(speed, Vec.normalize(dx, dy))
    end
  end
end

local function applyPlayerControls(e, estore, input, res)
  local speed = 10
  if e.speed then
    speed = e.speed.pps
  end
  
  -- CONTROLS -> VELOCITY
  if e.player_control.right then
    e.vel.dx = speed
  end
  if e.player_control.left then
    e.vel.dx = -speed
  end
  if e.player_control.up then
    e.vel.dy = -speed
  end
  if e.player_control.down then
    e.vel.dy = speed
  end
end


-- TODO: dedup w catgirl
local function applyMotion(e,  input)
  -- VELOCITY -> POSITION
  e.pos.x = e.pos.x + (input.dt * e.vel.dx)
  e.pos.y = e.pos.y + (input.dt * e.vel.dy)
end

-- TODO: dedup w catgirl
local function updateDir(e, estore)
  if e.vel.dx == 0 and e.vel.dy == 0 then
    local catgirl = Entities.getCatgirl(estore)
    if e.pos.x < catgirl.pos.x then
      e.states.dir.value = "right"
    else
      e.states.dir.value = "left"
    end
  else
    -- Update facing left/right:
    if e.vel.dx < 0 then
      e.states.dir.value = "left"
    elseif e.vel.dx > 0 then
      e.states.dir.value = "right"
    end
  end
end

local function updateVisuals(e)
  -- determine pic:
  local hflip = 1
  if e.vel.dx == 0 and e.vel.dy == 0 then
    e.pic.id = "puppygirl-idle-left"
    hflip = -1
  else
    if math.abs(e.vel.dx) > math.abs(e.vel.dy) then
      -- horizontal
      e.pic.id = "puppygirl-fly-left"
      hflip = -1 -- (the dir handler below assumes pics face right)
    else
      -- vertical
      if e.vel.dy < 0 then
        -- up
        -- e.pic.id = "puppygirl-rise-right"
        e.pic.id = "puppygirl-idle-left"
        hflip = -1
      else
        -- down
        -- e.pic.id = "puppygirl-descend-left"
        -- hflip = -1 -- (the dir handler below assumes pics face right)
        e.pic.id = "puppygirl-idle-left"
        hflip = -1
      end
    end
  end

  -- apply left/right dir:
  if e.states.dir.value == "right" then
    e.pic.sx = math.abs(e.pic.sx) * hflip
  else
    e.pic.sx = -1 * math.abs(e.pic.sx) * hflip
  end
end

local function handleTouch(e,estore,input,res)
  if e.touch then
    if e.touch.state == "pressed" then
      local t = e.touch
      e:newComp('nav_goal', {x=t.lastx, y=t.lasty})

      if SHOW_TOUCH then
        local offx, offy = (t.lastx - e.pos.x), (t.lasty - e.pos.y)
        e:newComp('circle', {
          name = 'dot',
          offx = offx,
          offy = offy,
          radius = 20,
          fill = true,
          color = { 1, 1, 1, 0.5 }
        })
      end

    elseif e.touch.state == "released" then
      if e.nav_goal then 
        e:removeComp(e.nav_goal)
      end
      if SHOW_TOUCH and e.circle then 
        e:removeComp(e.circle)
      end
    else
      local t = e.touch
      if e.nav_goal then
        e.nav_goal.x, e.nav_goal.y = t.lastx, t.lasty
      end
      if SHOW_TOUCH and e.circle then
        e.circle.offx, e.circle.offy = (t.lastx - e.pos.x), (t.lasty - e.pos.y)
      end
    end
  end
end

return defineUpdateSystem(hasTag('puppygirl'),
  function(e, estore, input,res)

    -- (maybe) add/move nav_goal
    handleTouch(e,estore,input,res)

    if e.nav_goal then
      moveTowardNavGoal(e,estore,input,res)

    elseif e.player_control and e.player_control.any then
      -- devel/debug manual keybd controls:
      applyPlayerControls(e,estore,input,res)
      
    else
      -- halt:
      e.vel.dx = 0
      e.vel.dy = 0
    end


    updateDir(e, estore)
    applyMotion(e, input)
    updateVisuals(e)

    -- manageWaypoint(e,estore,input,res)



  end
)
