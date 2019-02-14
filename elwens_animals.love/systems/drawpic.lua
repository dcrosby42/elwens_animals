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

local function drawAnims(e,res)
  if e.anims then
      -- local anim = e.anim
    for _,anim in pairs(e.anims) do
      local animRes = res.anims[anim.id]
      if not animRes then error("No anim resource '".. anim.id .."'") end
      local timer = e.timers[anim.name]
      if timer then
        local picRes = animRes.getFrame(timer.t)
        if picRes == nil then
          error("anim id="..anim.id.." t="..timer.t.." NIL PIC? "..tdebug(animRes))
        end
        local x,y = getPos(e)
        local r = 0
        if anim.r then 
          r = r + anim.r
        end
        if e.pos.r then 
          r = r + e.anim.r
        end

        local offy = 0
        local offy = 0
        if anim.centerx ~= '' then
          offx = anim.centerx * picRes.rect.w
        else
          offx = anim.offx
        end
        if anim.centery ~= '' then
          offy = anim.centery * picRes.rect.h
        else
          offy = anim.offy
        end

        local sx = (picRes.sx or 1) * (animRes.sx or 1)
        local sy = (picRes.sy or 1) * (animRes.sy or 1)

        love.graphics.setColor(anim.color)
        love.graphics.draw(
          picRes.image,
          picRes.quad,
          x,y,
          r,     
          sx, sy,
          offx, offy)

        if anim.drawbounds then
          love.graphics.rectangle(
            "line",
            x-(sx*offx), y-(sy*offy),
            picRes.rect.w * sx, picRes.rect.h * sy)
        end
      else
        print("For eid="..e.eid.." anim.cid="..anim.cid.." NEED TIMER named '".. anim.name  .."'")
      end -- end if timer
    end
  end
end

return {
  drawPics=drawPics,
  drawAnims=drawAnims,
}
