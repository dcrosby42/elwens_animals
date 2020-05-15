local Entities = require("modules.mario.entities")
local Debug = require("mydebug").sub("Slab", true, true)
local inspect = require("inspect")
local Const = require("modules.mario.const")
local BlockW = Const.BlockW
local BlockW2 = BlockW / 2
local BlockW4 = BlockW / 4

local Slab = {}

function Slab.calcPunchedLoc(e, slabE)
  local x, y = getPos(e)
  if slabE.slab.orient == 'h' then
    -- horizontal slab
    local slabw = slabE.rectangleShape.w
    local slableft = slabE.pos.x - (slabw / 2)
    local off = x - slableft
    local slabn = math.floor(slabw / BlockW)
    local b = math.floor(off / BlockW)
    if (b < 0) then
      b = 0
    elseif (b > (slabn - 1)) then
      b = slabn - 1
    end
    local punchedX = slableft + (b * BlockW) + BlockW2
    local punchedY = slabE.pos.y
    return punchedX, punchedY
  else
    -- vertical slab
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
    local punchedX = slabE.pos.x
    local punchedY = slabtop + (b * BlockW) + BlockW2
    return punchedX, punchedY
  end
end

local function breakSlabH(e, slabE, parent)
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
  local slaby = slabE.pos.y
  do
    local h = BlockW
    if b > 0 then
      local w = math.floor(b * BlockW)
      local x = slabx + w / 2
      Entities.slab(parent, slabE.orient, x, slaby, w, h)
    end
    if b < (slabn - 1) then
      local w = math.floor((slabn - 1 - b) * BlockW)
      local x = slabx + ((b + 1) * BlockW) + (w / 2)
      Entities.slab(parent, slabE.orient, x, slaby, w, h)
    end
    slabE:destroy()
  end
  return {x = (slabx + (b * BlockW)) + BlockW2, y = slaby}
end

local function breakSlabV(e, slabE, parent)
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
      Entities.slab(parent, slabE.slab.orient, slabx, slaby, BlockW, h)
    end
    if b < (slabn - 1) then
      -- figure out the "bottom leavins"
      local h = math.floor((slabn - 1 - b) * BlockW)
      local slaby = slabtop + ((b + 1) * BlockW) + (h / 2)
      Entities.slab(parent, slabE.slab.orient, slabx, slaby, BlockW, h)
    end
    slabE:destroy()
  end
  return {x = slabx, y = (slabtop + (b * BlockW)) + BlockW2}
end

function Slab.breakSlab(e, slabE, parent)
  if slabE.slab.orient == "h" then
    return breakSlabH(e, slabE, parent)
  elseif slabE.slab.orient == "v" then
    return breakSlabV(e, slabE, parent)
  end
end

return Slab
