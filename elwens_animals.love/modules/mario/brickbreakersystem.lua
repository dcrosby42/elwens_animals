local Contacts = require("systems.contacthelper")
local Debug = require("mydebug").sub("brickbreaker")
local Slab = require("modules.mario.slab")
local Block = require("modules.mario.block")

local function varPlus(varComp, num)
  varComp.value = (varComp.value or 0) + num
end
local function varMinus(varComp, num)
  varComp.value = (varComp.value or 0) - 1
end

local function varSet(varComp, value)
  varComp.value = value
end

local function slabPunched(e, slabE, contact, estore)
  -- calc the x,y of "standard brick" location where e punched slabE
  local punchedX, punchedY = Slab.calcPunchedLoc(e, slabE)
  -- find the punched entity by location
  local punchedE = estore:findEntity(function(e)
    return e.block and e.pos.x == punchedX and e.pos.y == punchedY
  end)

  if punchedE then
    if punchedE.block.kind == 'brick' then
      Slab.breakSlab(e, slabE, estore)
      Block.explodeBrick(e, punchedE, estore)
      varPlus(e.vars.points, 10)
      Debug.println("points=" .. e.vars.points.value)
    elseif punchedE.block.kind == 'qblock' then
      punchedE.block.kind = 'block'
      punchedE.anim.id = 'block_standard'
      e:newComp("sound", {sound = "bump"})
      if punchedE.block.contents == 'coin' then
        e:newComp("sound", {sound = "coin"})
        varPlus(e.vars.coins, 1)
        Debug.println("coins=" .. e.vars.coins.value)
      elseif punchedE.block.contents == 'mushroom' then
        e:newComp("sound", {sound = "powerup_appear"})
      elseif punchedE.block.contents == 'oneup' then
        e:newComp("sound", {sound = "powerup_appear"})
        -- varSet(e.vars.supermario, true)
        -- Debug.println("supermario=" .. e.vars.supermario.value)
      end
    elseif punchedE.block.kind == 'block' then
      e:newComp("sound", {sound = "bump"})
    end
  end

  e:removeComp(contact)
end

local breakerSystem = defineUpdateSystem({'blockbreaker', 'contact'},
                                         function(e, estore, input, res)
  for _, contact in pairs(e.contacts) do
    if Contacts.isUp(contact) and e.vel.dy <= 0 then
      local otherE = estore:getEntity(contact.otherEid)
      if (otherE and otherE.slab) then
        slabPunched(e, otherE, contact, estore)
      end
    end
  end
end)

-- this "tagalong" system will animated any non-physical brick fragments that may have been created
local function brickFragAnimSystem(estore, input, res)
  estore:walkEntities(hasTag("brickfrag_anim"), function(e)
    e.vel.dy = e.vel.dy + (input.dt * 1000)
    e.pos.x = e.pos.x + (e.vel.dx * input.dt)
    e.pos.y = e.pos.y + (e.vel.dy * input.dt)
    e.pic.r = e.pic.r + (e.vel.angularvelocity * input.dt)
  end)
end

return function(estore, input, res)
  breakerSystem(estore, input, res)
  brickFragAnimSystem(estore, input, res)
end

