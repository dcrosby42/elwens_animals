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
    move="sungirl_run", -- TODO: new slow anims!
  },
}
visMap["cooling_down"] = visMap["too_hot"]

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



-- update player's item counter ui element
local function updateFlowerCounter(estore, count)
  local flowerCounter = findEntity(estore, hasName("flower_counter"))
  if flowerCounter then
    flowerCounter.label.text = tostring(count)
  end
end

local function doPickups(myEnt, estore, res)
  local hits = C.detectPickups(myEnt,estore)

  if #hits == 0 then return end

  -- take the item components:
  for _, e in ipairs(hits) do
    Debug.println("pickup: "..e.item.kind)
    estore:transferComp(e, myEnt, e.item)
    estore:destroyEntity(e)
  end

  -- play sound
  C.addSoundComp(myEnt, "pickup_item", res)

  -- TODO: differentiate item kind. (Ie umbrella)
  local itemCount = tcount(myEnt.items)
  updateFlowerCounter(estore, itemCount)

end


local function updateShadow(catgirl,estore)
  local shadow = findEntity(estore, hasName('catgirl_shadow'))
  local sun = findEntity(estore, hasName('sun'))

  if sun and shadow then
    local sunMood = sun.states.mood.value
    if sunMood == "passive" then
      C.unhideEntity(shadow)
      shadow.pic.color[4] = 0.4
      shadow.pic.offx=0
      shadow.pic.offy=0
    elseif sunMood == "active" then
      C.unhideEntity(shadow)
      shadow.pic.color[4] = 0.6
      shadow.pic.sx = 1.2
      shadow.pic.sy = 1.2
    elseif sunMood == "angry" then
      local umbrella = tfindby(catgirl.items, "kind", "umbrella")
      if catgirl.states.mode.value == "normal" then
        if not umbrella then
          catgirl.states.mode.value = "heating_up"
        end
      elseif catgirl.states.mode.value == "too_hot" then
        if umbrella then
          catgirl.states.mode.value = "cooling_down"
        end
      end
    end
  end

  if catgirl.states.mode.value == "heating_up" then
    local puppygirl = findEntity(estore, hasName("puppygirl"))
    if puppygirl.states.mode.value == "hidden" then
      -- begin the transition to puppygirl
      C.resetPlayerControls(catgirl)
      C.hideEntity(shadow)
      -- signal puppygirl to begin appearingL:
      puppygirl.states.mode.value = "reveal"
      -- signal catgirl she's too hot
      catgirl.states.mode.value = "too_hot"

    -- elseif puppygirl.states.mode.value == "visible" then
    --   ...
    end

  elseif catgirl.states.mode.value == "cooling_down" then
    local puppygirl = findEntity(estore, hasName("puppygirl"))
    if puppygirl.states.mode.value == "visible" then
      -- signal puppygirl to disappear:
      puppygirl.states.mode.value = "hide"
    elseif puppygirl.states.mode.value == "hidden" then
      -- puppygirl has disappeared, resume control of catgirl
      catgirl.states.mode.value = "normal"
      C.resetPlayerControls(puppygirl)
      C.unhideEntity(shadow)
      C.assignAsPlayer(catgirl, estore)
      C.viewportFollow(catgirl, estore)
    end
  end
end

local function actionIsTriggered(e)
  return (e.touch and e.touch.state == "released") or
         (e.player_control and e.player_control.just_released['action'])
end

return defineUpdateSystem(hasTag('catgirl'),
  function(e, estore, input,res)

    if e.touch and e.touch.state == "pressed" then
      -- testing: click/touch catgirl or puppygirl to take control
      C.assignAsPlayer(e, estore)
    end

    if actionIsTriggered(e) then
      local exit = C.firstCollidingEntity(e, estore, hasTag("exit"))
      if exit then
        print("TODO: End level!")
      end
    end

    C.applyTouchNav(e)

    if e.nav_goal then
      -- applyNavControl(e,estore,input,res)
      C.accelTowardNavGoal(e)

    elseif e.player_control and e.player_control.any then
      C.controlPlayerVelocity(e, {vertical=false})
    else
      C.stopMoving(e)
    end

    C.updateLRDirFromVel(e)

    C.applyMotion(e, input.dt, {vertical=false})

    doPickups(e, estore, res)

    updateVisuals(e,estore,input,res)

    updateShadow(e,estore)


  end
)
