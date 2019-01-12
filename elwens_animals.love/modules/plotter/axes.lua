local A = {}

-- Creates two separate series of pts in form {x1,y1, x2,y2 ...}
-- First is for the X axis and 2nd is Y axis.
-- Just enough points are generated on each axis to cover the current given viewing area.
-- All in and out values are in space units (not screen units)
function A.generateXYAxes(top,left,bottom,right)
  local intx = 1
  left = math.floor(left / intx) * intx
  right = math.ceil(right / intx) * intx
  local inty = 1
  top= math.ceil(top / inty) * inty
  bottom = math.floor(bottom / inty) * inty

  local y = 0
  local xpts = {}
  local i = 1
  for x=left,right,intx do
    xpts[i] = x
    xpts[i+1] = y
    i = i + 2
  end

  local x = 0
  local ypts = {}
  i = 1
  for y=bottom,top,inty do
    ypts[i] = x
    ypts[i+1] = y
    i = i + 2
  end
  return xpts,ypts
end

return A
