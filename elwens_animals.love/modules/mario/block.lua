local Entities = require("modules.mario.entities")
local Debug = require("mydebug").sub("Block", true, true)
local inspect = require("inspect")
local Vec = require 'vector-light'
local Const = require("modules.mario.const")

local BlockW = Const.BlockW
local BlockW2 = BlockW / 2
local BlockW4 = BlockW / 4
local AnglePlay = math.pi / 3

local Block = {}

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

function Block.explodeBrick(e, punchedE, estore)
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
  mkFragment(parentE, 'brickfrag_ul', x - BlockW4, y - BlockW4, math.pi * -0.75,
             fragLife)
  mkFragment(parentE, 'brickfrag_ur', x + BlockW4, y - BlockW4, math.pi * -0.25,
             fragLife)
  mkFragment(parentE, 'brickfrag_ll', x - BlockW4, y + BlockW4, math.pi,
             fragLife)
  mkFragment(parentE, 'brickfrag_lr', x + BlockW4, y + BlockW4, 0, fragLife)

  -- (hitch the break sound to the breaker, ie, mario)
  e:newComp("sound", {sound = "breakblock"})

  -- Remove the entity that got punched
  estore:destroyEntity(punchedE)
end

return Block
