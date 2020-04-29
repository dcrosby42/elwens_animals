require("ecs.ecshelpers")
local G = love.graphics

local function getScaledRect(sx, sy, r)
  return {
    x = r.x * sx,
    y = r.y * sy,
    w = r.w * sx,
    h = r.h * sy
  }
end

-- local function getViewportRect(viewport)
--   viewport.pos.x
-- end

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
      local sx = viewport.viewport.sx
      local sy = viewport.viewport.sy

      G.push()
      -- G.translate((d-viewport.pos.x - viewport.rect.offx), (-viewport.pos.y - viewport.rect.offy))
      G.scale(sx, sy)

      -- (viewport rect offsets were calc'd based on actual window size, they need to be manually accounted for here as we pretend to use a viewport rect that counts the scaled pixes)
      local tx = -viewport.pos.x - (viewport.rect.offx / sx)
      local ty = -viewport.pos.y - (viewport.rect.offy / sy)
      G.translate(tx, ty)
    end

    mainDrawFunc(estore, res)

    if viewport then
      -- un-transform the view
      G.pop()
    end
  end
end

return {wrap = wrap}
