local R = {}

local Images = {}
local ImageDatas = {}
local Sounds = {}

function R.getImageData(fname)
  local imgdata = ImageDatas[fname]
  if not imgdata then
    imgdata = love.image.newImageData(fname)
    ImageDatas[fname] = imgdata
  end
  return imgdata
end

function R.getImage(fname)
  local img = Images[fname]
  if not img then
    local imgdata = R.getImageData(fname)
    img = love.graphics.newImage(imgdata)
    Images[fname] = img
  end
  return img
end

function R.getFont(fname, size)
  -- TODO
  return nil
end

function R.getSoundData(fname)
  local sdata = Sounds[fname]
  if not sdata then
    sdata = love.sound.newSoundData(fname)
    Sounds[fname] = sdata
  end
  return sdata
end

-- Args:
--   fname:(optional) filename. If omitted, img MUST be given.
--   img: (optional) image object.  If nil, R.getImage will be used w fname param to get it.
--   rect: (optional) {x=,y=,w=,h=} rectangle defining a Quad. If omitted, Quad will be the whole img dimensions.
--
-- Returned 'pic' structure:
--   filename string
--   image Image
--   quad   Quad
--   rect   {x,y,w,h}
--   duration
--   sx
--   sy
function R.makePic(fname, img, rect, opts)
  rect = rect or {}
  opts = opts or {}

  if fname and not img then
    img = R.getImage(fname)
  end
  if not fname and not img then
    error("ResourceLoader.makePic() requires filename or image object, but both were nil")
  end

  local x, y, w, h
  if rect and rect.x then
    x = rect.x
    y = rect.y
    w = rect.w
    h = rect.h
  else
    x, y, w, h = unpack(rect)
  end
  if not x then
    x = 0
    y = 0
  end
  if w == nil then
    w = img:getWidth()
    h = img:getHeight()
  end

  local quad = love.graphics.newQuad(x, y, w, h, img:getDimensions())
  local pic = {
    filename = fname,
    rect = {x = x, y = y, w = w, h = h},
    image = img,
    quad = quad,
    duration = (opts.duration or 1 / 60),
    sx = (opts.sx or 1),
    sy = (opts.sy or 1)
  }
  return pic
end

return R
