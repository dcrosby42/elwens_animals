local Comps = require 'comps'

-- local debug = print
local debug = function() end
local logError = print

-- (pre-declare some helpers, see below)
local generateCollisionEvents
local mkCollisionFuncs

-- Creates and maintains a physics simulation for entities that have body components.
local physicsSystem =  defineUpdateSystem({'physicsWorld'},function(physEnt,estore,input,res)
  local comp = physEnt.physicsWorld
  local stuff = res.physics.caches[comp.cid]
  if not stuff then
    debug("Creating new physics world")
    stuff = {
      world = love.physics.newWorld(comp.gx, comp.gy, comp.allowSleep),
      collisionBuffer = {},
      objectCache = {},
    }
    stuff.world:setCallbacks(mkCollisionFuncs(stuff))
    res.physics.caches[comp.cid] = stuff
  end
  local world = stuff.world

  --
  -- SYNC: Components->to->Physics Objects
  --
  local oc = stuff.objectCache
  local sawIds = {}
  -- estore:walkEntity(physEnt, hasComps('body'), function(e) -- XXX
  estore:walkEntities(hasComps('body'), function(e)
    local id = e.body.cid
    table.insert(sawIds,id)
    -- See if there's a cached phys obj for this component
    local obj = oc[id]
    if obj == nil then
      -- newly-added physics component -> create new obj in cache
      obj = res.physics.newObject(world, e)
      oc[id] = obj
      debug("New physics body for cid="..e.body.cid.." kind="..e.body.kind)
    end
    -- Apply values from Entity to the physics object
    obj.body:setPosition(getPos(e))
    obj.body:setAngle(e.pos.r)
    if e.vel then
      obj.body:setLinearVelocity(e.vel.dx, e.vel.dy)
    end
    if e.force then
      obj.body:applyForce(e.force.fx, e.force.fy)
    end
  end)

  -- Remove cached objects whose ids weren't seen in the last pass through the physics components
  local remIds = {}
  for id,obj in pairs(oc) do
    if not lcontains(sawIds, id) then
      table.insert(remIds, id)
    end
  end
  for _,id in ipairs(remIds) do
    debug("Removing phys obj cid="..id)
    local obj = oc[id]
    if obj then
      obj.body:destroy()
      oc[id] = nil
    end
  end

  stuff.collisionBuffer = {}

  --
  -- Iterate the physics world
  --
  world:update(input.dt)

  --
  -- Process Collisions
  --
  generateCollisionEvents(stuff.collisionBuffer, estore, input.events)
  stuff.collisionBuffer = {}

  --
  -- SYNC: Physics Objects->to->Components
  --
  estore:walkEntities(hasComps('body'), function(e)
    local id = e.body.cid
    local obj = oc[id]
    if obj then
      -- Copy values from physics object to entity's pos and vel components
      local x,y = obj.body:getPosition()
      e.pos.x = x
      e.pos.y = y
      e.pos.r = obj.body:getAngle()
      local dx,dy = obj.body:getLinearVelocity()
      e.vel.dx = dx
      e.vel.dy = dy
    else
      -- ? wtf
    end
  end)
end)

function mkCollisionFuncs(target)
  local beginContact = function(a,b,contact)
    local af,bf = contact:getFixtures()
    adx,ady = af:getBody():getLinearVelocity()
    bdx,bdy = bf:getBody():getLinearVelocity()
    local contactInfo = {
      a={
        vel={adx,ady},
      },
      b={
        vel={bdx,bdy},
      },
    }
    debug("beginContact a="..a:getUserData().." b="..b:getUserData())
    debug("  a={"..adx..","..ady.."} b={"..bdx..","..bdy.."}")
    table.insert(target.collisionBuffer, {"begin",a,b,contactInfo})
  end

  local endContact = function(a,b,_contact)
    debug("endContact a="..a:getUserData().." b="..b:getUserData())
    table.insert(target.collisionBuffer, {"end",a,b,{}})
    _contact = nil
    collectgarbage()
  end

  local preSolve = function(a,b,coll)
    -- local af,bf = coll:getFixtures()
    -- adx,ady = af:getBody():getLinearVelocity()
    -- bdx,bdy = bf:getBody():getLinearVelocity()
    -- debug("preSolve  a={"..adx..","..ady.."} b={"..bdx..","..bdy.."}")
  end

  local postSolve = function(a,b,coll,normalImpulse, tangentImpulse)
    -- print("postSolve",normalImpulse, tangentImpulse)
  end


  return beginContact, endContact, preSolve, postSolve
end

-- For each collision notes in physWorld._secret_collision_buffer,
-- Create a "collision event" object and append to the given events list.
function generateCollisionEvents(collbuf, estore, events)
  if #collbuf > 0 then
    debug("handleCollisions: num items:"..#collbuf)
    for _,c in ipairs(collbuf) do
      local state,a,b,contactInfo = unpack(c)
      local aComp, aEnt = estore:getCompAndEntityForCid(a:getUserData())
      local bComp, bEnt = estore:getCompAndEntityForCid(b:getUserData())
      -- debug("  aComp[eid="..aComp.eid.." cid="..aComp.cid.."] aEnt.eid="..aEnt.eid)
      -- debug("  bComp[eid="..bComp.eid.." cid="..bComp.cid.."] bEnt.eid="..bEnt.eid)
      if aEnt and bEnt then
        local evt = {
          type="collision",
          state=state,
          ent1=aEnt,
          comp1=aComp,
          ent2=bEnt,
          comp2=bComp,
          contactInfo=contactInfo,
        }
        table.insert(events, evt)
      
      else
        logError("!! Unable to register collision between '".. a:getUserData() .."' and '".. b:getUserData() .."'")
      end
    end
  end
end

return physicsSystem
