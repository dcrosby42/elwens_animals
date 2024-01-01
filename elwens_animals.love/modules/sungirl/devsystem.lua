local Debug = require('mydebug').sub("DevSystem",true,true,true)
local Entities = require 'modules.sungirl.entities'
local EventHelpers = require 'eventhelpers'

local function manuallyMoveViewport(viewportE, event, estore)
  local step = 10
  local zstep = 0.2

  local dx, dy, dzoom
  if event.key == "right" then
    dx = step
  elseif event.key == "left" then
    dx = -step
  elseif event.key == "up" then
    dy = -step
  elseif event.key == "down" then
    dy = step
  elseif event.key == "=" then
    dzoom = zstep
  elseif event.key == "-" then
    dzoom = -zstep
  end

  if dx or dy or dzoom then
    viewportE.viewport.x = viewportE.viewport.x + (dx or 0)
    viewportE.viewport.y = viewportE.viewport.y + (dy or 0)

    viewportE.viewport.sx = viewportE.viewport.sx + (dzoom or 0)
    viewportE.viewport.sy = viewportE.viewport.sy + (dzoom or 0)
  end
end

local function movePlayer(event,estore,input,res)
  local step = 10
  local dx, dy
  if event.key == "right" then
    dx = step
  elseif event.key == "left" then
    dx = -step
  elseif event.key == "up" then
    dy = -step
  elseif event.key == "down" then
    dy = step
  end
  if dx or dy then
    local e = findEntity(estore, hasName("sketchwalker"))
    if e then
      e.pos.x = e.pos.x + dx
    end
  end
end

return function(estore, input, res)
  local viewportE = Entities.getViewport(estore)

  EventHelpers.handle(input.events, 'keyboard', {
    pressed = function(event)
      -- manuallyMoveViewport(viewportE, event, estore)
      movePlayer(event,estore,input,res)
    end,
  })

  EventHelpers.handle(input.events, 'touch', {
    scrolled = function(touchAction)
      -- 
      -- Scrolling view left/right:
      --
      local x = touchAction.x
      if x ~= 0 then
        local scrollStep = 10
        if touchAction.shift then scrollStep = 50 end
        viewportE.viewport.x = viewportE.viewport.x + (x * scrollStep)
      end
    end,

    pressed = function(touch)
      local x = touch.x + viewportE.viewport.x
      local y = touch.y + viewportE.viewport.y
      Debug.println("Click: "..touch.x..", "..touch.y.." -- "..x..", "..y)
    end
  })
end
