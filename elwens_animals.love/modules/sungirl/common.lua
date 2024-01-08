local Debug = require('mydebug').sub('Common', true)
local Vec = require 'vector-light'

local C = {}



function C.removePlayerTag(e)
  if e.tags.player then
    e:removeComp(e.tags.player)
  end
end

function C.addPlayerTag(e)
  if not e.tags.player then
    e:newComp('tag', { name = 'player' })
  end
end

function C.resetPLayerControls(e)
  for _, attr in ipairs({ 'left', 'right', 'up', 'down', 'jump' }) do
    e.player_control[attr] = false
  end
end

function C.swapOrder(e1, e2)
  -- Debug.println("swapOrder\n" .. tdebug(e1.parent) .. "\n" .. tdebug(e2.parent))
  local o1 = e1.parent.order
  local o2 = e2.parent.order
  e1.parent.order = o2
  e2.parent.order = o1
end

function C.swapPlayers(estore)
  local puppygirl = findEntity(estore, hasTag("puppygirl"))
  local catgirl = findEntity(estore, hasTag("catgirl"))

  C.resetPLayerControls(puppygirl)
  C.resetPLayerControls(catgirl)

  if puppygirl.tags.player then
    C.removePlayerTag(puppygirl)
    C.addPlayerTag(catgirl)
    C.swapOrder(catgirl, puppygirl)
    Debug.println('controlling catgirl')
  elseif catgirl.tags.player then
    C.removePlayerTag(catgirl)
    C.addPlayerTag(puppygirl)
    C.swapOrder(catgirl, puppygirl)
    Debug.println('controlling puppygirl')
  end

  local parentE = estore:getEntity(catgirl.parent.parentEid)
  parentE:resortChildren()
end

function C.applyMotion(e, input, opts)
  if not opts then opts = {} end
  if opts.horizontal == nil then opts.horizontal = true end
  if opts.vertical == nil then opts.vertical = true end

  -- VELOCITY -> POSITION
  if opts.horizontal then
    e.pos.x = e.pos.x + (input.dt * e.vel.dx)
  end
  if opts.vertical then
    e.pos.y = e.pos.y + (input.dt * e.vel.dy)
  end
end


function C.accelTowardNavGoal(e)
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

function C.stopMoving(e)
  e.vel.dx = 0
  e.vel.dy = 0
end

function C.isMoving(e)
  return e.vel and (e.vel.dx ~= 0 or e.vel.dy ~= 0)
end

function C.isMovingMoreHorizontal(e)
  return C.isMoving(e) and math.abs(e.vel.dx) >= math.abs(e.vel.dy)
end

function C.isMovingMoreVertical(e)
  return C.isMoving(e) and math.abs(e.vel.dy) > math.abs(e.vel.dx)
end

function C.updateLRDirFromVel(e)
  if e.vel and e.states and e.states.dir then
    -- Update facing left/right:
    if e.vel.dx < 0 then
      e.states.dir.value = "left"
    elseif e.vel.dx > 0 then
      e.states.dir.value = "right"
    end
  end
end

function C.applyPlayerControls(e, opts)
  if not opts then opts = {} end
  if opts.horizontal == nil then opts.horizontal = true end
  if opts.vertical == nil then opts.vertical = true end

  local speed = 10
  if e.speed then
    speed = e.speed.pps
  end

  -- CONTROLS -> VELOCITY
  if opts.horizontal then
    if e.player_control.right then
      e.vel.dx = speed
    end
    if e.player_control.left then
      e.vel.dx = -speed
    end
  end
  if opts.vertical then
    if e.player_control.up then
      e.vel.dy = -speed
    end
    if e.player_control.down then
      e.vel.dy = speed
    end
  end
end

local SHOW_TOUCH_NAV = false

function C.applyTouchNav(e)
  if e.touch then
    if e.touch.state == "pressed" then
      local t = e.touch
      e:newComp('nav_goal', {x=t.lastx, y=t.lasty})

      if SHOW_TOUCH_NAV then
        local offx, offy = (t.lastx - e.pos.x), (t.lasty - e.pos.y)
        e:newComp('circle', {
          name = 'touch_dot',
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
      if SHOW_TOUCH_NAV and e.circle then 
        e:removeComp(e.circle)
      end
    else
      local t = e.touch
      if e.nav_goal then
        e.nav_goal.x, e.nav_goal.y = t.lastx, t.lasty
      end
      if SHOW_TOUCH_NAV and e.circle then
        e.circle.offx, e.circle.offy = (t.lastx - e.pos.x), (t.lasty - e.pos.y)
      end
    end
  end
end


return C
