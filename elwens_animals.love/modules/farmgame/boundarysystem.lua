-- boundarysystem
--
-- Destroys entities that leave the screen (beyond the "grace buffer")
--
require 'ecs.ecshelpers'
require 'mydebug'

local Debug = require('mydebug').sub("BoundarySystem", false, false, false)

local Buffer = 100

return defineUpdateSystem({ 'pos', 'vel' }, function(e, estore, input, res)
  local w, h = love.graphics.getDimensions()
  local top = -Buffer
  local bottom = h + Buffer
  local left = -Buffer
  local right = w + Buffer

  if e.pos.y > bottom or
      e.pos.y < top or
      e.pos.x > right or
      e.pos.x < left then
    Debug.println("Destroy entity "..debugEntityName(e) .. ", cuz it left the screen.")
    estore:destroyEntity(e)
  end
end)
