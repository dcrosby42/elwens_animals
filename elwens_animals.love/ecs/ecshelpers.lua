-- local debug = print
local debug = function(...) end

-- Require a list of modules, returning their values as a list
-- TODO: find and remove all usages of this func, then delete the func.
function requireModules(reqs)
  local modules = {}
  for i, req in ipairs(reqs) do
    local module = require(req)
    assert(module, "Cannot require '" .. req .. "'")
    table.insert(modules, module)
  end
  debug("requireModules returning " .. #modules .. " modules")
  return modules
end

-- Returns a System function:
-- If s is a string, s will be loaded via require.
-- If s is a function, it will be returned. (Param signature will NOT be checked/validated... we trust the caller here)
-- If s is a table, the property s.system will be returned, on the assumption that it's an apporpirate system function.
--   The property name "system" can be controlled via opts.systemKeys (a list of property names, which will be tried in order)
-- Errors if system cannot be resolved.
local function resolveSystem(s,opts)
  opts=opts or {}
  opts.systemKeys = opts.systemKeys or {"system","System","drawSystem","DrawSystem"}
  if type(s) == "string" then
    s = require(s)
  end
  if type(s) == "function" then
    return s
  end
  if type(s) == "table" then
    for _,key in ipairs(opts.systemKeys) do
      if type(s[key]) == "function" then
        return s[key]
      end
    end
  end
  error("ecshelpers.resolveSystem '"..tostring(s).."' cannot be resolved as a System")
end

local function resolveSystems(systems)
  local rsystems = {}
  for i = 1, #systems do
    table.insert(rsystems, resolveSystem(systems[i]))
  end
  return rsystems
end

-- Return a single System func that invokes all the given Systems in order.
-- Systems are resolved using resolveSystems()
--   - "Update" system funcs have signature f(estore, input, res) -> (estore, sidefx)
--   - "Draw" system funcs have signature f(estore, res) -> void
-- NB: IT IS THE CALLER'S RESPONSIBILITTY to ensure the list of systems all have proper param sigs.
--   Eg, if caller is composing "update" systems, they need to all have the proper f(estore,intput,res) signature,
--   but if composing "draw" systems, they need to all have f(estore,res) signatures.
function composeSystems(systems)
  return function(...)
    for _,system in ipairs(resolveSystems(systems)) do
      system(...)
    end
  end
end

-- TODO: find and remove all usages of composeDrawSystems
composeDrawSystems = composeSystems

-- Create an Entity predicate that matches entities having components for all given comp types.
-- Eg, hasComps("label","pos","bounds") matches entities that have at least one each of label, pos and bounds components.
function hasComps(...)
  local ctypes = {...}
  local num = #ctypes
  if num == 0 then
    return function(e) return true end
  elseif num == 1 then
    return function(e)
      return e[ctypes[1]] ~= nil
    end
  elseif num == 2 then
    return function(e)
      return e[ctypes[1]] ~= nil and e[ctypes[2]] ~= nil
    end
  elseif num == 3 then
    return function(e)
      return e[ctypes[1]] ~= nil and e[ctypes[2]] and e[ctypes[3]] ~= nil
    end
  elseif num == 4 then
    return function(e)
      return e[ctypes[1]] ~= nil and e[ctypes[2]] and e[ctypes[3]] ~= nil and e[ctypes[4]] ~= nil
    end
  else
    return function(e)
      for _,ctype in ipairs(ctypes) do
        if e[ctype] == nil then return end
      end
      return true
    end
  end
end

-- Create an Entity predicate that matches on tag name
function hasTag(tagname)
  return function(e)
    return e.tags and e.tags[tagname]
  end
end

-- Create an Entity predicate that matches on name component
function hasName(name)
  return function(e)
    return e.name and e.name.name==name
  end
end

-- Create an Entity predictate that matches on proximity
function isNear(x,y,maxDist)
  return function(e)
    return e.pos and math.dist(x, y, e.pos.x, e.pos.y) <= maxDist
  end
end

-- Compose an Entity predicate that matches when all given predicates match
function allOf(...)
  local matchers = {...}
  return function(e)
    for _,matchFn in ipairs(matchers) do
      if not matchFn(e) then
        return false
      end
    end
    return true
  end
end


function addInputEvent(input, evt)
  if not input.events[evt.type] then
    input.events[evt.type] = {}
  end
  table.insert(input.events[evt.type], evt)
end

function setParentEntity(estore, childE, parentE, order)
  if childE.parent then
    estore:removeComp(childE.parent)
  end
  estore:newComp(childE, 'parent', {parentEid=parentE.eid, order=order})
end

local function matchSpecToFn(matchSpec)
  if type(matchSpec) == "function" then
    return matchSpec
  else
    return hasComps(unpack(matchSpec))
  end
end

function defineUpdateSystem(matchSpec,fn)
  local matchFn = matchSpecToFn(matchSpec)
  return function(estore, input, res)
    estore:walkEntities(
      matchFn,
      function(e) fn(e, estore, input, res) end
    )
  end
end

function defineDrawSystem(matchSpec,fn)
  local matchFn = matchSpecToFn(matchSpec)
  return function(estore, res)
    estore:walkEntities(
      matchFn,
      function(e) fn(e, estore, res) end
    )
  end
end

function getPos(e)
  local par = e:getParent()
  if par and par.pos and not e.body then -- FIXME ZOINKS knowing about 'body' here is bad juju
    local x,y = getPos(par)
    return e.pos.x + x, e.pos.y + y
  else
    return e.pos.x, e.pos.y
  end
end

function getBoundingRect(e)
  local x, y = getPos(e)
  local bounds = e.bounds
  if not bounds then return x,y,1,1 end

  local sx = 1
  local sy = 1
  if e.scale then
    sx = e.scale.sx
    sy = e.scale.sy
  end

  x = x - bounds.offx*sx
  y = y - bounds.offy*sy
  local w = bounds.w*sx
  local h = bounds.h*sy

  return x,y,w,h
end

function resolveEntCompKeyByPath(e, path)
  local key = path[#path]
  local cur = e
  for i=1,#path-2 do
    if path[i] == 'PARENT' then
      cur = cur:getParent()
    else
      cur = cur[path[i]]
    end
  end
  local comp = cur[path[#path-1]]
  return cur, comp, key
end


local function byOrder(a,b)
  local aval,bval
  if a.parent and a.parent.order then aval = a.parent.order else aval = 0 end
  if b.parent and b.parent.order then bval = b.parent.order else bval = 0 end
  return aval < bval
end

function sortEntities(ents, deep)
  table.sort(ents, byOrder)
  if deep then
    for i=1,#ents do
      sortEntities(ents[i]._children, true)
    end
  end
end

-- Find an entity with this tag near these coords; if found, run the func.
-- Entity is passed as the sole arg to the func.
-- Return true if an entity was matched, false otherwise.
function touchingTaggedEntity(estore, coords, tagName, maxDist, fn)
  local hit = false
  estore:seekEntity(
    allOf(hasTag(tagName), isNear(coords.x, coords.y, maxDist)),
    function(e)
      fn(e)
      hit = true
      return true
    end
  )
  return hit
end

-- Return the first Entity matching the given entity predicate.
-- Return nil if not found
function findEntity(estore, filter)
  local found
  estore:seekEntity(filter, function(e)
    found = true
    return true
  end)
  return found
end

-- Return all the Entities matching the given entity predicate.
-- Return empty table if none found
function findEntities(estore, filter)
  local ents = {}
  estore:walkEntities(filter, function(e)
    table.insert(ents, e)
  end)
  return ents
end


-- Returns a useful string depicting the entity name.
-- Begins with the entity ID, then adds tag.name, name.name or pic.id, 
-- if such components are available on the entity.
function debugEntityName(e)
  local name = "" .. e.eid
  if e.tag then
    name = name .. "." .. e.tag.name
  end
  if e.name then
    name = name .. "." .. e.name.name
  elseif e.pic then
    name = name .. "." .. e.pic.id
  end
  return name
end