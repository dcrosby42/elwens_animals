local Entities = require("modules.mario.entities")
local Const = require("modules.mario.const")
local Vec = require 'vector-light'

local BlockW = Const.BlockW
local BlockW2 = BlockW / 2
local BlockW4 = BlockW / 4

local Slab = {}

local function breakSlabH(e, slabE, contact, parent)
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
      Entities.slab(parent, slabE.orient, x, y, w, h)
    end
    if b < (slabn - 1) then
      local w = math.floor((slabn - 1 - b) * BlockW)
      local x = slabx + ((b + 1) * BlockW) + (w / 2)
      Entities.slab(parent, slabE.orient, x, y, w, h)
    end
    e:removeComp(contact)
    slabE:destroy()
  end
  return {x = (slabx + (b * BlockW)) + BlockW2, y = y}
end

local function breakSlabV(e, slabE, contact, parent)
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
    e:removeComp(contact)
    slabE:destroy()
  end
  return {x = slabx, y = (slabtop + (b * BlockW)) + BlockW2}
end

local AnglePlay = math.pi / 3
local function mkBrickFragPhys(parentE, picId, x, y, r, selfDestruct)
  r = r - (AnglePlay / 2) + (AnglePlay * math.random())
  local vecx, vecy = Vec.rotate(r, 1, 0)
  local sp = 125 + (150 * math.random())
  local spin = math.pi + (math.pi * 10 * math.random())
  local verts = Entities.rectangleVerts(7, 7, 0.5, 0.5)
  local e = parentE:newEntity({
    {'pic', {id = picId, centerx = 0.5, centery = 0.5}},
    {'pos', {x = x, y = y}},
    {'body', {debugDraw = false}},
    {'polygonShape', {vertices = verts}},
    {'vel', {dx = sp * vecx, dy = sp * vecy, angularvelocity = spin}},

  })
  tagEnt(e, 'brickfrag')
  if selfDestruct then selfDestructEnt(e, selfDestruct) end
end

local function mkBrickFrag(parentE, picId, x, y, r, selfDestruct)
  r = r - (AnglePlay / 2) + (AnglePlay * math.random())
  local vecx, vecy = Vec.rotate(r, 1, 0)
  local sp = 125 + (150 * math.random())
  local spin = math.pi + (math.pi * 10 * math.random())
  local verts = Entities.rectangleVerts(7, 7, 0.5, 0.5)
  local e = parentE:newEntity({
    {'pic', {id = picId, centerx = 0.5, centery = 0.5}},
    {'pos', {x = x, y = y}},
    {'vel', {dx = sp * vecx, dy = sp * vecy, angularvelocity = spin}},
  })
  tagEnt(e, 'brickfrag_anim')
  tagEnt(e, 'brickfrag')
  if selfDestruct then selfDestructEnt(e, selfDestruct) end
end

function Slab.slabPunched(e, slabE, contact, estore)
  local punched = Slab.breakSlab(e, slabE, contact, estore)
  local punchedE
  estore:seekEntity(function(e)
    return e.tags and e.tags.brick and e.pos.x == punched.x and e.pos.y ==
               punched.y
  end, function(e)
    punchedE = e
    return true
  end)
  if punchedE then
    local x, y = getPos(punchedE)
    local parentE = e:getParent()

    local fragLife = e.blockbreaker.fraglife
    if fraglife == '' or fraglife == 0 then fraglife = nil end
    local mkFragment = mkBrickFrag
    if e.blockbreaker.fragstyle == 'physical' then
      mkFragment = mkBrickFragPhys
    else
      if fragLife == nil then
        fragLife = 2 -- animated frags should not live forever
      end
    end
    mkFragment(parentE, 'brickfrag_ul', x - BlockW4, y - BlockW4,
               math.pi * -0.75, fragLife)
    mkFragment(parentE, 'brickfrag_ur', x + BlockW4, y - BlockW4,
               math.pi * -0.25, fragLife)
    mkFragment(parentE, 'brickfrag_ll', x - BlockW4, y + BlockW4, math.pi,
               fragLife)
    mkFragment(parentE, 'brickfrag_lr', x + BlockW4, y + BlockW4, 0, fragLife)

    -- (hitch the break sound to the breaker, ie, mario)
    e:newComp("sound", {sound = "breakblock"})

    -- Remove the entity that got punched
    estore:destroyEntity(punchedE)
  end
end

function Slab.breakSlab(e, slabE, contact, parent)
  if slabE.slab.orient == "h" then
    return breakSlabH(e, slabE, contact, parent)
  elseif slabE.slab.orient == "v" then
    return breakSlabV(e, slabE, contact, parent)
  end
end

return Slab
