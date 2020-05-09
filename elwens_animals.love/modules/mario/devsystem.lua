local Entities = require("modules.mario.entities")
local Contacts = require("systems.contacthelper")
local inspect = require("inspect")

local ZoomDefault = 3
local ZoomInc = 0.25
local MaxZoom = 7
local MinZoom = 0.25

local function zoomIn(e)
  local s = e.viewport.sx
  s = s + ZoomInc
  if s > MaxZoom then
    s = MaxZoom
  end
  e.viewport.sx = s
  e.viewport.sy = s
end
local function zoomOut(e)
  local s = e.viewport.sx
  s = s - ZoomInc
  if s < MinZoom then
    s = MinZoom
  end
  e.viewport.sx = s
  e.viewport.sy = s
end
local function zoomReset(e)
  e.viewport.sx = ZoomDefault
  e.viewport.sy = ZoomDefault
end

local BlockW = 16

local function breakSlab(e, contact, slabE, estore)
  local x, y = getPos(e)
  local slabw = slabE.rectangleShape.w
  local slabx = slabE.pos.x - (slabw / 2)
  local off = x - slabx
  local slabn = math.floor(slabw / BlockW)
  local b = math.floor(off / BlockW)
  if (b < 0) then
    b = 0
  elseif (b > (slabn - 1)) then
    b = slabn - 1
  end
  local dleft = b * BlockW
  local dright = (b + 1) * BlockW
  -- print(
  --   "x=" .. x .. " slabx=" .. slabx .. " off=" .. off .. " b=" .. b .. " dleft=" .. dleft .. " dright=" .. dright
  -- )
  do
    local y = slabE.pos.y
    local h = BlockW
    if b > 0 then
      local w = math.floor(b * BlockW)
      local x = slabx + w / 2
      -- print("(left side) new slab(parentE, slabE.orient x=" .. x .. " y=" .. y .. " w=" .. w .. " h=" .. h)
      Entities.slab(estore, slabE.orient, x, y, w, h)
    end
    if b < (slabn - 1) then
      local w = math.floor((slabn - 1 - b) * BlockW)
      local x = slabx + ((b + 1) * BlockW) + (w / 2)
      Entities.slab(estore, slabE.orient, x, y, w, h)
    -- print("(right side) new slab(parentE, slabE.orient x=" .. x .. " y=" .. y .. " w=" .. w .. " h=" .. h)
    end
    e:removeComp(contact)
    estore:destroyEntity(slabE)
  end
  return slabx + (b * BlockW)
end

local function doContacts(e, estore)
  local brokeBrickLeft
  for _, contact in pairs(e.contacts) do
    if Contacts.isUp(contact) and e.vel.dy > 0 then
      local otherE = estore:getEntity(contact.otherEid)
      if (otherE and otherE.slab) then
        brokeBrickLeft = breakSlab(e, contact, otherE, estore)
        break
      end
    end
  end
  if brokeBrickLeft then
    for _, contact in pairs(e.contacts) do
      local otherE = estore:getEntity(contact.otherEid)
      if otherE and otherE.tags and otherE.tags.brick then
        local brickLeft = otherE.pos.x - (BlockW / 2)
        if brickLeft == brokeBrickLeft then
          estore:destroyEntity(otherE)
          break
        end
      end
    end
  end

  -- for _, contact in ipairs(Contacts.getUpContacts(e)) do
  --   if e.vel.dy <= 0 then
  --     return
  --   end
  --   local slabE = estore:getEntity(contact.otherEid)
  --   if not (slabE and slabE.slab) then
  --     return
  --   end
  -- end
end

return function(estore, input, res)
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

  estore:walkEntities(
    hasComps("blockbreaker", "contact"),
    function(e)
      doContacts(e, estore)
    end
  )
end
