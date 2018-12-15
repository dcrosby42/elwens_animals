require 'ecs.ecshelpers'
require 'mydebug'
local EventHelpers = require 'eventhelpers'
local Entities = require 'modules.fishbowl.entities'

--
-- Fish System
--
local dampen = 0.02
local accel = 0.02
return defineUpdateSystem({'fish'}, function(e, estore,input,res)
  if e.timers.brain.alarm then
    if e.fish.state == "swim" then
      e.fish.state = "idle"
    else
      if flipCoin(0.8) then
        e.fish.state = "swim"
      else
        e.fish.targetspeed = -e.fish.targetspeed
        e.anim.sx = -e.anim.sx
      end
    end
  end
  if e.fish.state == "idle" then
    e.vel.dx = (1-dampen) * e.vel.dx
    e.vel.dy = (1-dampen) * e.vel.dy
    e.force.fx = 0
    e.force.fy = 0
  else
    if e.fish.targetspeed > 0 then
      if e.vel.dx < e.fish.targetspeed then
        e.force.fx = 50
      end
    elseif e.fish.targetspeed < 0 then
      if e.vel.dx > e.fish.targetspeed then
        e.force.fx = -50
      end
    end
  end
  e.anims.fishy.id="fish_"..e.fish.kind.."_"..e.fish.state
end)
