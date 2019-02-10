local G = love.graphics

local PhysicsDraw = require 'systems.physicsdraw'
local DrawPic = require 'systems.drawpic'
local DrawButton = require 'systems.drawbutton'

local topColor = {.5, .6, .7}
local groundColor = {1,1,1}
local skyColor = {.6, .8, 1}

local function draw(estore,res)
  -- Find the viewport
  local viewportE = estore:getEntityByName("viewport")
  if not viewportE then return end
  local viewport = viewportE.viewport

  -- Transform the view 
  G.push()
  G.translate(-viewport.x, -viewport.y)
  G.scale(viewport.sx, viewport.sy)

  G.setBackgroundColor(skyColor)

  -- Draw the map slices
  local bottom = viewport.y + viewport.h
  viewportE:walkEntities(hasComps('slice','chainShape','pos'),function(e)
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

  viewportE:walkEntities(hasComps('pic','pos'), function(e)
    DrawPic.drawPics(e,res)
  end)

  PhysicsDraw.drawEntities(viewportE, estore:getCache('physics'))

  G.pop()

  local uiE = estore:getEntityByName("ui")
  if uiE then
    uiE:walkEntities(hasComps('pic','pos'), function(e)
      DrawButton.drawButtons(e,res)
      DrawPic.drawPics(e,res)
    end)
  end
end


return draw
