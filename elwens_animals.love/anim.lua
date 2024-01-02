local Debug = (require('mydebug')).sub("Anim",false,false)
local R = require 'resourceloader'

local Anim = {}

-- Assume the image at fname has left-to-right, top-to-bottom
-- uniform sprite frames of w-by-h.
function Anim.simpleSheetToPics(img,w,h)
  if type(img) == "string" then
    Debug.println(img)
    img = R.getImage(img)
  end
  local imgw = img:getWidth()
  local imgh = img:getHeight()
  Debug.println("imgw="..imgw.." imgh="..imgh)

  local pics = {}

  for j=1,imgh/h do
    local y=(j-1)*h
    for i=1,imgw/w do
      local x=(i-1)*w
      local pic = R.makePic(nil,img,{x=x,y=y,w=w,h=h})
      table.insert(pics, pic)
      Debug.println("Added pic.rect x="..x.." y="..y.." w="..w.." h="..h)
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
    print("anim? "..tdebug(anim))
  end
end

function Anim.makeSimpleAnim(pics, frameDur)
  pics = shallowclone(pics)
  
  local duration = 0
  for _, pic in ipairs(pics) do
    pic.frameNum = i
    if not pic.duration then
      pic.duration = frameDur
    end
    duration = duration + pic.duration
  end

  local anim = {
    pics=pics,
    duration=duration,
  }
  anim.getFrame = Anim.makeFrameLookup(anim)

  return anim
end

return Anim
