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
local BlockW2 = BlockW / 2

local function breakSlabH(e, contact, slabE, estore)
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
  local y = slabE.pos.y
  do
    local h = BlockW
    if b > 0 then
      local w = math.floor(b * BlockW)
      local x = slabx + w / 2
      Entities.slab(estore, slabE.orient, x, y, w, h)
    end
    if b < (slabn - 1) then
      local w = math.floor((slabn - 1 - b) * BlockW)
      local x = slabx + ((b + 1) * BlockW) + (w / 2)
      Entities.slab(estore, slabE.orient, x, y, w, h)
    end
    e:removeComp(contact)
    estore:destroyEntity(slabE)
  end
  return {
    x = (slabx + (b * BlockW)) + BlockW2,
    y = y
  }
end
local function breakSlabV(e, contact, slabE, estore)
  local x, y = getPos(e)
  local slabh = slabE.rectangleShape.h
  local slabn = math.floor(slabh / BlockW)
  local slabtop = slabE.pos.y - (slabh / 2)
  local contactOffset = y - slabtop
  local b = math.floor(contactOffset / BlockW)
  if (b < 0) then
    b = 0
  elseif (b > (slabn - 1)) then
    b = slabn - 1
  end
  local dtop = b * BlockW
  local dbottom = (b + 1) * BlockW
  local slabx = slabE.pos.x
  do
    if b > 0 then
      -- figure out the "top leavins"
      local h = math.floor(b * BlockW)
      local slaby = slabtop + h / 2
      Entities.slab(estore, slabE.slab.orient, slabx, slaby, BlockW, h)
    end
    if b < (slabn - 1) then
      -- figure out the "bottom leavins"
      local h = math.floor((slabn - 1 - b) * BlockW)
      local slaby = slabtop + ((b + 1) * BlockW) + (h / 2)
      Entities.slab(estore, slabE.slab.orient, slabx, slaby, BlockW, h)
    end
    e:removeComp(contact)
    estore:destroyEntity(slabE)
  end
  return {
    x = slabx,
    y = (slabtop + (b * BlockW)) + BlockW2
  }
end
local function breakSlab(e, contact, slabE, estore)
  if slabE.slab.orient == "h" then
    return breakSlabH(e, contact, slabE, estore)
  elseif slabE.slab.orient == "v" then
    return breakSlabV(e, contact, slabE, estore)
  end
end

local function blockPunch(e, contact, estore, input, res)
  local otherE = estore:getEntity(contact.otherEid)
  if (otherE and otherE.slab) then
    local punched = breakSlab(e, contact, otherE, estore)
    local punchedE
    estore:seekEntity(
      function(e)
        return e.tags and e.tags.brick and e.pos.x == punched.x and e.pos.y == punched.y
      end,
      function(e)
        punchedE = e
        return true
      end
    )
    if punchedE then
      estore:destroyEntity(punchedE)
      e:newComp(
        "sound",
        {
          sound = "breakblock"
        }
      )
    end
  end
end

local function doContacts(e, estore, input, res)
  local brokeBrickLeft
  for _, contact in pairs(e.contacts) do
    if Contacts.isUp(contact) and e.vel.dy <= 0 then
      blockPunch(e, contact, estore, input, res)
    end
  end
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
      doContacts(e, estore, input, res)
    end
  )
end
