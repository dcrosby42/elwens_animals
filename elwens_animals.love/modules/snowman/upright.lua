require 'ecs.ecshelpers'
local Debug = require('mydebug').sub("Upright",true,true)

local EventHelpers = require 'eventhelpers'

-- 
-- Keep snowmen upright
--
return defineUpdateSystem(hasTag('upright_snowman'), function(e,estore,input,res)
    local ta = 0
    local a = e.pos.r
    local diff = a-ta
    local sign=1
    if diff == 0 then 
      return
    elseif math.abs(diff) < 0.01 and e.vel.angularvelocity < 0.01 then
      e.pos.r = ta
      e.vel.angularvelocity = 0
      return
    elseif diff < 0 then
      sign = -1
    end
    local f = -sign * (math.pow(math.abs(diff),0.5) * 500000)
    e.force.torque = f
end)
