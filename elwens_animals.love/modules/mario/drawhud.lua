local G = love.graphics

local function drawText(opts)
  assert(opts.text, "drawText requires 'text'")
  local x = opts.x or 0
  local y = opts.y or 0
  local wasR, wasG, wasB, wasA = G.getColor()
  local wasFont = G.getFont()

  if opts.font then G.setFont(opts.font) end

  -- draw drop shadow
  if opts.shadow and opts.shadow.color then
    local color = opts.shadow.color
    local offx = opts.shadow.offx or opts.shadow.off or 3
    local offy = opts.shadow.offy or opts.shadow.off or 3
    G.setColor(unpack(color))
    G.print(opts.text, x + offx, y + offy)
    G.setColor(wasR, wasG, wasB, wasA)
  end

  -- draw fore text
  if opts.color then G.setColor(unpack(opts.color)) end
  G.print(opts.text, x, y)

  -- reset color and font
  G.setColor(wasR, wasG, wasB, wasA)
  G.setFont(wasFont)
end

return function(estore, res)

  local mario = estore:getEntityByName("mario")
  local coins = mario.vars.coins.value or 0
  local points = mario.vars.points.value or 0

  drawText({
    text = string.upper("Player 1    Coins: " .. coins .. " Points: " .. points),
    font = res.fonts.narpassword_normal,
    color = {1, 1, 1},
    shadow = {color = {0.5, 0.5, 0.5, 0.5}},
  })
end

