require 'ecs.ecshelpers'
local V = require "vector-light"
local EventHelpers = require 'eventhelpers'
local Entities = require 'modules.snowman.entities'

local Debug = require('mydebug').sub("CannonSystem",true,true)

local Range = 500
local MinPow = 500
local MaxPow = 1000

local function addSound(e, res, name)
  if not name then return end
  local cfg = res.sounds[name]
  if cfg then
    return e:newComp('sound', {
      sound=name,
      state='playing',
      duration=cfg.duration,
      volume=cfg.volume or 1,
    })
  else
    Debug.println("(No sound for "..tostring(name)..")")
    return nil
  end
end

local function newProjectile(evt, estore, res,targetEnt)
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

  estore:seekEntity(hasComps('name'),function(bgEnt)
    if bgEnt.names and bgEnt.names.background then
      local name = pickRandom(res.giftNames)
      local e =Entities.gift(bgEnt,res,name)
      e.body.mass = mass
      e.body.debugDraw = false
      e.pos.x = x
      e.pos.y = y
      e.vel.dx = dx 
      e.vel.dy = dy 
      e.vel.angularvelocity = spin
      addSound(e,res, pickRandom({"woosh1","woosh2"}))
      return true
    end
  end)
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
  snowman:newComp('tag',{name="self_destruct"})
  snowman:newComp('timer',{name="self_destruct",t=4})

  snowman:walkEntities(hasComps('tag'), function(e)
    if e.tags.cannon_target then
      e:removeComp(e.tags.cannon_target)
    end
    -- if e.tags and e.tags.upright_snowman then
    --   e:removeComp(e.tags.upright_snowman)
    -- end
  end)
  estore:walkEntity(snowman, hasComps('joint'), function(e)
    e:removeComp(e.joint)
    e.force.impy = -2
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
  -- EventHelpers.handle(input.events, "keyboard", {
  --   pressed=function(evt)
  --     if evt.key == "space" then
  --       Entities.snowman(estore,res)
  --     end
  --   end,
  -- })
  
  if targetEnt then
    EventHelpers.handle(input.events, "collision", {
      begin=function(evt)
        local snowmanEnt,childEnt = findSnowman({evt.entA,evt.entB})
        local giftEnt = findGift({evt.entA,evt.entB})
        if giftEnt and snowmanEnt then
          local vx,vy = V.sub(evt.dxA,evt.dyA, evt.dxB,evt.dyB)
          local mag = V.len(vx,vy)
          if mag > 1000 then
            local dmg=1
            snowmanEnt.health.hp = snowmanEnt.health.hp - dmg
            Debug.println("Snowman HIT, hp: "..snowmanEnt.health.hp)
            if snowmanEnt.health.hp <= 0 then
              addSound(snowmanEnt, res, pickRandom({"wpunch"}))
              Debug.println("Snowman KILLED")
              killSnowman(estore,snowmanEnt)
              estore:newEntity({
                {'timer', {t=5, event={type='snowmanSpawn',state='fired'}}},
              })
            else
              addSound(snowmanEnt, res, pickRandom({"thud"}))
            end
          end
        end
      end,
    })
  end

  EventHelpers.handle(input.events, "snowmanSpawn", {
    fired=function(evt)
      Entities.snowman(estore,res)
    end
  })
end

