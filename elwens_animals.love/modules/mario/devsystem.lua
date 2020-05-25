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
  estore:walkEntities(hasComps('bumpanim', 'pos'), function(e)
    e.bumpanim.t = e.bumpanim.t + input.dt

    if e.bumpanim.t > bumpAnimLen then
      e.pos.y = e.bumpanim.orig
      e:removeComp(e.bumpanim)
    else
      local dy = bumpSpeed * input.dt
      if e.bumpanim.t > bumpAnimLen / 2 then dy = -dy end
      e.pos.y = e.pos.y + dy
    end

  end)
end

local coinBumpAnimLen = 0.58
local coinBumpInitVel = -300
local coinBumpGrav = 9.8 * 100
local function coinBumpAnim(estore, input, res)
  local toKill
  estore:walkEntities(hasComps('coinbumpanim', 'pos'), function(e)
    local anim = e.coinbumpanim
    anim.t = anim.t + input.dt

    if anim.t > coinBumpAnimLen then
      e.pos.y = anim.orig
      e:removeComp(anim)
      toKill = e
    else
      e.pos.y = anim.orig + (coinBumpInitVel * anim.t) +
                    (0.5 * coinBumpGrav * math.pow(anim.t, 2))
    end

  end)
  if toKill then toKill:destroy() end
end

return function(estore, input, res)
  uiZoom(estore, input, res)
  bumpAnim(estore, input, res)
  coinBumpAnim(estore, input, res)
end
