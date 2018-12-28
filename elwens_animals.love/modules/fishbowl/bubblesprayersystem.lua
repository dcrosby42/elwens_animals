require 'ecs.ecshelpers'
require 'mydebug'
local EventHelpers = require 'eventhelpers'
local Entities = require 'modules.fishbowl.entities'

local Debug = Debug.sub("BubbleSprayer",true,true)

-- local function spawnBubble(e,estore,input,res)
--   local size = randomFloat(0.1, 0.5)
--
--   local bub = Entities.bubble(estore,res, size)
--   -- XXX bub.pic.sx = 
--   -- XXX bub.pic.sy = bub.pic.sx
--   bub.pos.x = randomInt(0,1024)
--   bub.pos.y = 770
--   return bub
-- end

--
-- Bubble Sprayer System
--
local bubbleThrottle=0.01
return function(estore,input,res)
  EventHelpers.handle(input.events, "touch", {
    pressed=function(evt)
      local dur = res.sounds.bubbles.duration
      local ptime = randomFloat(0,dur)
      estore:newEntity({
        {'tag', {name='bubblesprayer'}},
        {'touch', {touchid=evt.id, startx=evt.x, starty=evt.y, lastx=evt.x,lasty=evt.y}},
        {'sound', {sound='bubbles', loop=true, duration=dur, playtime=ptime}},
        {'timer', {name='trigger', t=0,reset=bubbleThrottle,loop=true}},
      })
      Debug.println("Start bubblesprayer touch="..tostring(evt.id).." soundpos="..ptime)
      return true
    end,

    moved=function(evt)
      local found = true
      estore:seekEntity(hasComps('touch'), function(e)
        if e.touch.touchid == evt.id then
          e.touch.lastx = evt.x
          e.touch.lasty = evt.y
          found=true
          return true -- end seek
        end
      end)
      return found
    end,

    released=function(evt)
      local found = true
      estore:seekEntity(hasComps('touch'), function(e)
        if e.touch.touchid == evt.id then
          estore:destroyEntity(e)
          found=true
          Debug.println("End bubblesprayer touch="..tostring(evt.id))
          return true -- end seek
        end
      end)
      return found
    end,
  })

  estore:walkEntities(hasTag('bubblesprayer'), function(e)
    if e.timer and not e.timer.alarm then return end -- respect the timer only if it exists
    -- local x=e.touch.lastx
    -- local y=e.touch.lasty
    -- local b = spawnBubble(e,estore,input,res)
    -- b.pos.x = x + randomInt(-5,5)
    -- b.pos.y = y + randomInt(-5,5)

    Entities.bubble(estore, {
      size=randomFloat(0.1,0.5),
      x=e.touch.lastx + randomInt(-5,5),
      y=e.touch.lasty + randomInt(-5,5),
    })
  end)
end
