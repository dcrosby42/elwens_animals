local DRAW_BOUNDS = false

local G = love.graphics

local function drawRects(e)
  if e.rects then
    local x, y = getPos(e)
    for _, rect in pairs(e.rects) do
      G.setColor(unpack(rect.color))
      G.rectangle(rect.style, x - rect.offx, y - rect.offy, rect.w, rect.h)
    end
  end
end

local function drawCircles(e)
  if e.circles then
    for _, circle in pairs(e.circles) do
      local x, y = getPos(e)
      x = x + circle.offx
      y = y + circle.offy
      G.setColor(unpack(circle.color))
      local style = "line"
      if circle.fill then
        style = "fill"
      end
      G.circle(style, x, y, circle.radius)
    end
  end
end

local function drawBounds(e)
  local x, y = getPos(e)
  G.setColor(1, 1, 1, 1)
  G.line(x - 5, y, x + 5, y)
  G.line(x, y - 5, x, y + 5)
  if e.bounds then
    local b = e.bounds
    G.rectangle("line", x - b.offx, y - b.offy, b.w, b.h)
  end
end

local function drawLabel(e)
  if not e.label then
    return
  end
  local label = e.label
  if label.font then
    local font = res.fonts[label.font]
    if font then
      G.setFont(font)
    end
  end
  G.setColor(unpack(label.color))
  local x, y = getPos(e)
  if label.height then
    if label.valign == "middle" then
      local halfLineH = G.getFont():getHeight() / 2
      y = y + (label.height / 2) - halfLineH
    elseif label.valign == "bottom" then
      local lineH = G.getFont():getHeight()
      y = y + label.height - lineH
    end
  end
  if label.width then
    local align = label.align
    if not align then
      align = "left"
    end
    G.printf(label.text, x - label.offx, y - label.offy, label.width, label.align)
  else
    G.print(label.text, x - label.offx, y - label.offy)
  end
end

local function draw(estore, res)
  estore:walkEntities(
    hasComps("debugDraw", "pos"),
    function(e)
      local drawBounds = false
      if DRAW_BOUNDS or drawBounds then
        drawBounds(e)
      end

      drawRects(e)

      drawCircles(e)

      drawLabel(e)
    end
  )
end

return {
  -- the main system:
  drawSystem = draw,
  -- for improvisational use:
  drawRects = drawRects,
  drawCircles = drawCircles,
  drawBounds = drawBounds,
  drawLabel = drawLabel,
  drawLabels = drawLabel
}
