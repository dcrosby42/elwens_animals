local Comps = require 'comps'
local Estore = require 'ecs.estore'
local AnimalEnts = require 'modules.animalscreen.entities'
local Snow = require 'modules.snowman.snow'

local Entities={}

function Entities.initialEntities(res)
  local estore = Estore:new()

  -- local bg = Entities.background(estore,res)

	-- TODO AnimalEnts.buttons(bg,res)
	AnimalEnts.buttons(estore,res)

  return estore
end

-- function Entities.background(parent,res)
--   return parent:newEntity({
--     {'name', {name="background"}},
--     {'pic', {id='woodsbg', sx=1, sy=1}}, 
--     {'pos', {}},
--     {'sound', {sound='bgmusic', loop=true, duration=res.sounds.bgmusic.duration}},
--     {'physicsWorld', {gy=9.8*64,allowSleep=false}},
--   })
-- end 

return Entities
