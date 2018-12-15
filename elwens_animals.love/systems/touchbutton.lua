local Debug = require 'mydebug'
local EventHelpers = require 'eventhelpers'
local Entities = require 'modules.animalscreen.entities'

-- Helper
-- function addSound(e, name, res)
--   local cfg = res.sounds[name]
--   if cfg then
--     return e:newComp('sound', {
--       sound=name,
--       state='playing',
--       duration=cfg.duration,
--       volume=cfg.volume or 1,
--     })
--   else
--     Debug.println("(No sound for "..tostring(name)..")")
--     return nil
--   end
-- end

return function(estore, input, res)
  estore:walkEntities(hasComps('button', 'timer'), 
    function(e)
      local timer = e.timers.holdbutton
      if timer and timer.alarm then
        -- TODO something like this: EventHelpers.deleteAll('touch',{id=e.button.touchid})
        e.button.touchid = ''
        e:removeComp(timer)
        table.insert(input.events, {type=e.button.eventtype, srcid=e.button.cid})
        Debug.println("Emit event "..e.button.eventtype)
      end
    end
  )

  EventHelpers.handle(input.events, 'touch', {
    -- Touch pressed
    pressed =function(touch)
      -- First, see if we touched a button
      local hit
      estore:seekEntity(hasComps("button"),
        function(e)
          if dist(touch.x,touch.y, e.pos.x,e.pos.y) <= 40 then
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

    -- Touch dragged
    -- moved =function(touch)
    --   estore:walkEntities(hasComps('button'),
    --     function(e)
    --       if e.button.touchid == touch.id then
    --         Debug.println("Move button "..e.eid)
    --       end
    --   end)
    -- end,

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
