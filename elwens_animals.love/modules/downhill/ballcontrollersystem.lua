local EventHelpers = require 'eventhelpers'

return function(estore,input,res)
  EventHelpers.handle(input.events, "keyboard", {
    pressed=function(evt)
      if evt.key == "right" or evt.key == "left" then
        estore:seekEntity(hasName("ball"), function(e)
          if evt.key == "left" then
            e.force.impx = -100
          elseif evt.key == "right" then
            e.force.impx = 100
          end
          return true
        end)
      end
    end,
  })
end
