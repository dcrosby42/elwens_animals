local R = {}

local Images = {}
local ImageDatas = {}

R.getImageData = memoize1(love.image.newImageData)

R.getImage =
  memoize1(
  function(fname)
    return love.graphics.newImage(R.getImageData(fname))
  end
)

function R.getFont(fname, size)
  -- TODO
  return nil
end

R.getSoundData = memoize1(love.sound.newSoundData)

-- Returns a streaming Source
R.getMusicSource =
  memoize1(
  function(fname)
    return love.audio.newSource(fname, "stream")
  end
)

-- Args:
--   fname:(optional) filename. If omitted, img MUST be given.
--   img: (optional) image object.  If nil, R.getImage will be used w fname param to get it.
--   rect: (optional) {x=,y=,w=,h=} rectangle defining a Quad. If omitted, Quad will be the whole img dimensions.
--   opts: (optional) {sx, sy, duration, frameNum}
--
-- Returned 'pic' structure:
--   filename string
--   image Image
--   quad   Quad
--   rect   {x,y,w,h}
--   duration (default 1/60) (cheating a bit, this is for using Pic inside an Anim)
--   frameNum (default 1) (cheating a bit, this is for using Pic inside an Anim)
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
    frameNum = (opts.frameNum or 1),
    sx = (opts.sx or 1),
    sy = (opts.sy or 1)
  }
  return pic
end

return R
