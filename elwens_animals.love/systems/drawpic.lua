require 'ecs.ecshelpers'
local G = love.graphics

local M = {}

function M.drawEntity(e,res)
  local pic = e.pic
  local x,y = getPos(e)
  local r = 0
  if pic.r then 
    r = r + pic.r
  end
  if e.pos.r then 
    r = r + e.pos.r
  end
  local picRes = res.pics[pic.id]
  if not picRes then
    error("No pic resource '".. pic.id .."'")
  end

  local offy = 0
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

  G.setColor(unpack(pic.color))

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

  if e.names and e.names.mouthcoal_1 then
    Debug.noteObj({e.eid,'mouth1'},{picRes=tostring(picRes), x=x,y=y,r=r,sx=picsx,sy=pic.sy,offx=offx,offy=offy,color=colorstring(pic.color)})
  end

end

return M
