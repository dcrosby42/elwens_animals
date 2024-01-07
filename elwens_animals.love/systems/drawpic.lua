require 'ecs.ecshelpers'
local G = love.graphics

local function drawPic(e,pic,res)
  local x,y = e.pos.x,e.pos.y
  local r = e.pos.r
  if pic.r then r = r + pic.r end
  local picRes = res.pics[pic.id]
  if not picRes then
    error("No pic resource '".. pic.id .."'")
  end

  local offx = 0
  local offy = 0
  if pic.centerx ~= '' then
    -- offx = pic.centerx * picRes:getWidth() * pic.sx
    offx = pic.centerx * picRes.rect.w
  else
    offx = pic.offx
  end
  if pic.centery ~= '' then
    -- offy = pic.centery * picRes:getHeight() * pic.sy
    offy = pic.centery * picRes.rect.h
  else
    offy = pic.offy
  end

  G.setColor(pic.color)

  G.draw(
    picRes.image,
    picRes.quad,
    x,y,
    r,     
    pic.sx, pic.sy,
    offx, offy)

  if pic.drawbounds then
    G.rectangle(
      "line",
      x-(pic.sx*offx), y-(pic.sy*offy),
      picRes.rect.w * pic.sx, picRes.rect.h * pic.sy)
  end
end

local function drawPics(e,res)
  if not e.pics then return end
  for _,pic in pairs(e.pics) do
    drawPic(e,pic,res)
  end
end

return {
  drawPics=drawPics,
}
