require 'ecs.ecshelpers'
require 'mydebug'
local EventHelpers = require 'eventhelpers'
local Entities = require 'modules.christmas.entities'

local Debug = Debug.sub("XmasSystem",true,true)

-- Xmas System
--
local nextOrn = 1
return function(estore,input,res)
  EventHelpers.handle(input.events, "touch", {
    pressed=function(evt)
      -- local item = pickRandom(res.ornamentNames)
      local item = res.ornamentNames[nextOrn]
      nextOrn = nextOrn + 1
      if nextOrn > #res.ornamentNames then nextOrn = 1 end
      Debug.println(item)
      local orn = Entities.ornament(estore, res, item)
      orn.pos.x = evt.x
      orn.pos.y = evt.y
      return true
    end,

    moved=function(evt)
    end,

    released=function(evt)
    end,
  })
end
