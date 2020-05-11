local ResourceSet = {}

function ResourceSet:new()
  local o = {}
  setmetatable(o, self)
  self.__index = self
  return o
end

function ResourceSet:put(name, obj)
  self[name] = obj
  return obj
end

function ResourceSet:get(name)
  return self[name]
end

local ResourceRoot = {}

function ResourceRoot:new()
  local o = {}
  setmetatable(o, self)
  self.__index = self
  return o
end

function ResourceRoot:get(name)
  local resSet = self[name]
  if resSet == nil then
    resSet = ResourceSet:new()
    self[name] = resSet
  end
  return resSet
end

function ResourceRoot:debugString()
  local s = "ResourceRoot\n"
  for setName, resSet in pairs(self) do
    s = s .. "\t" .. setName .. ":\n"
    for key, _ in pairs(resSet) do s = s .. "\t\t" .. key .. "\n" end
  end
  return s
end

return ResourceRoot
