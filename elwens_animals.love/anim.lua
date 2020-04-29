local Debug = (require("mydebug")).sub("Anim", false, false)
local R = require "resourceloader"

local Anim = {}

-- Assume the image at fname has left-to-right, top-to-bottom
-- uniform sprite frames of w-by-h.
-- opts: (optional) Passed to makePic(). {sx, sy, duration, frameNum}.  Though frameNum doesn't make much sense here.
function Anim.simpleSheetToPics(img, w, h, opts)
  opts = opts or {}
  if type(img) == "string" then
    Debug.println(img)
    img = R.getImage(img)
  end
  local imgw = img:getWidth()
  local imgh = img:getHeight()
  Debug.println("imgw=" .. imgw .. " imgh=" .. imgh)

  local pics = {}

  for j = 1, imgh / h do
    local y = (j - 1) * h
    for i = 1, imgw / w do
      local x = (i - 1) * w
      local pic = R.makePic(nil, img, {x = x, y = y, w = w, h = h}, opts)
      table.insert(pics, pic)
      Debug.println("Added pic.rect x=" .. x .. " y=" .. y .. " w=" .. w .. " h=" .. h)
    end
  end
  return pics
end

function Anim.makeFrameLookup(anim, opts)
  opts = opts or {}
  return function(t)
    if not opts.extend then
      t = t % anim.duration
    end
    local acc = 0
    for i = 1, #anim.pics do
      acc = acc + anim.pics[i].duration
      if t < acc then
        return anim.pics[i]
      end
    end
  end
end

function Anim.recalcDuration(anim)
  local d = 0
  for i = 1, #anim.pics do
    d = d + anim.pics[i].duration
  end
  anim.duration = d
end

function Anim.makeSimpleAnim(pics, frameDur)
  local anim = {
    pics = {},
    duration = (#pics * frameDur)
  }
  for i = 1, #pics do
    table.insert(anim.pics, shallowclone(pics[i]))
    -- stamp each frame w duration and frame#
    anim.pics[i].frameNum = i
    anim.pics[i].duration = frameDur
  end
  -- make a frame getter func for this anim
  anim.getFrame = Anim.makeFrameLookup(anim)

  return anim
end

function Anim.makeSinglePicAnim(pic, framwDur)
  frameDur = frameDur or 1
  pic = shallowclone(pic)
  pic.frameNum = 1
  pic.duration = frameDur
  local anim = {
    pics = {pic},
    duration = pic.duration
  }
  -- make a frame getter func for this anim
  anim.getFrame = function(t)
    return pic
  end

  return anim
end

return Anim
