local Debug = require 'mydebug'
Debug = Debug.sub("TouchButton",true,true)
local EventHelpers = require 'eventhelpers'
local Entities = require 'modules.animalscreen.entities'

return function(estore, input, res)
  -- 1. Look for hold-me buttons that have been held long enough to trigger:
  estore:walkEntities(hasComps('button', 'timer'), 
    function(e)
      local timer = e.timers.holdbutton
      if timer and timer.alarm then
        -- TODO something like this: EventHelpers.deleteAll('touch',{id=e.button.touchid})
        e.button.touchid = ''
        e:removeComp(timer)
        table.insert(input.events, {type=e.button.eventtype, state="held", eid=e.eid, cid=e.button.cid})
        Debug.println("Emit event "..e.button.eventtype)
      end
    end
  )

  -- 2. Handle incoming touch events
  EventHelpers.handle(input.events, 'touch', {
    -- Touch pressed
    pressed =function(touch)
      -- First, see if we touched a button
      local hit
      estore:seekEntity(hasComps("button"),
        function(e)
          if dist(touch.x,touch.y, e.pos.x,e.pos.y) <= e.button.radius then
            hit = e
            Debug.println("Touch button "..e.eid)
            return true -- short circuit seekEntity
          end
        end
      )
      if hit then
        hit.button.touchid = touch.id
        hit:newComp('timer', {name="holdbutton",t=hit.button.holdtime})
        Debug.println("...holdtime="..hit.button.holdtime)
        return true -- absorb event
      end
    end,

    -- End of touch
    released =function(touch)
      estore:walkEntities(hasComps('button'),
        function(e)
          if e.button.touchid == touch.id then
            Debug.println("Released button "..e.eid)
            e.button.touchid = ''
            e:removeComp(e.timers.holdbutton)
            return true -- absorb event
          end
      end)
    end,
  })
end 
