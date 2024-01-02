local EventHelpers = require 'eventhelpers'
local Debug = require('mydebug').sub("PlayerControl")

return defineUpdateSystem(
  allOf(hasTag('player'), hasComps('player_control')),
  function(e, estore, input, res)
    EventHelpers.handle(input.events, 'keyboard', {

      pressed = function(event)
        if event.key == "left" then
          e.player_control.left = true
        elseif event.key == "right" then
          e.player_control.right = true
        end
      end,

      released = function(event)
        if event.key == "left" then
          e.player_control.left = false
        elseif event.key == "right" then
          e.player_control.right = false
        end
      end,

    })
  end
)
