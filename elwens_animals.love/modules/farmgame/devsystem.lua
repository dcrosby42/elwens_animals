local Debug = require('mydebug').sub("DevSystem",true,true,true)
local EventHelpers = require 'eventhelpers'
-- local Entities = require 'modules.farmgame.entities'

return function(estore, input, res)
  EventHelpers.handle(input.events, 'keyboard', {
    pressed = function(event)
      -- Debug.println("Keyboard! "..event.key)
    end,
  })
end
