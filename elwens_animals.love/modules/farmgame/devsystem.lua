local Debug = require('mydebug').sub("DevSystem",true,true,true)
local EventHelpers = require 'eventhelpers'
local soundmanager = require 'crozeng.soundmanager'
-- local Entities = require 'modules.farmgame.entities'

return function(estore, input, res)
  EventHelpers.handle(input.events, 'keyboard', {
    pressed = function(event)
      -- Debug.println("Keyboard! "..event.key)
      if event.key == "s" and event.gui then
        soundmanager.printstate()
      end
    end,
  })
end
