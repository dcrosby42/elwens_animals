local G = love.graphics

local PhysicsDraw = require 'systems.physicsdraw'
local DrawPic = require 'systems.drawpic'
local DrawButton = require 'systems.drawbutton'

local skyColor = {.6, .8, 1} -- TODO move to viewport?

local function draw(estore,res)
  -- Find the viewport
  -- local viewportE = estore:getEntityByName("viewport")
  -- if not viewportE then return end
  -- local viewport = viewportE.viewport
  --
  -- -- Transform the view 
  -- G.push()
  -- G.translate(-viewport.x, -viewport.y)
  -- G.scale(viewport.sx, viewport.sy)

  G.setBackgroundColor(skyColor)

  local viewportE = estore
  viewportE:walkEntities(hasComps('pic','pos'), function(e)
    DrawPic.drawPics(e,res)
  end)
  viewportE:walkEntities(hasComps('anim','pos'), function(e)
    DrawPic.drawAnims(e,res)
  end)

  -- PhysicsDraw.drawEntities(viewportE, estore:getCache('physics'))

  -- G.pop()
  --
  -- local uiE = estore:getEntityByName("ui")
  -- if uiE then
  --   uiE:walkEntities(hasComps('pic','pos'), function(e)
  --     DrawButton.drawButtons(e,res)
  --     DrawPic.drawPics(e,res)
  --   end)
  -- end
end


return draw
