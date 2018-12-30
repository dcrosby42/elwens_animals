require 'ecs.ecshelpers'
require 'mydebug'
local V = require "vector-light"
local EventHelpers = require 'eventhelpers'
local Entities = require 'modules.snowman.entities'

local Debug = Debug.sub("CannonSystem",true,true)

local Range = 500
local MinPow = 500
local MaxPow = 1000

function newProjectile(evt, estore, res,targetEnt)
  if not targetEnt then return end

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

local function findSnowman(ents)
  for i=1,#ents do
    local par = ents[i]:getParent()
    if par and par.tags and par.tags.snowman and par.health then
      return par,ents[i]
    end
  end
  return nil,nil
end
local function findGift(ents)
  for i=1,#ents do
    local e = ents[i]
    if e.tags and e.tags.gift then
      return e
    end
  end
  return nil
end

local function killSnowman(estore,snowman) 
  estore:walkEntity(snowman, hasComps('tag'), function(e)
    if e.tags.cannon_target then
      e:removeComp(e.tags.cannon_target)
    end
    -- if e.tags and e.tags.upright_snowman then
    --   e:removeComp(e.tags.upright_snowman)
    -- end
  end)
  estore:walkEntity(snowman, hasComps('joint'), function(e)
    e:removeComp(e.joint)
    -- e.force.impy = -5
  end)
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
        local fake={x=randomInt(10,1000),y=100}
        newProjectile(fake,estore,res,targetEnt)
        -- estore:walkEntities(hasTag('snowman'), function(e)
        --   killSnowman(estore,e)
        -- end)
      end
    end,
  })
  
  if targetEnt then
    EventHelpers.handle(input.events, "collision", {
      begin=function(evt)
        local snowmanEnt,childEnt = findSnowman({evt.entA,evt.entB})
        local giftEnt = findGift({evt.entA,evt.entB})
        if giftEnt and snowmanEnt then
          local vx,vy = V.sub(evt.dxA,evt.dyA, evt.dxB,evt.dyB)
          local mag = V.len(vx,vy)
          -- Debug.println("Collision "..evt.compA.cid.."-"..evt.compB.cid.." "..V.rstr(evt.dxA,evt.dyA).."-"..V.rstr(evt.dxB,evt.dyB).." vel: ".. V.rstr(vx,vy).." mag: "..mag)
          -- Debug.println("  compA: "..tflatten(evt.compA))
          -- Debug.println("  compB: "..tflatten(evt.compB))
          if mag > 1000 then
            local dmg=1
            snowmanEnt.health.hp = snowmanEnt.health.hp - dmg
            Debug.println("Snowman HIT, hp: "..snowmanEnt.health.hp)
            if snowmanEnt.health.hp <= 0 then
              Debug.println("Snowman KILLED")
              killSnowman(estore,snowmanEnt)
            end
          end
        end
      end,
    })
  end
end
