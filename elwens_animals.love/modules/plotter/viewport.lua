local G = love.graphics

local Viewport = {
}

function Viewport:new()
  local o = {
    screen={w=G.getWidth(), h=G.getHeight()}, -- in pixels
    focus={x=0,y=0},   -- in space units
    scale={w=10,h=10}, -- pixels-per-space-unit
  }
  setmetatable(o, self)
  self.__index = self
  return o
end

function Viewport:transformPointToScreen(x,y)
  local x1 = (self.screen.w / 2) + (self.scale.w * (x - self.focus.x))
  local y1 = (self.screen.h / 2) - (self.scale.h * (y - self.focus.y))
  return x1,y1
end

function Viewport:transformPointsToScreen(pts)
  local res = {}
  for i=1,#pts,2 do
    res[i], res[i+1] = self:transformPointToScreen(pts[i], pts[i+1])
  end
  return res
end

function Viewport:transformPointToSpace(x,y)
  local x1 = ((x - (self.screen.w/2)) / self.scale.w) + self.focus.x
  local y1 = (-(y - (self.screen.h/2)) / self.scale.h) + self.focus.y
  return x1,y1
end

function Viewport:getSpaceExtents()
  local left,top = self:transformPointToSpace(0,0)
  local right,bottom = self:transformPointToSpace(self.screen.w, self.screen.h)
  return top,left,bottom,right
end

return Viewport
