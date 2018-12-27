local Comps = require 'comps'
local GC = require 'garbagecollect'
local Debug = (require('mydebug')).sub("Physics",false,true)

-- local logDebug = print
local logDebug = function() end
local logError = print

-- (pre-declare some helpers, see below)
local generateCollisionEvents
local mkCollisionFuncs

-- Creates and maintains a physics simulation for entities that have body components.
local physicsSystem =  defineUpdateSystem({'physicsWorld'},function(physEnt,estore,input,res)
  local comp = physEnt.physicsWorld
  local stuff = res.physics.caches[comp.cid]
  if not stuff then
    Debug.println("Creating new physics world")
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
  -- Sync body comps to phys bodies:
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
      Debug.println("New physics body for cid="..e.body.cid.." kind="..e.body.kind)
    end
    -- Apply values from Entity to the physics object
    local b = obj.body
    b:setPosition(getPos(e))
    b:setAngle(e.pos.r)
    if e.vel then
      b:setLinearVelocity(e.vel.dx, e.vel.dy)
      b:setLinearDamping(e.vel.lineardamping)
      b:setAngularVelocity(e.vel.angularvelocity)
      b:setAngularDamping(e.vel.angulardamping)
    end
    if e.force then
      local f = e.force
      b:applyForce(f.fx, f.fy)
      b:applyTorque(f.torque)
      b:applyLinearImpulse(f.impx, f.impy)
      b:applyAngularImpulse(f.angimp)
      -- Impulses need to be reset to 0 here
      f.impx=0
      f.impy=0
      f.angimp=0
    end
  end)
  -- Sync joint comps to phys bodies:
  estore:walkEntities(hasComps('joint'), function(e)
    local id = e.joint.cid
    table.insert(sawIds,id)
    -- See if there's a cached phys obj for this component
    local obj = oc[id]
    if obj == nil then
      -- newly-added Joint component -> create new phys joint in cache
      obj = res.physics.newJoint(world, e.joint, e, estore, oc)
      oc[id] = obj
      Debug.println("New physics joint for cid="..id.." kind="..e.joint.kind)
    end
    -- Apply values from Joint comp to the physics Joint object
    -- TODO ... when we have more interesting Joints
  end)

  -- Remove cached objects (bodies and joints) whose ids weren't seen in the last pass through the physics components
  local remIds = {}
  for id,obj in pairs(oc) do
    if not lcontains(sawIds, id) then
      table.insert(remIds, id)
    end
  end
  for _,id in ipairs(remIds) do
    Debug.println("Removing phys obj cid="..id)
    local obj = oc[id]
    if obj then
      if obj.body then 
        obj.body:destroy()
        GC.request()
      end
      if obj.joint then 
        obj.joint:destroy()
        GC.request()
      end
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
      local b = obj.body
      local x,y = b:getPosition()
      e.pos.x = x
      e.pos.y = y
      e.pos.r = b:getAngle()
      if e.vel then
        local dx,dy = b:getLinearVelocity()
        e.vel.dx = dx
        e.vel.dy = dy
        e.vel.lineardamping = b:getLinearDamping()
        e.vel.angularvelocity = b:getAngularVelocity()
        e.vel.angulardamping = b:getAngularDamping()
      end
    else
      -- ? wtf ? obj is missing from the cache
    end
  end)
  -- TODO walkEntities(hasComps('joint'), ....)
  -- ...when we actually need to
end)

local function tryGetUserData(obj)
  local userData
  ok,err = xpcall(function() userData = obj:getUserData() end, debug.traceback)
  if ok then
    return userData
  end
  -- ruh roh
  print("getUserData() FAILED on "..tostring(obj)..": "..tostring(err))
  print(debug.traceback())
  return nil
end

function mkCollisionFuncs(target)
  local beginContact = function(a,b,contact)
    local userA = tryGetUserData(a)
    local userB = tryGetUserData(a)
    if not userA or not userB then return end -- sometimes we get stale fixtures, abort

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
    Debug.println("beginContact a="..a:getUserData().." b="..b:getUserData())
    Debug.println("  a={"..adx..","..ady.."} b={"..bdx..","..bdy.."}")
    table.insert(target.collisionBuffer, {"begin",a,b,contactInfo})
  end

  local endContact = function(a,b,_contact)
    Debug.println("endContact a="..a:getUserData().." b="..b:getUserData())
    table.insert(target.collisionBuffer, {"end",a,b,{}})
    _contact = nil
    GC.request()
  end

  -- local preSolve = function(a,b,coll)
    -- local af,bf = coll:getFixtures()
    -- adx,ady = af:getBody():getLinearVelocity()
    -- bdx,bdy = bf:getBody():getLinearVelocity()
    -- Debug.println("preSolve  a={"..adx..","..ady.."} b={"..bdx..","..bdy.."}")
  -- end

  -- local postSolve = function(a,b,coll,normalImpulse, tangentImpulse)
    -- print("postSolve",normalImpulse, tangentImpulse)
  -- end


  -- return beginContact, endContact, preSolve, postSolve
  return beginContact, endContact, nil, nil
end

-- For each collision notes in physWorld._secret_collision_buffer,
-- Create a "collision event" object and append to the given events list.
function generateCollisionEvents(collbuf, estore, events)
  if #collbuf > 0 then
    Debug.println("handleCollisions: num items:"..#collbuf)
    for _,c in ipairs(collbuf) do
      local state,a,b,contactInfo = unpack(c)
      local aCid = tryGetUserData(a)
      local bCid = tryGetUserData(b)
      if aCid and bCid then 
        local aComp, aEnt = estore:getCompAndEntityForCid(a:getUserData())
        local bComp, bEnt = estore:getCompAndEntityForCid(b:getUserData())
        -- Debug.println("  aComp[eid="..aComp.eid.." cid="..aComp.cid.."] aEnt.eid="..aEnt.eid)
        -- Debug.println("  bComp[eid="..bComp.eid.." cid="..bComp.cid.."] bEnt.eid="..bEnt.eid)
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
          logError("!! Unable to register collision between '".. aCid .."' and '".. bCid .."'")
        end
      end
    end
  end
end

return physicsSystem
