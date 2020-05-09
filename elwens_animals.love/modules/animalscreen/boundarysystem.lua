require "ecs.ecshelpers"

local Debug = require("mydebug").sub("BoundarySystem", false, false)

local MaxY = 1000
local MinY = -1000
local MaxX = 2000
local MinX = -1000

return defineUpdateSystem(
  {"pos", "vel"},
  function(e, estore, input, res)
    if e.pos.y > MaxY or e.pos.y < MinY or e.pos.x > MaxX or e.pos.x < MinX then
      estore:destroyEntity(e)
      Debug.println(e.eid .. " fell off the world.")
    end
  end
)
