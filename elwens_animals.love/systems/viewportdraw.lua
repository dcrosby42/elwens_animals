require("ecs.ecshelpers")
local G = love.graphics

-- wrap() returns a draw function that:
-- 1. Uses the "viewport" entity to transform the view (push, translate etc)
-- 2. Invokes the given mainDrawFunc
-- 3. pops the graphics context when done
-- (If there's no entity named "viewport", transform is skipped and mainDrawFunc is invoked normally.)
local function wrap(mainDrawFunc)
  return function(estore, res)
    -- viewport entity must have a "name" comp where name=="viewport",
    -- and singular "pos" and "rect" components.
    local viewport = estore:getEntityByName("viewport")
    if viewport then
      -- Transform the view
      G.push()
      G.translate(-viewport.pos.x - viewport.rect.offx, -viewport.pos.y - viewport.rect.offy)
    end

    mainDrawFunc(estore, res)

    if viewport then
      -- un-transform the view
      G.pop()
    end
  end
end

return {wrap = wrap}
