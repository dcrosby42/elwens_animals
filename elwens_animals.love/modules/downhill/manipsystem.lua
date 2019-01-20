local Debug = require 'mydebug'
local EventHelpers = require 'eventhelpers'
local Entities = require 'modules.animalscreen.entities'
local MapSystem = require 'modules.downhill.mapsystem'

local FlingFactorX=10
local FlingFactorY=10


return function(estore, input, res)
  local offx = 0
  local offy = 0
  local viewport = estore:getComponentOfNamedEntity("viewport","viewport")
  if viewport then
    offx = viewport.x
    offy = viewport.y
  end
  EventHelpers.handle(input.events, 'touch', {
    -- Touch pressed
    pressed =function(touch)
      local touchx,touchy = touch.x+offx,touch.y+offy

      local groundHeight = MapSystem.terrain(touchx)
      if touchy > groundHeight then return end

      -- First, see if we touched an animal
      -- local hit
      -- estore:seekEntity(
      --   hasTag('animal'),
      --   function(e) 
      --     if dist(touchx,touchy, e.pos.x,e.pos.y) <= 70 then
      --       hit = e
      --       return true
      --     end
      --   end
      -- )
      -- local e = hit
      -- local animalName
      local e
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
      -- vis.sx = 0.7
      -- vis.sy = 0.7
      vis.sx = 0.5
      vis.sy = 0.5
      e.pos.x = touchx
      e.pos.y = touchy
      e.force.impx = love.math.random(400,600)
      e.force.impy = love.math.randomNormal(-500,150)
      e.force.angimp = love.math.randomNormal(15000,3000)
      e:newComp('manipulator', {id=touch.id, mode='drag'}) -- TODO MORE INFO HERE?

      -- Try to add a sound for this animal
      Entities.addSound(e, animalName, res)

      -- Re-target the viewport -- XXX ?
      -- local targE
      -- estore:seekEntity(hasComps('viewportTarget'),function(e)
      --   targE = e
      --   return true
      -- end)
      -- if targE then
      --   local comp = targE.viewportTarget
      --   estore:detachComp(targE, comp)
      --   estore:addComp(e, comp)
      -- end

    end,

    -- Touch dragged
    -- moved =function(touch)
    --   -- Find the entity having a manipulator that matches the id of this touch event
    --   local touchx,touchy = touch.x+offx,touch.y+offy
    --   estore:walkEntities(
    --     hasComps('manipulator','pos'),
    --     function(e)
    --       if e.manipulator.id == touch.id then
    --         -- Move the entity where the touch is moving
    --         e.pos.x = touchx
    --         e.pos.y = touchy
    --         e.vel.dx = 0
    --         e.vel.dy = 0
    --         -- track some deltas
    --         e.manipulator.dx = touch.dx or 0
    --         e.manipulator.dy = touch.dy or 0
    --       end
    --   end)
    -- end,

    -- End of touch
    -- released =function(touch)
    --   local touchx,touchy = touch.x+offx,touch.y+offy
    --   estore:walkEntities(
    --     hasComps('manipulator','pos'),
    --     function(e)
    --       if e.manipulator.id == touch.id then
    --         e.pos.x = touchx
    --         e.pos.y = touchy
    --         e.vel.dx = (e.manipulator.dx or 0) * FlingFactorX
    --         e.vel.dy = (e.manipulator.dy or 0) * FlingFactorY
    --         local comp = e.anim or e.pic
    --         comp.sx = 0.5
    --         comp.sy = 0.5
    --         e:removeComp(e.manipulator)
    --       end
    --   end)
    -- end,

  })
end 
