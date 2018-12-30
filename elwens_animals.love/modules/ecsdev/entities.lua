local Comps = require 'comps'
local Estore = require 'ecs.estore'

local Entities={}

function Entities.initialEntities(res)
  local estore = Estore:new()

  Entities.pauseButton(estore)

  return estore
end

function Entities.pauseButton(estore)
  return estore:newEntity({
    {'pic', {id='skip-button-outline', sx=0.25,sy=0.25,centerx=0.5, centery=0.5, color={1,1,1,0.25}}},
    {'pos', {x=50,y=50}},
    {'button', {kind='tap', eventtype='PAUSE', holdtime=0.5, radius=40}},
  })
end

return Entities
