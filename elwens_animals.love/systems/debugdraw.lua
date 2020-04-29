local DRAW_BOUNDS = true

local G = love.graphics

local function drawRects(e)
  if e.debugDraw.rects and e.rects then
    local x, y = getPos(e)
    for _, rect in pairs(e.rects) do
      G.setColor(unpack(rect.color))
      G.rectangle(rect.style, x - rect.offx, y - rect.offy, rect.w, rect.h)
    end
  end
end

local function drawCircles(e)
  if e.debugDraw.circles and e.circles then
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

local function drawPos(e)
  if e.debugDraw.pos then
    local x, y = getPos(e)
    -- print(e.name.name)
    G.setColor(e.debugDraw.color)
    -- draw crosshairs at pos:
    G.line(x - 2, y, x + 2, y)
    G.line(x, y - 2, x, y + 2)
  end
end

local function drawBounds(e)
  if e.debugDraw.bounds then
    local x, y = getPos(e)
    print(e.name.name)
    G.setColor(e.debugDraw.color)
    -- draw crosshairs at pos:
    G.line(x - 2, y, x + 2, y)
    G.line(x, y - 2, x, y + 2)
    if e.bounds then
      local b = e.bounds
      G.rectangle("line", x - b.offx, y - b.offy, b.w, b.h)
    end
  end
end

local function drawLabel(e, label)
  if e.debugDraw.labels then
    if not label then
      if e.label then
        label = e.label
      else
        return
      end
    end
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
end

local function drawLabels(e)
  if e.debugDraw.labels then
    if e.labels then
      for _, label in pairs(e.labels) do
        drawLabel(e, label)
      end
    end
  end
end

local function draw(estore, res)
  estore:walkEntities(
    hasComps("debugDraw", "pos"),
    function(e)
      if e.debugDraw.on then
        drawRects(e)

        drawCircles(e)

        drawLabels(e)

        drawBounds(e)

        drawPos(e)
      end
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
  drawLabels = drawLabels
}
