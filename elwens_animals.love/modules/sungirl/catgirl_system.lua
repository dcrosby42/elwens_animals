local EventHelpers = require 'eventhelpers'
local Debug = require('mydebug').sub("CatGirl")
local Entities = require("modules.sungirl.entities")

local function handleMovement(e, estore, input, res)
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

  

  -- MOVE
  e.pos.x = e.pos.x + (input.dt * e.vel.dx)
  e.pos.y = e.pos.y + (input.dt * e.vel.dy)
end

local function manageWaypoint(e,estore,input,res)
  EventHelpers.handle(input.events, 'touch', {
    pressed = function(touch)
      local viewportE = Entities.getViewport(estore)
      local vp = viewportE.viewport
      
      local x = (touch.x  +  vp.x) / vp.sx
      -- local y = (touch.y  +  vp.y) / vp.sy
      local y = 460 -- over head fixed height

      local wp = findEntity(estore, allOf(hasTag('waypoint'),hasName('sungirl_nav')))
      if wp then
        Debug.println("Removing waypoint at "..wp.pos.x..", "..wp.pos.y)
        estore:destroyEntity(wp)
      else
        wp = Entities.waypoint(viewportE, 'sungirl_nav', x,y)
        Debug.println("Adding waypoint at "..wp.pos.x..", "..wp.pos.y)
      end
    end,
  })
end

local function handleNavigation(e,estore,input,res)
  local wp = findEntity(estore, allOf(hasTag('waypoint'),hasName('sungirl_nav')))
  if wp then
    local dist = math.abs(wp.pos.x - e.pos.x)
    local thresh = 50
    if dist > thresh then
      -- approach waypoint
      if wp.pos.x - e.pos.x > 0 then
        -- go right
        e.player_control.left = false
        e.player_control.right = true
      else
        -- go left
        e.player_control.left = true
        e.player_control.right = false
      end
    else
      -- arrived at waypoint
      e.player_control.left = false
      e.player_control.right = false
      estore:destroyEntity(wp)
    end
  end
end

return defineUpdateSystem(hasTag('catgirl'),
  function(e, estore, input,res)

    handleMovement(e,estore,input,res)

    -- manageWaypoint(e,estore,input,res)

    -- handleNavigation(e,estore,input,res)


  end
)
