-- local debug = print
local debug = function(...)
end

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

function resolveSystem(s, opts)
  opts = opts or {}
  opts.systemKeys = opts.systemKeys or {"system", "System"}
  if type(s) == "string" then s = require(s) end
  if type(s) == "function" then return s end
  if type(s) == "table" then
    for _, key in ipairs(opts.systemKeys) do
      if type(s[key]) == "function" then return s[key] end
    end
  end
  error("ecshelpers.resolveSystem '" .. tostring(s) ..
            "' cannot be resolved as a System")
end

function composeSystems(systems)
  local rsystems = {}
  for i = 1, #systems do table.insert(rsystems, resolveSystem(systems[i])) end
  return function(estore, input, res)
    for _, system in ipairs(rsystems) do system(estore, input, res) end
  end
end

function composeDrawSystems(systems)
  local rsystems = {}
  for i = 1, #systems do
    table.insert(rsystems,
                 resolveSystem(systems[i], {systemKeys = {"drawSystem"}}))
  end
  return function(estore, res)
    for _, system in ipairs(rsystems) do system(estore, res) end
  end
end

function hasComps(...)
  local ctypes = {...}
  local num = #ctypes
  if num == 0 then
    return function(e)
      return true
    end
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
      return e[ctypes[1]] ~= nil and e[ctypes[2]] and e[ctypes[3]] ~= nil and
                 e[ctypes[4]] ~= nil
    end
  else
    return function(e)
      for _, ctype in ipairs(ctypes) do if e[ctype] == nil then return end end
      return true
    end
  end
end

function hasTag(tagname)
  return function(e)
    return e.tags and e.tags[tagname]
  end
end

function hasName(name)
  return function(e)
    return e.name and e.name.name == name
  end
end

function allOf(...)
  local matchers = {...}
  return function(e)
    for _, matchFn in ipairs(matchers) do
      if not matchFn(e) then return false end
    end
    return true
  end
end

function addInputEvent(input, evt)
  if not input.events[evt.type] then input.events[evt.type] = {} end
  table.insert(input.events[evt.type], evt)
end

function setParentEntity(estore, childE, parentE, order)
  if childE.parent then estore:removeComp(childE.parent) end
  estore:newComp(childE, "parent", {parentEid = parentE.eid, order = order})
end

local function matchSpecToFn(matchSpec)
  if type(matchSpec) == "function" then
    return matchSpec
  else
    return hasComps(unpack(matchSpec))
  end
end

function defineUpdateSystem(matchSpec, fn)
  local matchFn = matchSpecToFn(matchSpec)
  return function(estore, input, res)
    estore:walkEntities(matchFn, function(e)
      fn(e, estore, input, res)
    end)
  end
end

function defineDrawSystem(matchSpec, fn)
  local matchFn = matchSpecToFn(matchSpec)
  return function(estore, res)
    estore:walkEntities(matchFn, function(e)
      fn(e, estore, res)
    end)
  end
end

function getPos(e)
  local par = e:getParent()
  if par and par.pos and not e.body then -- FIXME ZOINKS knowing about 'body' here is bad juju
    local x, y = getPos(par)
    return e.pos.x + x, e.pos.y + y
  else
    return e.pos.x, e.pos.y
  end
end
function getName(e)
  if e.name and e.name.name then
    return e.name.name
  else
    return nil
  end
end

function getBoundingRect(e)
  local x, y = getPos(e)
  local bounds = e.bounds
  if not bounds then return x, y, 1, 1 end

  local sx = 1
  local sy = 1
  if e.scale then
    sx = e.scale.sx
    sy = e.scale.sy
  end

  x = x - bounds.offx * sx
  y = y - bounds.offy * sy
  local w = bounds.w * sx
  local h = bounds.h * sy

  return x, y, w, h
end

function resolveEntCompKeyByPath(e, path)
  local key = path[#path]
  local cur = e
  for i = 1, #path - 2 do
    if path[i] == "PARENT" then
      cur = cur:getParent()
    else
      cur = cur[path[i]]
    end
  end
  local comp = cur[path[#path - 1]]
  return cur, comp, key
end

local function byOrder(a, b)
  local aval, bval
  if a.parent and a.parent.order then
    aval = a.parent.order
  else
    aval = 0
  end
  if b.parent and b.parent.order then
    bval = b.parent.order
  else
    bval = 0
  end
  return aval < bval
end

function sortEntities(ents, deep)
  table.sort(ents, byOrder)
  if deep then for i = 1, #ents do sortEntities(ents[i]._children, true) end end
end

function tagEnt(e, name)
  e:newComp('tag', {name = name})
end

function nameEnt(e, name)
  if e.name then
    e.name.name = name
  else
    e:newComp('name', {name = name})
  end
end

function selfDestructEnt(e, t)
  tagEnt(e, "self_destruct")
  e:newComp('timer', {t = t, name = 'self_destruct'})
end
