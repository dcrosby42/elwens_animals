local Debug = require 'mydebug'
local EventHelpers = require 'eventhelpers'
local Entities = require 'modules.animalscreen.entities'

local FlingFactorX=10
local FlingFactorY=10

return function(estore, input, res)
  EventHelpers.handle(input.events, 'touch', {

    pressed =function(touch)
      local hit
      estore:seekEntity(
        hasTag('animal'),
        function(e) 
          if dist(touch.x,touch.y, e.pos.x,e.pos.y) <= 70 then
            hit = e
            return true
          end
        end
      )
      local e = hit
      local name
      if not e then
        name = pickRandom(res.animalNames)
        e = Entities.animal(estore, res, name)
			else
        name = e.img.imgId
      end
      e.img.sx = 0.7
      e.img.sy = 0.7
      e.pos.x = touch.x
      e.pos.y = touch.y
      e:newComp('manipulator', {id=touch.id, mode='drag'}) -- TODO MORE INFO HERE

      -- Add a sound
      local cfg = res.sounds[name]
      if cfg then
        local s = e:newComp('sound', {
          sound=name,
          -- state='playing', -- default
          duration=cfg.duration,
					volume=cfg.volume or 1,
        })
      else
				Debug.println("(No sound for "..tostring(name)..")")
      end

    end,

    moved =function(touch)
      estore:walkEntities(
        hasComps('manipulator','pos'),
        function(e)
          if e.manipulator.id == touch.id then
            e.pos.x = touch.x
            e.pos.y = touch.y
            e.vel.dx = 0
            e.vel.dy = 0
            e.manipulator.dx = touch.dx or 0
            e.manipulator.dy = touch.dy or 0
          end
      end)
    end,

    released =function(touch)
      estore:walkEntities(
        hasComps('manipulator','pos'),
        function(e)
          if e.manipulator.id == touch.id then
            e.pos.x = touch.x
            e.pos.y = touch.y
            e.img.drawBounds = false
            e.img.sx = 0.5
            e.img.sy = 0.5
            e.vel.dx = (e.manipulator.dx or 0) * FlingFactorX
            e.vel.dy = (e.manipulator.dy or 0) * FlingFactorY
            e:removeComp(e.manipulator)
          end
      end)
    end,

  })
end

-- function defineUpdateSystem(matchSpec,fn)
--   local matchFn = matchSpecToFn(matchSpec)
--   return function(estore, input, res)
--     estore:walkEntities(
--       matchFn,
--       function(e) fn(e, estore, input, res) end
--     )
--   end
-- end
