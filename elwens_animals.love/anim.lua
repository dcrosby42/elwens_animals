local R = require 'resourceloader'

local Anim = {}

-- Assume the image at fname has left-to-right, top-to-bottom
-- uniform sprite frames of w-by-h.
function Anim.simpleSheetToPics(img,w,h)
  local imgw = img:getWidth()
  local imgh = img:getHeight()

  local pics = {}

  for i=1,imgw/w do
    local x=(i-1)*w
    for j=1,imgh/h do
      local y=(j-1)*h
      local pic = R.makePic(fname,img,{x=x,y=y,w=w,h=h})
      table.insert(pics, pic)
    end
  end
  return pics
end

function Anim.makeFrameLookup(anim,opts)
  opts = opts or {}
  return function(t)
    if not opts.extend then
      t = t % anim.duration
    end
    local acc = 0
    for i=1,#anim.pics do
      acc = acc + anim.pics[i].duration
      if t < acc then
        return anim.pics[i]
      end
    end
  end
end

function Anim.makeSimpleAnim(pics, frameDur)
  local anim = {
    pics=shallowclone(pics),
    duration=(#pics * frameDur),
  }
  -- stamp each frame w duration
  for i=1,#anim.pics do
    anim.pics[i].frameNum = i
    anim.pics[i].duration = frameDur
  end
  -- make a frame getter func for this anim
  anim.getFrame = Anim.makeFrameLookup(anim) 

  return anim
end

return Anim
