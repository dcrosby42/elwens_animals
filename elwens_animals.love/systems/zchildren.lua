local Comp = require 'ecs/component'
-- zChildren 
-- 
-- Keeps a set of child entities ordered under their parent (thus controlling draw ordering)
-- basded on their screen Y coordinates... ie, the lower on the screen, the later the draw, the more "on top".
-- 
-- DELETEME? Looks like a holdover ... not currently used as of 2023-12-31

Comp.define("zChildren", {})

return defineUpdateSystem(hasComps('zChildren'),
  function(e,estore,input,res)
    for _, ch in ipairs(e:getChildren()) do
      if ch.pos then
        x,y = getPos(ch)
        ch.parent.order = y
      end
    end
    e:resortChildren()
  end
)
