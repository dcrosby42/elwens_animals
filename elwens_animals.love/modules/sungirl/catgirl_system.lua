local EventHelpers = require 'eventhelpers'
local Debug = require('mydebug').sub("CatGirl")
local Entities = require("modules.sungirl.entities")
local C = require("modules.sungirl.common")
local Vec = require 'vector-light'

local function updateVisuals(e, estore, input, res)
  -- SELECT ANIM
  local anim = e.anims.catgirl
  if e.vel.dx == 0 then
    anim.id = "sungirl_stand"
  else
    anim.id = "sungirl_run"
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
    print("pickup: "..e.item.kind)
    estore:transferComp(e, myEnt, e.item)
    estore:destroyEntity(e)
  end
  if #hits > 0 then
    C.addSoundComp(myEnt, "pickup_item", res)
    print("I've got "..tcount(myEnt.items).." items")
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

  end
)
