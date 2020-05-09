local Entities = require("modules.mario.entities")
local Contacts = require("systems.contacthelper")
local Vec = require 'vector-light'
local inspect = require("inspect")
local BlockW = 16
local BlockW2 = BlockW / 2
local BlockW4 = BlockW / 4

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
  return {x = (slabx + (b * BlockW)) + BlockW2, y = y}
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
  return {x = slabx, y = (slabtop + (b * BlockW)) + BlockW2}
end
local function breakSlab(e, contact, slabE, estore)
  if slabE.slab.orient == "h" then
    return breakSlabH(e, contact, slabE, estore)
  elseif slabE.slab.orient == "v" then
    return breakSlabV(e, contact, slabE, estore)
  end
end

local function tagEnt(e, name) e:newComp('tag', {name = name}) end

local function nameEnt(e, name)
  if e.name then
    e.name.name = name
  else
    e:newComp('name', {name = name})
  end
end

local function selfDestructEnt(e, t)
  tagEnt(e, "self_destruct")
  e:newComp('timer', {t = t, name = 'self_destruct'})
end

local function mkBrickFrag(estore, picId, x, y, r)
  local vecx, vecy = Vec.rotate(r, 1, 0)
  local sp = 200
  local e = estore:newEntity({
    {'pic', {id = picId, centerx = 0.5, centery = 0.5}},
    {'pos', {x = x, y = y}},
    {'vel', {dx = sp * vecx, dy = sp * vecy}},
  })
  tagEnt(e, 'brickfrag')
  selfDestructEnt(e, 1)
end

local function blockPunch(e, contact, estore, input, res)
  local otherE = estore:getEntity(contact.otherEid)
  if (otherE and otherE.slab) then
    local punched = breakSlab(e, contact, otherE, estore)
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

      mkBrickFrag(estore, 'brickfrag_ul', x - BlockW4, y - BlockW4,
                  math.pi * -0.75)
      mkBrickFrag(estore, 'brickfrag_ur', x + BlockW4, y - BlockW4,
                  math.pi * -0.25)
      mkBrickFrag(estore, 'brickfrag_ll', x - BlockW4, y + BlockW4, math.pi)
      mkBrickFrag(estore, 'brickfrag_lr', x + BlockW4, y + BlockW4, 0)

      -- (hitch the break sound to the break, ie, mario)
      e:newComp("sound", {sound = "breakblock"})

      -- Remove the entity that got punched
      estore:destroyEntity(punchedE)
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
  estore:walkEntities(hasComps("blockbreaker", "contact"),
                      function(e) doContacts(e, estore, input, res) end)

  -- xxx
  estore:walkEntities(hasTag('brickfrag'), function(e)
    e.vel.dy = e.vel.dy + (input.dt * 1000)
    e.pos.x = e.pos.x + (e.vel.dx * input.dt)
    e.pos.y = e.pos.y + (e.vel.dy * input.dt)
    e.pic.r = e.pic.r + (200 * input.dt)
  end)
end
