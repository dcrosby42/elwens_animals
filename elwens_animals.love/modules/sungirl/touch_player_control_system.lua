local EventHelpers = require 'eventhelpers'
local Debug = require('mydebug').sub("TouchPlayerControl")
local Entities = require("modules.sungirl.entities")

local function aimFor(x,y,e,estore)
  local x, y = screenXYToViewport(Entities.getViewport(estore), x, y)
  if x < e.pos.x then
    e.player_control.left = true
  else
    e.player_control.right = true
  end
end

return defineUpdateSystem(
  allOf(hasTag('player'), hasComps('player_control')),
  function(e, estore, input, res)
    EventHelpers.handle(input.events, 'touch', {

      pressed = function(touch)
        aimFor(touch.x, touch.y, e, estore)
      end,

      released = function(touch)
        e.player_control.right = false
        e.player_control.left = false
      end,

    })
  end
)
