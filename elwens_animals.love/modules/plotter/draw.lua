local G = love.graphics

local function draw(d, viewport)
  local pts = viewport:transformPointsToScreen(d.pts)

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
  else
    error("dunno how to draw kind of drawable '"..d.kind.."'")
  end

  G.setColor(1,1,1)
  G.setPointSize(1)
end

return draw
