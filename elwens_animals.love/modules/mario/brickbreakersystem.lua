local Contacts = require("systems.contacthelper")
local Slab = require("modules.mario.slab")

local function doContacts(e, estore, input, res)
end

local breakerSystem = defineUpdateSystem({'blockbreaker', 'contact'},
                                         function(e, estore, input, res)
  for _, contact in pairs(e.contacts) do
    if Contacts.isUp(contact) and e.vel.dy <= 0 then
      local otherE = estore:getEntity(contact.otherEid)
      if (otherE and otherE.slab) then
        Slab.slabPunched(e, otherE, contact, estore)
      end
    end
  end
end)

return function(estore, input, res)
  breakerSystem(estore, input, res)

  -- this "tagalong" system will animated any non-physical brick fragments that may have been created
  estore:walkEntities(hasTag("brickfrag_anim"), function(e)
    e.vel.dy = e.vel.dy + (input.dt * 1000)
    e.pos.x = e.pos.x + (e.vel.dx * input.dt)
    e.pos.y = e.pos.y + (e.vel.dy * input.dt)
    e.pic.r = e.pic.r + (e.vel.angularvelocity * input.dt)
  end)
end
