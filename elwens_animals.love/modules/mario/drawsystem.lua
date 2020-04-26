local PhysicsDraw = require "systems.physicsdraw"
local DrawPic = require "systems.drawpic"
local DebugDraw = require "systems.debugdraw"
local DrawButton = require "systems.drawbutton"
local MarioMapSystem = require "modules.mario.mariomapsystem"
local SW = MarioMapSystem.SectorW
local SH = MarioMapSystem.SectorH
local Res = require "modules.mario.resources"

local G = love.graphics

local SkyColor = {.6, .8, 1} -- TODO move to viewport?

local function draw(estore, res)
  G.setBackgroundColor(SkyColor)

  estore:walkEntities(
    hasComps("mariomap"),
    function(e)
      G.setColor(1, 0.8, 0.8)
      for i = 1, #e.mariomap.sectors do
        local s = e.mariomap.sectors[i]
        local x = s[1] * SW
        local y = s[2] * SH
        G.setColor(1, 0.7, 0.7)
        G.rectangle("line", x, y, SW, SH)
        G.setColor(0.8, 0.5, 0.5)
        G.print("(" .. s[1] .. "," .. s[2] .. ")", x, y)
      end
    end
  )

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
