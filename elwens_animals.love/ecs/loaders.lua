local R = require "resourceloader"
local inspect = require "inspect"

local Loaders = R.Loaders.copy()

local function loadDrawSystems(dsConfig)
  if #dsConfig > 0 then
    -- normal list of system names, just convert it into the classical sys sequence
    return composeDrawSystems(dsConfig)
  else
    -- nested system.  Eg, viewportdraw
    local drawSystems = {}
    for name, subs in pairs(dsConfig) do
      -- resolve the sub system(s) and wrap them up in the encompassing system
      local sysobj = require(name)
      if sysobj.newDrawSystem then
        local ds = require(name).newDrawSystem(loadDrawSystems(subs))
        table.insert(drawSystems, ds)
      else
        error("loadDrawSystems: Tried to load wrapping draw system '" .. name ..
                  "' but it did not provide a 'newDrawSystem()' func. Config was: " ..
                  inspect(dsConfig))
      end
    end
    if #drawSystems > 1 then
      error(
          "loadDrawSystems: Dunno what to do with MULTIPLE top level composite systems....? Config was: " ..
              inspect(dsConfig))
    end
    return drawSystems[1] -- should really only be one
  end
end

local function loadEntities(eConfig)
  assert(eConfig.code,
         "loadEntities: expected 'code' in config " .. inspect(eConfig))
  local entities = require(eConfig.code)
  assert(entities.initialEntities,
         "loadEntities: expected object from '" .. eConfig.code ..
             "' to contain a function 'initialEntities()'")
  return entities
end

function Loaders.ecs(res, ecsConfig)
  local data = Loaders.getData(ecsConfig)

  local ecs = {
    entities = loadEntities(data.entities),
    update = composeSystems(data.systems),
    draw = loadDrawSystems(data.drawSystems),
  }

  res:get('ecs'):put(ecsConfig.name, ecs)
end

return Loaders
