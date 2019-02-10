local Vec = require 'vector-light'
local MoveFact = 0.2


return defineUpdateSystem(hasComps('viewportTarget','pos'),function(e,estore,input,res)
  -- Find the lead creature
  local animals = {}
  estore:walkEntities(hasTag('animal'), function(animal) 
    animals[#animals+1] = animal
  end)
  if #animals == 0 then return end
  table.sort(animals, function(a,b) return a.pos.x > b.pos.x end)

  local lx,ly = 0,0
  local n = math.min(3,#animals)
  for i=1,n do
    lx = lx + animals[i].pos.x
    ly = ly + animals[i].pos.y
  end
  lx = lx / n
  ly = ly / n
  
  -- Vector from viewport target's current pos and the desired pos:
  -- local leader = animals[1]
  -- local lx,ly = leader.pos.x,leader.pos.y
  local dx,dy = Vec.sub(lx,ly, e.pos.x,e.pos.y)

  -- Calc a speed based on how far off we are
  local l = Vec.len(dx,dy)
  local s = l * MoveFact
  -- Move the position basd on the calcs:
  local mx,my = Vec.mul(s, Vec.normalize(dx,dy))
  e.pos.x = e.pos.x + mx
  e.pos.y = e.pos.y + my

  -- --
  -- e.viewportTarget.x = e.pos.x
  -- e.viewportTarget.y = e.pos.y
end)
