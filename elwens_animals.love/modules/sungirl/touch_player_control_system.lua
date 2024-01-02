local EventHelpers = require 'eventhelpers'
local Debug = require('mydebug').sub("TouchPlayerControl")
local Entities = require("modules.sungirl.entities")

local function screenXYToViewport(estore, x, y)
  local sx = 1
  local sy = 1
  local vx = 0
  local vy = 0
  local viewportE = Entities.getViewport(estore)
  if viewportE then
    sx = viewportE.viewport.sx
    sy = viewportE.viewport.sy
    vx = viewportE.viewport.x
    vy = viewportE.viewport.y
  end
  local xx = (x + vx) / sx
  local yy = (y + vy) / sy
  return xx, yy
end

return defineUpdateSystem(
  allOf(hasTag('player'), hasComps('player_control')),
  function(e, estore, input, res)
    EventHelpers.handle(input.events, 'touch', {

      pressed = function(touch)
        local x, y = screenXYToViewport(estore, touch.x, touch.y)
        if x < e.pos.x then
          e.player_control.left = true
        else
          e.player_control.right = true
        end
      end,

      released = function(touch)
        e.player_control.right = false
        e.player_control.left = false
      end,

    })
  end
)
