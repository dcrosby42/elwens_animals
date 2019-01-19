local G = love.graphics

local PhysicsDraw = require 'systems.physicsdraw'

local topColor = {.5, .6, .7}
local groundColor = {1,1,1}
local skyColor = {.6, .8, 1}

local function draw(estore,res)
  -- Get the viewport
  local viewport
  estore:seekEntity(hasName('viewport'),function(e)
    viewport = e.viewport
    return true
  end)
  if not viewport then return end

  -- Transform the view 
  G.push()
  G.translate(-viewport.x, -viewport.y)
  G.scale(viewport.sx, viewport.sy)

  G.setBackgroundColor(skyColor)

  -- Draw the map slices
  local bottom = viewport.y + viewport.h
  estore:walkEntities(hasComps('slice','chainShape','pos'),function(e)
    G.setColor(groundColor)
    for i=1,#e.chainShape.vertices-2, 2 do
      G.polygon('fill',
        e.chainShape.vertices[i],
        e.chainShape.vertices[i+1],

        e.chainShape.vertices[i+2],
        e.chainShape.vertices[i+3],

        e.chainShape.vertices[i+2],
        viewport.y + viewport.h,

        e.chainShape.vertices[i],
        viewport.y + viewport.h
      )
    end

    -- Draw the chain line
    G.setLineWidth(4)
    G.setColor(topColor)
    G.line(e.chainShape.vertices)
  end)

  PhysicsDraw.drawEntities(estore)

  G.pop()
end


return draw
