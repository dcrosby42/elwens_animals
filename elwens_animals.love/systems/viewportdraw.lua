require("ecs.ecshelpers")
local G = love.graphics

local function construct(mainDrawFunc)
  return function(estore, res)
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

return {construct = construct}
