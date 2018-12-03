-- TODO maybe integrate this if we start wanting it?

-- Convenience func transforms a complex body definition 
-- structure into physics body, shapes and fixtures.
--
-- Input structure:
-- opts
--   userdata | usually component id
--   body
--     type  | (dynamic) static kinematic
--     x                | 0
--     y                | 0
--     angularDamping   | optional, nil default
--     linearDamping    | optional, nil default
--     fixedRotation    | optional, nil default
--     mass             | optional, nil default
--   shape
--     type | rectangle circle chain edge (polygon)
--     x (for circle and rectangle only)
--     y (for circle and rectangle only)
--     pts (for edge, chain and polygon)
--     width (for rectangles only)
--     height (for rectangles only)
--     radius (for circles only)
--     loop (for chain only)
--     sensor | true (false)
--     userData | nil
--   []shapes
--     (see shape above)
--
-- Output structure:
-- {
--   body=<physics Body>,
--   shape(s)=<physics Shape(s)>,
--   fixture(s)=<physics Fixture(s)>,
-- }
local function newPhysicsObject(physicsWorld,opts)
  local obj = {
    body={},
    shape={},
    fixture={},
    shapes={},
    fixtures={},
  }

  local b = opts.body
  b.x = b.x or 0
  b.y = b.y or 0
  b.type = b.type or "dynamic"
  obj.body = love.physics.newBody(physicsWorld, b.x, b.y, b.type)

  local ss = nil
  local singleShape = false
  if opts.shapes then
    ss = opts.shapes
  elseif opts.shape then
    ss = {opts.shape}
  else
    error("Provide opts.shape or opts.shape")
  end

  for _,sh in ipairs(ss) do
    local shape = nil
    if sh.type == 'rectangle' then
      sh.x = sh.x or 0
      sh.y = sh.y or 0
      sh.width = sh.width or 0
      sh.height = sh.height or 0
      shape = love.physics.newRectangleShape(sh.x,sh.y,sh.width,sh.height,0)
    elseif sh.type == 'circle' then
      sh.x = sh.x or 0
      sh.y = sh.y or 0
      sh.radius = sh.radius or 1
      shape = love.physics.newCircleShape(sh.x,sh.y, sh.radius)
    elseif sh.type == 'chain' then
      sh.pts = sh.pts or {}
      shape = love.physics.newChainShape(sh.loop, unpack(sh.pts))
    elseif sh.type == 'edge' then
      sh.pts = sh.pts or {}
      shape = love.physics.newEdgeShape(unpack(sh.pts))
    elseif sh.type == 'polygon' then
      sh.pts = sh.pts or {}
      shape = love.physics.newPolygonShape(sh.pts)
    else
      error("Cannot build a phyics shape for sh.type="..tostring(sh.type).." -- "..tdebug(opts))
    end
    table.insert(obj.shapes, shape)

    local fixture = love.physics.newFixture(obj.body, shape)
    fixture:setUserData(opts.userData)
    if sh.sensor == true then
      fixture:setSensor(true)
    end
    if sh.filter then
      local f = sh.filter
      if f.cats then
        fixture:setCategory(unpack(f.cats))
      end
      if f.mask then
        fixture:setMask(unpack(f.mask))
      end
      if f.group then
        fixture:setGroupIndex(f.group)
      end
    end
    if sh.userData ~= nil then
      fixture:setUserData(sh.userData)
    end
    table.insert(obj.fixtures, fixture)
  end

  if #obj.shapes > 0 then
    obj.shape = obj.shapes[1]
    obj.fixture = obj.fixtures[1]
  end

  if b.mass then
    obj.body:setMass(b.mass)
  end
  if b.linearDamping then
    obj.body:setLinearDamping(b.linearDamping)
  end
  if b.angularDamping then
    obj.body:setAngularDamping(b.angularDamping)
  end
  if b.fixedRotation then
    obj.body:setFixedRotation(true)
  end

  return obj
end
