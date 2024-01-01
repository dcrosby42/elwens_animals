local Debug = require('mydebug').sub("DevSystem",true,true,true)
local Entities = require 'modules.sungirl.entities'
local EventHelpers = require 'eventhelpers'

local function manuallyMoveViewport(event, estore)
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
    local viewportE = Entities.getViewport(estore)
    if viewportE then
      viewportE.viewport.x = viewportE.viewport.x + (dx or 0)
      viewportE.viewport.y = viewportE.viewport.y + (dy or 0)

      viewportE.viewport.sx = viewportE.viewport.sx + (dzoom or 0)
      viewportE.viewport.sy = viewportE.viewport.sy + (dzoom or 0)
    end
  end
end

return function(estore, input, res)
  EventHelpers.handle(input.events, 'keyboard', {
    pressed = function(event)
      manuallyMoveViewport(event, estore)
    end,
  })

  EventHelpers.handle(input.events, 'touch', {
    scrolled = function(touchAction)
      -- 
      -- Scrolling view left/right:
      --
      local x = touchAction.x
      if x ~= 0 then
        local viewportE = Entities.getViewport(estore)
        if viewportE then
          local scrollStep = 10
          if touchAction.shift then scrollStep = 50 end
          viewportE.viewport.x = viewportE.viewport.x + (x * scrollStep)
        end
      end
    end
  })
end
