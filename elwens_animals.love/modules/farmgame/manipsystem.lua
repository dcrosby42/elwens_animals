local Debug = require 'mydebug'
local EventHelpers = require 'eventhelpers'
local Entities = require 'modules.farmgame.entities'

local FlingFactorX = 10
local FlingFactorY = 10
local ZoomedVisualSize = 0.7
local UnzoomedVisualSize = 0.5

local function zoomPic(e)
  if e.pic then
    e.pic.sx = ZoomedVisualSize
    e.pic.sy = ZoomedVisualSize
  end
end

local function unzoomVisual(e)
  if e.pic then
    e.pic.sx = UnzoomedVisualSize
    e.pic.sy = UnzoomedVisualSize
  end
end

local function addManipulator(e,touch)
  return e:newComp('manipulator', { id = touch.id, mode = 'drag', x = touch.x, y = touch.y })
end

local function handleAnimal(estore,touch,res)
  return touchingTaggedEntity(estore,touch,"animal",70, function(e) 
    zoomPic(e)
    addManipulator(e,touch)
    Entities.addSound(e, e.pic.id, res)
  end)
end

local function handleFood(estore,touch,res)
  return touchingTaggedEntity(estore,touch,"food",50, function(e) 
    zoomPic(e)
    addManipulator(e,touch)
  end)
end

local function handleAir(estore,touch,res)
  -- Let's generate a random animal
  -- local animalName = pickRandom(res.animalNames)
  -- local e = Entities.animal(estore, res, animalName)
  -- moveAnimal(e, touch, res)
end

local function handleFoodBox(estore,touch,res)
  return touchingTaggedEntity(estore, touch, "food_box", 50, function(e)
    -- Dispense food
    local foodE = Entities.food(estore, res, e.pics.food.id)
    foodE.pos.x = e.pos.x
    foodE.pos.y = e.pos.y
    foodE.force.impx = 5
  end)
end

local function dragManipulator(estore, touch, res)
  estore:walkEntities(hasComps('manipulator', 'pos'), function(e)
    if e.manipulator.id == touch.id then
      e.manipulator.x = touch.x
      e.manipulator.y = touch.y
      e.manipulator.dx = touch.dx or 0
      e.manipulator.dy = touch.dy or 0
    end
  end)
end

local function releaseManipulator(estore, touch, res)
  estore:walkEntities(
    hasComps('manipulator', 'pos'),
    function(e)
      if e.manipulator.id == touch.id then
        -- reposition and fling item:
        e.pos.x = touch.x
        e.pos.y = touch.y
        e.vel.dx = (e.manipulator.dx or 0) * FlingFactorX
        e.vel.dy = (e.manipulator.dy or 0) * FlingFactorY

        unzoomVisual(e)

        e:removeComp(e.manipulator)
      end
    end)
end

return function(estore, input, res)
  local ended = false
  EventHelpers.handle(input.events, 'touch', {
    -- Touch pressed
    pressed = function(touch)
      if handleAnimal(estore,touch,res) then
      elseif handleFoodBox(estore, touch, res) then
      elseif handleFood(estore, touch, res) then
      elseif handleAir(estore,touch,res) then
      end
    end,

    -- Touch dragged
    moved = function(touch)
      dragManipulator(estore,touch,res)
    end,

    -- End of touch
    released = function(touch)
      releaseManipulator(estore, touch, res)
      ended = true
    end,
  })

  if not ended then
    -- Rigidly control motion and location while under manipulation:
    estore:walkEntities(
      hasComps('manipulator', 'pos', 'vel'),
      function(e)
        e.vel.dx = 0
        e.vel.dy = 0
        e.pos.x = e.manipulator.x
        e.pos.y = e.manipulator.y
        e.pos.r = 0
        e.vel.angularvelocity = 0
      end)
  end
end
