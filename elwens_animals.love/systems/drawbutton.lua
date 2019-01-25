require 'ecs.ecshelpers'
local G = love.graphics

local TwoPi = 2*math.pi

local function drawButton(e,button,res)
  local x,y = e.pos.x, e.pos.y
  if button.shape == "circle" then
    if button.kind == "hold" and e.timers and e.timers.holdbutton then
      local elapsed = button.holdtime - e.timers.holdbutton.t
      if elapsed > 0 then
        local a1=-math.pi/2
        local a2 = a1 + (elapsed / button.holdtime) * TwoPi
        love.graphics.setColor(1,1,1,0.5)
        love.graphics.arc("fill",x,y,button.radius,a1,a2,30)
      end

    elseif button and button.kind == "tap" and button.touchid ~= '' then
      local x,y = getPos(e)
      love.graphics.setColor(1,1,1,0.5)
      love.graphics.circle("fill",x,y,button.radius)
    end
  end
end

local function drawButtons(e,res)
  if not e.buttons then return end
  for _,button in pairs(e.buttons) do
    drawButton(e,button,res)
  end
end


return {
  drawButtons=drawButtons,
}
