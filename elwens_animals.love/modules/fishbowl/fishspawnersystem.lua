require 'ecs.ecshelpers'
require 'mydebug'
local EventHelpers = require 'eventhelpers'
local Entities = require 'modules.fishbowl.entities'

local function spawnFish(e,estore,input,res)
  local f = Entities.fish(estore, res)
  f.pos.y = randomInt(20,740)
  f.vel.dx = randomInt(20,100)

  if flipCoin() then
    -- start at right, go left
    f.pos.x = 1024
    f.vel.dx = -f.vel.dx
  else
    -- start at left, go right
    f.pos.x = 0
    f.anim.sx = -f.anim.sx
  end
  f.fish.targetspeed = f.vel.dx

  f.fish.kind = pickRandom(res.fishColors)
  Debug.println("Fish spawner: new fish "..f.eid)
end

--
-- Fish Spawner System
--
return defineUpdateSystem({'fishspawner','timer'}, function(e, estore,input,res)
  local timer = e.timers.fishspawner
  if timer and timer.alarm then
    spawnFish(e,estore,input,res)
  end

  EventHelpers.handle(input.events, "keyboard", {
    pressed=function(evt)
      spawnFish(e,estore,input,res)
      -- Debug.println("FISH SPACE!")
    end,
  })
end)
