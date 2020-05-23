local Entities = require("modules.mario.entities")

local ZoomDefault = 3
local ZoomInc = 0.25
local MaxZoom = 7
local MinZoom = 0.25

local function zoomIn(e)
  local s = e.viewport.sx
  s = s + ZoomInc
  if s > MaxZoom then s = MaxZoom end
  e.viewport.sx = s
  e.viewport.sy = s
end
local function zoomOut(e)
  local s = e.viewport.sx
  s = s - ZoomInc
  if s < MinZoom then s = MinZoom end
  e.viewport.sx = s
  e.viewport.sy = s
end
local function zoomReset(e)
  e.viewport.sx = ZoomDefault
  e.viewport.sy = ZoomDefault
end

local function uiZoom(estore, input, res)
  for _, evt in ipairs(input.events) do
    if evt.type == "keyboard" and evt.state == "pressed" then
      if evt.key == "=" and evt.shift then
        local e = estore:getEntityByName("viewport")
        zoomIn(e)
      elseif evt.key == "=" then
        local e = estore:getEntityByName("viewport")
        zoomReset(e)
      elseif evt.key == "-" then
        local e = estore:getEntityByName("viewport")
        zoomOut(e)
      elseif evt.key == "space" then
        local blockE = Entities.kerblock(estore)
        blockE.vel.dx = 300
      end
    end
  end
end

local bumpAnimLen = 0.2
local bumpSpeed = -100
local bumpDispl = 5
local function bumpAnim(estore, input, res)
  estore:walkEntities(hasComps('bumpAnim', 'pos'), function(e)
    e.bumpAnim.t = e.bumpAnim.t + input.dt

    if e.bumpAnim.t > bumpAnimLen then
      e.pos.y = e.bumpAnim.orig
      e:removeComp(e.bumpAnim)
    else
      local dy = bumpSpeed * input.dt
      if e.bumpAnim.t > bumpAnimLen / 2 then dy = -dy end
      e.pos.y = e.pos.y + dy
    end

  end)
end

return function(estore, input, res)
  uiZoom(estore, input, res)
  bumpAnim(estore, input, res)
end
