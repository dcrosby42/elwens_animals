local Debug = require('mydebug').sub("DevSystem",true,true,true)
local Entities = require 'modules.farmgame.entities'
local EventHelpers = require 'eventhelpers'
local soundmanager = require 'crozeng.soundmanager'
-- local Entities = require 'modules.farmgame.entities'

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
      -- Debug.println("Keyboard! "..event.key)
      if event.key == "s" and event.gui then
        soundmanager.printstate()
      end

      manuallyMoveViewport(event, estore)
    end,
  })
end
