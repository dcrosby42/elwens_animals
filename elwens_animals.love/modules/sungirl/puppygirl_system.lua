local EventHelpers = require 'eventhelpers'
local Debug = require('mydebug').sub("PuppyGirl")
local Entities = require("modules.sungirl.entities")
local Vec = require 'vector-light'

local SHOW_TOUCH = true

-- TODO: dedup w catgirl
-- 
local function applyNavControl(e, estore, input, res)
  local bufferZone = 10

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

local function applyPlayerControl(e, estore, input, res)
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
local function updateDir(e)
  -- Update facing left/right:
  if e.vel.dx < 0 then
    e.states.dir.value = "left"
  elseif e.vel.dx > 0 then
    e.states.dir.value = "right"
  end
end

local function updateAnim(e)
  -- SELECT ANIM
  local anim = e.anims.sungirl
  if e.vel.dx == 0 then
    anim.id = "sungirl_stand"
  else
    anim.id = "sungirl_run"
  end

  -- Flip left/right?
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

  -- SELECT ANIM
  -- local anim = e.anims.sungirl
  -- if e.vel.dx == 0 then
  --   anim.id = "sungirl_stand"
  -- else
  --   anim.id = "sungirl_run"
  -- end
  -- if e.vel.dx < 0 then
  --   e.states.dir.value = "left"
  -- else
  --   e.states.dir.value = "right"
  -- end

  -- ORIENT
  -- if e.states.dir.value == "left" then
  --   if anim.sx > 0 then
  --     anim.sx = -1 * anim.sx
  --   end
  -- else
  --   if anim.sx < 0 then
  --     anim.sx = -1 * anim.sx
  --   end
  -- end

-- local function setNavGoal(e,estore,x,y)
--   local x, y = screenXYToViewport(Entities.getViewport(estore), x, y)
--   if not e.nav_goal then
--     e:newComp('nav_goal', { x = x, y = y })
--   else
--     e.nav_goal.x = x
--     e.nav_goal.y = y
--   end
-- end

local function applyTouchNav(e,estore,input,res)
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
    if #input.events > 1 then
      if lcontains(input.events, function(evt) return evt.type == "touch" and evt.state=="pressed" end) then
        msg = table.concat(lmap(input.events, function(evt) return evt.type .."."..evt.state end), ", ")
        Debug.println("Multi event ("..#input.events.."): "..msg)
        -- for _,evt in ipairs(input.events) do
        --   Debug.println(tdebug1(evt))
        -- end
        -- Debug.println("---")
      end
    end

    applyTouchNav(e,estore,input,res)

    if e.nav_goal then
      applyNavControl(e,estore,input,res)
    elseif e.player_control and e.player_control.any then
      applyPlayerControl(e,estore,input,res)
    -- elseif e.touch then
      -- applyDpadControl(e,estore,input,res)
    else
      e.vel.dx = 0
      e.vel.dy = 0
    
    end


    updateDir(e)
    applyMotion(e, input)
    -- updateAnim(e)

    -- manageWaypoint(e,estore,input,res)



  end
)
