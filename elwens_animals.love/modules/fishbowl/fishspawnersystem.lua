require 'ecs.ecshelpers'
require 'mydebug'
local Entities = require 'modules.fishbowl.entities'


return defineUpdateSystem({'fishspawner','timer'}, function(e, estore,input,res)
  local timer = e.timers.fishspawner
  if timer and timer.alarm then

    local f = Entities.fish(estore, res)
    f.pos.y = randomInt(20,740)
    f.vel.dx = randomInt(5,50)

    local flip = randomInt(0,1)
    if flip == 0 then
      -- start at right, go left
      f.pos.x = 1024
      f.vel.dx = -f.vel.dx
    else
      -- start at left, go right
      f.pos.x = 0
      f.pic.sx = -f.pic.sx
    end
  end
end)
