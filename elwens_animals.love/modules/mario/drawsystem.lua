local PhysicsDraw = require "systems.physicsdraw"
local DrawPic = require "systems.drawpic"
local DebugDraw = require "systems.debugdraw"
local DrawButton = require "systems.drawbutton"

local G = love.graphics

local SkyColor = {.6, .8, 1} -- TODO move to viewport?

local function draw(estore, res)
  -- -- Find the viewport
  -- local viewport = estore:getEntityByName("viewport")
  -- if not viewport then
  --   return
  -- end

  -- -- Transform the view
  -- G.push()
  -- G.translate(-viewport.pos.x - viewport.rect.offx, -viewport.pos.y - viewport.rect.offy)
  -- -- TODO: fix scale? G.scale(viewport.sx, viewport.sy)

  G.setBackgroundColor(SkyColor)

  estore:walkEntities(
    hasComps("pic", "pos"),
    function(e)
      DrawPic.drawPics(e, res)
    end
  )
  estore:walkEntities(
    hasComps("anim", "pos"),
    function(e)
      DrawPic.drawAnims(e, res)
      -- (print mario's "mode" string near his sprite for debugging)
      -- if e.mario then
      --   love.graphics.print(e.mario.mode,e.pos.x+15,e.pos.y+30)
      -- end
    end
  )

  -- PhysicsDraw.drawEntities(viewportE, estore:getCache("physics"))
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
