local R={}

local Images = {}

function R.getImage(fname)
  local img = Images[fname]
  if not img then
    img = love.graphics.newImage(fname)
    Images[fname] = img
  end
  return img
end

function R.getFont(fname, size)
  -- TODO
  return nil
end

function R.getSound(fname)
  -- TODO
  return nil
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
--   duration_ms
function R.makePic(fname, img, rect)
  if fname and not img then
    img = R.getImage(fname)
  end
  if not fname and not img then
    error("ResourceLoader.makePic() requires filename or image object, but both were nil")
  end

  local x,y,w,h = unpack(rect or {})
  if x == nil then
    x = 0
    y = 0
  end
  if w == nil then
    w = img:getWidth()
    h = img:getHeight()
  end
  local quad = love.graphics.newQuad(x,y,w,h, img:getDimensions())
  local pic = {
    filename=fname,
    rect={x=x, y=y, w=w, h=h},
    image=img,
    quad=quad,
  }
  return pic
end

return R

