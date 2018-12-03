require 'ecs.ecshelpers'
require 'mydebug'

local MaxY = 1000

return defineUpdateSystem({'pos','vel'}, function(e, estore,input,res)
  if e.pos.y > MaxY then
    estore:destroyEntity(e)
    Debug.println("BoundarySystem: "..e.eid.." fell off the world.")
  end
end)
