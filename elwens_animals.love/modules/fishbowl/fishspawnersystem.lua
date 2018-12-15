require 'ecs.ecshelpers'
require 'mydebug'
local EventHelpers = require 'eventhelpers'
local Entities = require 'modules.fishbowl.entities'

local Debug = Debug.sub("FishSpawner",false,false)

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

local function spawnBubble(e,estore,input,res)
  local bub = Entities.bubble(estore,res)
  bub.pic.sx = randomFloat(0.1, 0.5)
  bub.pic.sy = bub.pic.sx
  bub.pos.x = randomInt(0,1024)
  bub.pos.y = 770
  return bub
end

--
-- Fish Spawner System
--
return defineUpdateSystem({'fishspawner','timer'}, function(e, estore,input,res)
  local ftimer = e.timers.fishspawner
  if ftimer and ftimer.alarm then
    spawnFish(e,estore,input,res)
  end

  local btimer = e.timers.bubbler
  if btimer and btimer.alarm then
    spawnBubble(e,estore,input,res)
  end

  EventHelpers.handle(input.events, "keyboard", {
    pressed=function(evt)
      if evt.key == "space" then
        spawnBubble(e,estore,input,res)
      end
    end,
  })
end)
