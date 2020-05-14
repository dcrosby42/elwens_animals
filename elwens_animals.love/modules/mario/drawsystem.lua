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

local function drawMarioMap(e, res)
  if e.debugDraw and e.debugDraw.on then
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
end

local function draw(estore, res)
  G.setBackgroundColor(SkyColor)

  estore:walkEntities(nil, function(e)
    if e.mariomap then
      drawMarioMap(e, res)
    elseif e.pic and e.pos then
      DrawPic.drawPics(e, res)
    elseif e.anim and e.pos then
      DrawPic.drawAnims(e, res)
    end
  end)

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
