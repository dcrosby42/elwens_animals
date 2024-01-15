local EventHelpers = require 'eventhelpers'
local Debug = require('mydebug').sub("CatGirl")
local Entities = require("modules.sungirl.entities")
local C = require("modules.sungirl.common")
local Vec = require 'vector-light'

local visMap = {
  normal={
    idle="sungirl_stand",
    move="sungirl_run",
  },
  too_hot={
    idle="sungirl_stand_too_hot",
    move="sungirl_run",
  },
}

local function updateVisuals(e, estore, input, res)
  local mode = "normal"
  if e.states and e.states.mode then
    mode = e.states.mode.value
  end

  -- SELECT ANIM
  local anim = e.anims.catgirl
  if e.vel.dx == 0 then
    anim.id = visMap[mode].idle
  else
    anim.id = visMap[mode].move
  end

  if e.vel.dx < 0 then
    e.states.dir.value = "left"
  else
    e.states.dir.value = "right"
  end

  -- ORIENT
  if e.states.dir.value == "left" then
    if anim.sx > 0 then
      anim.sx = -1 * anim.sx
    end
  else
    if anim.sx < 0 then
      anim.sx = -1 * anim.sx
    end
  end
end



local function doPickups(myEnt, estore, res)
  local hits = findEntities(estore, function(e)
    return e.item and e.eid ~= myEnt.eid and C.entitiesIntersect(myEnt,e)
  end)
  for _, e in ipairs(hits) do
    Debug.println("pickup: "..e.item.kind)
    estore:transferComp(e, myEnt, e.item)
    estore:destroyEntity(e)
  end
  if #hits > 0 then
    C.addSoundComp(myEnt, "pickup_item", res)

    -- print("I've got "..tcount(myEnt.items).." items")
    local count = tcount(myEnt.items)
    local fcounter = findEntity(estore, hasName("flower_counter"))
    if fcounter then
      fcounter.label.text = tostring(count)
    end
  end
end

-- Add a "hidden" component to the entity, if not already present
local function hideEntity(e)
  if not e.hidden then 
    e:newComp("hidden",{}) 
  end
end

-- Remove the "hidden" component from an entity
local function unhideEntity(e)
  if e.hidden then
    e:removeComp(e.hidden)
  end
end


local function updateShadow(catgirl,estore)
  local shadow = findEntity(estore, hasName('catgirl_shadow'))
  local sun = findEntity(estore, hasName('sun'))

  if sun and shadow then
    local mood = sun.states.mood.value
    if mood == "passive" then
      unhideEntity(shadow)
      shadow.pic.color[4] = 0.4
      shadow.pic.offx=0
      shadow.pic.offy=0
    elseif mood == "active" then
      unhideEntity(shadow)
      shadow.pic.color[4] = 0.6
      shadow.pic.sx = 1.2
      shadow.pic.sy = 1.2
    elseif mood == "angry" then
      local puppygirl = findEntity(estore, hasName("puppygirl"))
      if puppygirl and puppygirl.hidden then
        hideEntity(shadow)
        puppygirl.states.mode.value = "reveal" -- see puppygirl_system for handling
        C.resetPlayerControls(catgirl)
      end
    end
  end
  
end

return defineUpdateSystem(hasTag('catgirl'),
  function(e, estore, input,res)

    if e.touch and e.touch.state == "pressed" then
      C.assignAsPlayer(e, estore)
    end

    C.applyTouchNav(e)

    if e.nav_goal then
      -- applyNavControl(e,estore,input,res)
      C.accelTowardNavGoal(e)

    elseif e.player_control and e.player_control.any then
      C.applyPlayerControls(e, {vertical=false})
    else
      C.stopMoving(e)
    end

    C.updateLRDirFromVel(e)

    C.applyMotion(e,input, {vertical=false})

    doPickups(e, estore, res)

    updateVisuals(e,estore,input,res)

    updateShadow(e,estore)


  end
)
