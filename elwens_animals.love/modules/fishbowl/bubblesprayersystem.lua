require 'ecs.ecshelpers'
require 'mydebug'
local EventHelpers = require 'eventhelpers'
local Entities = require 'modules.fishbowl.entities'

local Debug = Debug.sub("BubbleSprayer",true,true)

local function spawnBubble(e,estore,input,res)
  local bub = Entities.bubble(estore,res)
  bub.pic.sx = randomFloat(0.1, 0.5)
  bub.pic.sy = bub.pic.sx
  bub.pos.x = randomInt(0,1024)
  bub.pos.y = 770
  return bub
end

--
-- Bubble Sprayer System
--
return function(estore,input,res)
  EventHelpers.handle(input.events, "touch", {
    pressed=function(evt)
      estore:newEntity({
        {'tag', {name='bubblesprayer'}},
        {'touch', {touchid=evt.id, startx=evt.x, starty=evt.y, lastx=evt.x,lasty=evt.y}},
      })
      Debug.println("Start bubblesprayer touch="..evt.id)
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
          Debug.println("End bubblesprayer touch="..evt.id)
          return true -- end seek
        end
      end)
      return found
    end,
  })

  estore:walkEntities(hasTag('bubblesprayer'), function(e)
    local x=e.touch.lastx
    local y=e.touch.lasty
    Debug.println("spray x="..x.." y="..y)
    local b = spawnBubble(e,estore,input,res)
    b.pos.x = x + randomInt(-5,5)
    b.pos.y = y + randomInt(-5,5)
  end)
end
