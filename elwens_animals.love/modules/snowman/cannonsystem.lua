require 'ecs.ecshelpers'
require 'mydebug'
local EventHelpers = require 'eventhelpers'
local Entities = require 'modules.snowman.entities'

local Debug = Debug.sub("CannonSystem",true,true)

local Range = 500
local MinPow = 500
local MaxPow = 1000

function newProjectile(evt, estore, res,targetEnt)
  if not targetEnt then return end

  Debug.println("Projectile!")

  -- local CannonWallRadius = math.dist(0,0, love.graphics.getWidth()/2, love.graphics.getHeight())

  local touchX=evt.x
  local touchY=evt.y
  local targX,targY = getPos(targetEnt)

  local d = math.dist(touchX,touchY, targX,targY)
  local prop = math.max(d/Range, 1.0)
  local inv = 1 / prop
  -- local power = MinPow + inv*(MaxPow-MinPow)
  local power = MinPow + prop*(MaxPow-MinPow)
  local vec = {(targX-touchX)/d, (targY-touchY)/d}
  local dx = vec[1] * power
  local dy = vec[2] * power

  local x = targX - vec[1]*Range
  local y = targY - vec[2]*Range

  local w = 40
  local h = 40

  local mass=1
  local spin=10

  local name = pickRandom(res.giftNames)
  Debug.println("res.giftNames "..tflatten(res.giftNames))
  local e =Entities.gift(estore,res,name)
  e.body.mass = mass
  e.body.debugDraw = false
  e.pos.x = x
  e.pos.y = y
  e.vel.dx = dx 
  e.vel.dy = dy 
  e.vel.angularvelocity = spin

  return e
end

-- 
-- Cannon System
--
return function(estore,input,res)
  local targetEnt
  estore:seekEntity(hasTag('cannon_target'),function(e)
    targetEnt = e
    return true
  end)

  EventHelpers.handle(input.events, "touch", {
    pressed=function(evt)
      newProjectile(evt,estore,res,targetEnt)
      return true
    end,

    moved=function(evt)
    end,

    released=function(evt)
    end,
  })

  -- XXX
  EventHelpers.handle(input.events, "keyboard", {
    pressed=function(evt)
      if evt.key == "space" then
        estore:walkEntities(hasComps('joint'), function(e)
          e:removeComp(e.joint)
          -- e.force.impy = -5
        end)
        if targetEnt then
          targetEnt:removeComp(targetEnt.tags.cannon_target)
        end
      end
    end,
  })
  if targetEnt then
    EventHelpers.handle(input.events, "collision", {
      begin=function(evt)
        local vel
        if evt.entA.eid == targetEnt.eid then
          vel = evt.velA
        elseif evt.entB.eid == targetEnt.eid then
          vel = evt.velB
        end
        if vel then
          Debug.println("Snowman hit: "..tflatten(vel))
        end
      end,
    })
  end
end
