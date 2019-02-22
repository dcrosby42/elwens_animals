require 'ecs.ecshelpers'

local G = love.graphics

local function drawEntity(e,cache)
  if e.body.debugDraw then
    local obj = cache[e.body.cid]
    if obj then
      G.setColor(e.body.debugDrawColor)
      G.setLineWidth(1)
      for _,shape in ipairs(obj.shapes) do
        if shape:type() == "CircleShape" then
          local x,y = obj.body:getWorldPoints(shape:getPoint())
          local r = shape:getRadius()
          G.circle("line", x,y,r)
        elseif shape:type() == "ChainShape" then
          G.line(obj.body:getWorldPoints(shape:getPoints()))
        else
          G.polygon("line", obj.body:getWorldPoints(shape:getPoints()))
        end
        G.points(obj.body:getWorldPoint(0,0))
      end
    else
      print("!! physicsdraw: No physics object in cache for body.cid="..e.body.cid.." .kind=".. e.body.kind .." in entity eid="..e.eid)
    end
  end
end

local function drawEntities(parent,cache)
  parent:walkEntities(hasComps('body'), function(e)
    drawEntity(e,cache)
  end)
end

local system =  defineDrawSystem({'physicsWorld'}, function(physWorldE,estore,res)
  drawEntities(estore,estore:getCache('physics'))
end)

return {
  drawSystem=system,
  drawEntity=drawEntity,
  drawEntities=drawEntities,
}
