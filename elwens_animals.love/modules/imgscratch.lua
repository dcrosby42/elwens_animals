local Debug = require 'mydebug'
local R = require 'resourceloader'
local A = require 'animalpics'
local M={}

function drawAllAnimals()
  local sx=0.5
  local sy=0.5
  local r=0

  local x=0
  local y=0
  local rowHeight=20

  for i,animal in ipairs(A.animals) do
    local img = R.getImage(animal.file)
    local w = img:getWidth()
    local h = img:getHeight()
    -- love.graphics.draw(img, x,y, r, sx, sy, w/2, h/2)
    love.graphics.draw(img, x,y, r, animal.sizeX, animal.sizeY, 0,0)
  
    -- local name = A.names[i]
    love.graphics.print(animal.name,x,y)


    -- update location for next img:
    x = x + (w * sx)
    if rowHeight < (h * sy) then
      rowHeight = h * sy
    end
    if x+w > love.graphics.getWidth() then
      x = 0
      y = y + rowHeight
      rowHeight = 20
    end
  end

end

function M.newWorld()
  return {}
end

function M.updateWorld(world,action,res)
  if action.type == "touch" or action.type=="mouse" and action.state == "pressed" then
    Debug.println("TOUCH")
    local src = love.audio.newSource("data/sounds/fx/tng_viewscreen_on.mp3", "static")
    src:setVolume(1)
    src:play()
  end
  return world
end

function M.drawWorld(world)
  drawAllAnimals()
  -- love.graphics.rectangle("line",0,0,50,50)
end

return M
