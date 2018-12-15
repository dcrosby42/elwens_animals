local Debug = require 'mydebug'
local EventHelpers = require 'eventhelpers'
local Entities = require 'modules.animalscreen.entities'

local FlingFactorX=10
local FlingFactorY=10

-- Helper
function addSound(e, name, res)
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

function setScale(e,sx,sy)
end

return function(estore, input, res)
  EventHelpers.handle(input.events, 'touch', {
    -- Touch pressed
    pressed =function(touch)
      -- First, see if we touched an animal
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
      local animalName
      if not e then
        -- Nothing.  Let's generate a random animal
        animalName = pickRandom(res.animalNames)
        e = Entities.animal(estore, res, animalName)
			else
        if e.pic then
          animalName = e.pic.id
        end
      end
      -- slightly enlarge the animal image (normally it's 0.5)
      vis = e.anim or e.pic
      vis.sx = 0.7
      vis.sy = 0.7
      e.pos.x = touch.x
      e.pos.y = touch.y
      e:newComp('manipulator', {id=touch.id, mode='drag'}) -- TODO MORE INFO HERE?

      -- Try to add a sound for this animal
      addSound(e, animalName, res)

    end,

    -- Touch dragged
    moved =function(touch)
      -- Find the entity having a manipulator that matches the id of this touch event
      estore:walkEntities(
        hasComps('manipulator','pos'),
        function(e)
          if e.manipulator.id == touch.id then
            -- Move the entity where the touch is moving
            e.pos.x = touch.x
            e.pos.y = touch.y
            e.vel.dx = 0
            e.vel.dy = 0
            -- track some deltas
            e.manipulator.dx = touch.dx or 0
            e.manipulator.dy = touch.dy or 0
          end
      end)
    end,

    -- End of touch
    released =function(touch)
      estore:walkEntities(
        hasComps('manipulator','pos'),
        function(e)
          if e.manipulator.id == touch.id then
            e.pos.x = touch.x
            e.pos.y = touch.y
            e.vel.dx = (e.manipulator.dx or 0) * FlingFactorX
            e.vel.dy = (e.manipulator.dy or 0) * FlingFactorY
            local comp = e.anim or e.pic
            comp.sx = 0.5
            comp.sy = 0.5
            e:removeComp(e.manipulator)
          end
      end)
    end,

  })
end 
