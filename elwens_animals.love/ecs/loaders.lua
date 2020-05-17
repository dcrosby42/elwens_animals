local R = require "resourceloader"
local inspect = require "inspect"
local Comp = require "comps"

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

local function mkDrawSystemChain(systems)
  for i, sys in ipairs(systems) do
    if type(sys) == 'table' and #sys > 0 then
      sys = mkDrawSystemChain(sys)
    elseif type(sys) == 'string' then
      sys = resolveSystem(sys, {systemKeys = {"drawSystem"}}) -- resolveSystem from ecs.ecshelpers
    end
    systems[i] = sys
  end
  return makeFuncChain2(systems) -- mkFuncChain2 from crozeng.helpers
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

-- Component config block contains either a 'data' key or 'datafile'
-- Data consists of a map of component definitions, 
-- where the key is the component type name, and the value is a pair-list of field defs.
-- Eg {data={ pos = {'x',0,'y',0,'real',false}, state = {'value','NIL'}}}
-- "CHEAT" this method doesn't put the definitions in a clever place, it just modifies 
-- the global Comp definitions.
local function defineComponents(cConfig)
  assert(cConfig.data or cConfig.datafile,
         "loadEntities: expected 'data' or 'datafile' in config " ..
             inspect(cConfig))
  local defs = Loaders.getData(cConfig)
  if defs then
    for compType, compDef in pairs(defs) do Comp.define(compType, compDef) end
  end
  return Comp
end

function Loaders.ecs(res, ecsConfig)
  local data = Loaders.getData(ecsConfig)

  local ecs = {
    entities = loadEntities(data.entities),
    components = defineComponents(data.components),
    update = composeSystems(data.systems),
    draw = mkDrawSystemChain(data.drawSystems),
  }

  res:get('ecs'):put(ecsConfig.name, ecs)
end

return Loaders
