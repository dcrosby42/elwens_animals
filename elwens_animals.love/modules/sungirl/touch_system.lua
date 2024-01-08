local EventHelpers = require 'eventhelpers'
local Debug = require('mydebug').sub("Touch",true)
local Entities = require("modules.sungirl.entities")
local Vec = require 'vector-light'

local function toVPCoords(x,y,estore)
  return screenXYToViewport(Entities.getViewport(estore), x, y)
end

local function findTouchable(estore,touchEvt)
  local x, y = toVPCoords(touchEvt.x, touchEvt.y, estore)
  return findEntity(estore, function(e)
    if e.touchable and e.touchable.enabled and e.pos then
      local ex = e.pos.x + e.touchable.offx
      local ey = e.pos.y + e.touchable.offy
      return Vec.dist(x, y, ex, ey) <= e.touchable.radius
    end
    return false
  end)
end

local function findTouch(estore,tid)
  local e = findEntity(estore, function(e)
    return e.touch and e.touch.touchid == tid
  end)
  if e then
    local comp = e.touchs[tostring(tid)]
    return e, comp
  else
    return nil,nil
  end
end

local function updateTouchComp(touchComp, touchEvt, estore)
  local x, y = toVPCoords(touchEvt.x, touchEvt.y, estore)
  touchComp.touchid = touchEvt.id
  touchComp.state = touchEvt.state
  touchComp.lastx = x
  touchComp.lasty = y
  touchComp.lastscreenx = touchEvt.x
  touchComp.lastscreeny = touchEvt.y
  touchComp.lastdx = touchEvt.dy
  touchComp.lastdy = touchEvt.dy
  return touchComp
end

return function(estore, input, res)

  -- 'released' touches only live for 1 trip around the update loop:
  estore:walkEntities(hasComps('touch'), function(e)
    for _,touchComp in pairs(e.touchs) do
      if touchComp.state == 'released' then
        Debug.println("removing "..tdebug(touchComp))
        e:removeComp(touchComp)
      else
        -- Touch components are "idle" between actual touch events
        touchComp.state = 'idle'
        -- Gotta update viewport-relative coords each times, because the viewport moves around
        touchComp.lastx, touchComp.lasty = toVPCoords(touchComp.lastscreenx,touchComp.lastscreeny,estore)
      end
    end
  end)

  EventHelpers.handle(input.events, 'touch', {
    pressed = function(touch)
      local e = findTouchable(estore,touch)
      if e then
        local touchComp = e:newComp('touch', {name=tostring(touch.id)})
        updateTouchComp(touchComp, touch, estore)
        touchComp.startx = touchComp.lastx
        touchComp.starty = touchComp.lasty
        touchComp.startscreenx = touch.x
        touchComp.startscreeny = touch.y
        Debug.println("pressed: new touch comp: "..tdebug(touchComp))
      end
    end,

    moved = function(touch)
      local e,touchComp = findTouch(estore,touch.id)
      if e and touchComp and touchComp.state ~= "released" then
        -- (ignore moved events if released has already been processed)
        updateTouchComp(touchComp, touch, estore)
        Debug.println("moved: updated touch comp: "..tdebug(touchComp))
      end
    end,

    released = function(touch)
      local e,touchComp = findTouch(estore,touch.id)
      if e then
        updateTouchComp(touchComp, touch, estore)
        Debug.println("released: updated touch comp: "..tdebug(touchComp))
      end
      -- NB: state will be set to 'released'; during the next update, the top of this func will remove the component
    end,
  })
end
