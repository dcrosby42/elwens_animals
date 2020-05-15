local Contacts = require("systems.contacthelper")
local Slab = require("modules.mario.slab")
local Block = require("modules.mario.block")

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
    elseif punchedE.block.kind == 'qblock' then
      punchedE.block.kind = 'block'
      punchedE.anim.id = 'block_standard'
      e:newComp("sound", {sound = "bump"})
      e:newComp("sound", {sound = "coin"})
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

