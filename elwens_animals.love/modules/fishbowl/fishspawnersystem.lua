require 'ecs.ecshelpers'

local EventHelpers = require 'eventhelpers'
local Entities = require 'modules.fishbowl.entities'

local Debug = require('mydebug').sub("FishSpawner",false,false)

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

local function spawnBubble(estore)
  return Entities.bubble(estore,{
    size=randomFloat(0.1,0.5),
    x=randomInt(0,1024),
    y=770,
  })
end

--
-- Fish Spawner System
--
return defineUpdateSystem({'fishspawner','timer'}, function(e, estore,input,res)
  local ftimer = e.timers.fishspawner
  if ftimer and ftimer.alarm then
    spawnFish(e,estore,input,res)
    local nextFish = randomInt(1,6)
    ftimer.t = nextFish
    ftimer.reset = nextFish
  end

  local btimer = e.timers.bubbler
  if btimer and btimer.alarm then
    spawnBubble(estore)
  end

  EventHelpers.handle(input.events, "keyboard", {
    pressed=function(evt)
      if evt.key == "space" then
        spawnBubble(estore)
      end
    end,
  })
end)
