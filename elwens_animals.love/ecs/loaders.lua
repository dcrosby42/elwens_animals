local R = require "resourceloader"

local Loaders = R.Loaders.copy()

function Loaders.ecs(res, ecsConfig)
  local data = Loaders.getData(ecsConfig)

  local ecs = {update = composeSystems(data.systems)}

  res:get('ecs'):put(ecsConfig.name, ecs)
end

return Loaders
