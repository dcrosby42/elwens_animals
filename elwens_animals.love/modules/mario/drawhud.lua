local G = love.graphics

return function(estore, res)

  local mario = estore:getEntityByName("mario")
  local coins = mario.vars.coins.value or 0
  local points = mario.vars.points.value or 0
  G.setColor(1, 1, 1, 1)
  G.print("Player 1    Coins: " .. coins .. " Points: " .. points)
end

