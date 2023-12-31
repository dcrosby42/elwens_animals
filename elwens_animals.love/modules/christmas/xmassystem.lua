require 'ecs.ecshelpers'
local EventHelpers = require 'eventhelpers'
local Entities = require 'modules.christmas.entities'

local Debug = require('mydebug').sub("XmasSystem",false,false)

function newOrnament(evt,estore,res)
  local item = pickRandom(res.ornamentNames)
  Debug.println(item)
  local orn = Entities.ornament(estore, res, item)
  orn.pos.x = evt.x
  orn.pos.y = evt.y
  return orn
end

-- 
-- Xmas System
--
return function(estore,input,res)
  EventHelpers.handle(input.events, "touch", {
    pressed=function(evt)
      local hit
      estore:seekEntity(hasTag('ornament'),function(e)
        if dist(evt.x,evt.y, e.pos.x,e.pos.y) <= 70 then
          hit = e
          return true
        end
      end)
      if hit then
        Debug.println("Touched "..hit.eid)
        local ang = -randomFloat(0,math.pi)
        local mag = randomInt(300,1800)
        hit.vel.dx=math.cos(ang)*mag
        hit.vel.dy=math.sin(ang)*mag
      else
        newOrnament(evt,estore,res)
      end
      return true
    end,

    moved=function(evt)
    end,

    released=function(evt)
    end,
  })
end
