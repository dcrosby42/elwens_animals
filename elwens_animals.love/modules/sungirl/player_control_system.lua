local EventHelpers = require 'eventhelpers'
local Debug = require('mydebug').sub("PlayerControl")

return defineUpdateSystem(
  allOf(hasTag('player'), hasComps('player_control')),
  function(e, estore, input, res)
    local con = e.player_control
    EventHelpers.handle(input.events, 'keyboard', {
      pressed = function(event)
        if con[event.key] ~= nil then
          con[event.key] = true
        end
      end,

      released = function(event)
        if con[event.key] ~= nil then
          con[event.key] = false
        end
      end,
    })
    con.any = con.left or con.right or con.up or con.down or con.jump
  end
)
