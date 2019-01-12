local G = love.graphics

local function draw(d, viewport)
  local pts = {}
  if d.type == "series" then
    pts = viewport:transformPointsToScreen(d.pts)
  elseif d.type == "fn" then
    local top,left,bottom,right = viewport:getSpaceExtents()
    local int = d.step or 0.1
    left = math.floor(left / int) * int
    right = math.ceil(right / int) * int
    local i = 1
    for x=left,right,int do
      pts[i] = x
      pts[i+1] = d.fn(x)
      i = i + 2
    end
    pts = viewport:transformPointsToScreen(pts)
  else
    error("Dunnot how to draw type of "..d.type)
  end

  if d.style then
    if d.style.color then
      G.setColor(unpack(d.style.color))
    end
    if d.style.pointSize then
      G.setPointSize(d.style.pointSize)
    end
  end

  if d.kind == "points" or d.kind == "pointsAndLines" then
    if d.kind == "pointsAndLines" then
      G.line(pts)
    end
    G.points(pts)
  elseif d.kind == "line" then
    G.line(pts)
  else
    error("dunno how to draw kind of drawable '"..d.kind.."'")
  end

  G.setColor(1,1,1)
  G.setPointSize(1)
end

return draw
