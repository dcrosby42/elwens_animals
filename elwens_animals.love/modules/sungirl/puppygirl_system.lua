local Debug = require('mydebug').sub("PuppyGirl")
local Entities = require("modules.sungirl.entities")
local C = require("modules.sungirl.common")


local function updateDir(e, estore)
  if C.isMoving(e) then
    C.updateLRDirFromVel(e)
  else
    -- Face catgirl when idling
    local catgirl = Entities.getCatgirl(estore)
    if e.pos.x < catgirl.pos.x then
      e.states.dir.value = "right"
    else
      e.states.dir.value = "left"
    end
  end
end

local function updateVisuals(e)
  -- determine pic:
  local hflip = 1
  if not C.isMoving(e) then
    e.pic.id = "puppygirl-idle-left"
    hflip = -1
  else
    if C.isMovingMoreHorizontal(e) then
      e.pic.id = "puppygirl-fly-left"
      hflip = -1 -- (the dir handler below assumes pics face right)
    else
      if e.vel.dy < 0 then
        -- up
        -- e.pic.id = "puppygirl-rise-right"
        e.pic.id = "puppygirl-idle-left"
        hflip = -1
      else
        -- down
        -- e.pic.id = "puppygirl-descend-left"
        -- hflip = -1 -- (the dir handler below assumes pics face right)
        e.pic.id = "puppygirl-idle-left"
        hflip = -1
      end
    end
  end

  -- update pic orientation based on dir:
  if e.states.dir.value == "right" then
    e.pic.sx = math.abs(e.pic.sx) * hflip
  else
    e.pic.sx = -1 * math.abs(e.pic.sx) * hflip
  end
end

local function revealPuppygirl(puppygirl, catgirl)
  if puppygirl.hidden then puppygirl:removeComp(puppygirl.hidden) end

  local x = catgirl.pos.x
  local y = catgirl.pos.y + 250
  puppygirl.pos.x = x
  puppygirl.pos.y = y
  puppygirl.pic.sy = 0.1
  -- cleanup stale tweens and timers:
  local rems = {}
  for _, timer in pairs(puppygirl.timers or {}) do
    table.insert(rems, timer)
  end
  for _, tween in pairs(puppygirl.tweens or {}) do
    table.insert(rems, tween)
  end
  for _, comp in ipairs(rems) do
    catgirl:removeComp(comp)
  end
  -- add new tweens and timer:
  local dur = 0.5
  local funcName = "inQuart"
  -- (NB: this timer, once expired, WILL BE DELETED by tween_system:)
  puppygirl:newComp("timer", {
    name = "reveal_anim",
    countDown = false,
    reset = dur,
    loop = false
  })
  -- tween the pic's vertical scale from squashed to full height:
  puppygirl:newComp("tween", {
    subject = "pic",
    target = { sy = { 0.1, 1.0, dur, funcName } }, -- {from,to,duration,tweenFunc}
    timer = "reveal_anim",
  })
  -- tween the pos up and to the right (float up from catgirl's feet)
  puppygirl:newComp("tween", {
    subject = "pos",
    target = {
      x = { x, x + 300, dur, funcName },
      y = { y, y - 300, dur, funcName },
    },
    timer = "reveal_anim",
  })
end

local function startHidingPuppyGirl(puppygirl, catgirl)
  local dur = 0.5

  puppygirl.pic.id = "puppygirl-idle-left"

  puppygirl:newComp("timer", {
    name = "hide_anim",
    countDown = false,
    reset = dur,
    loop = false
  })
  local funcName = "outQuart"
  -- add new tweens and timer:

  -- tween the pic's vertical scale from squashed to full height:
  puppygirl:newComp("tween", {
    subject = "pic",
    target = { sy = { 1.0, 0.1, dur, funcName } }, -- {from,to,duration,tweenFunc}
    timer = "hide_anim",
  })
  -- tween the pos up and to the right (float up from catgirl's feet)
  puppygirl:newComp("tween", {
    subject = "pos",
    target = {
      x = { puppygirl.pos.x, catgirl.pos.x, dur, funcName },
      y = { puppygirl.pos.y, catgirl.pos.y + 250, dur, funcName },
    },
    timer = "hide_anim",
  })
end

local function doPickups(myEnt, estore, res)
  local hits = C.detectPickups(myEnt,estore)

  if #hits == 0 then return end

  -- take the item components:
  for _, pickupE in ipairs(hits) do
    if pickupE.item.kind == "umbrella" then
      Debug.println("pickup: "..pickupE.item.kind)
      C.addSoundComp(myEnt, "pickup_item", res)

      -- Tuck this entity in as a child of the player entity:
      pickupE:removeComp(pickupE.tags.pickup)
      pickupE.pos.x, pickupE.pos.y = 0,0
      myEnt:addChild(pickupE)
    end
  end
end

local function findCatgirl(estore)
  return findEntity(estore, hasName("catgirl"))
end

-- When puppygirl is holding an umbrella, and is touching catgirl,
-- bequeath the umbrella to her.
local function doGiveToCatgirl(myEnt, estore, res)
  local umbE = findEntity(myEnt, hasTag("umbrella"))
  if umbE then
    local catgirl = findCatgirl(estore)
    if C.entitiesIntersect(myEnt, catgirl) then
      -- Give umbrella from puppygirl to catgirl
      Debug.println("Gives umbrella to Catgirl!")
      catgirl:newComp("item",{kind="umbrella"})
      umbE.pos.x, umbE.pos.y = -80,30
      umbE.pic.sx = -1
      catgirl:addChild(umbE) -- transfer umbrella ent from puppygirl to catgirl
      C.addSoundComp(catgirl, "pickup_item", res)
    end
  end
end

return defineUpdateSystem(hasTag('puppygirl'),
  function(e, estore, input, res)
    local mode = e.states.mode.value
    if mode == "visible" then
      if e.touch and e.touch.state == "pressed" then
        C.assignAsPlayer(e, estore)
      end

      -- (maybe) add/move nav_goal
      C.applyTouchNav(e)

      if e.nav_goal then
        C.accelTowardNavGoal(e)
      elseif e.player_control and e.player_control.any then
        -- devel/debug manual keybd controls:
        C.controlPlayerVelocity(e)
      else
        -- halt:
        C.stopMoving(e)
      end

      updateDir(e, estore)

      C.applyMotion(e, input.dt)

      doPickups(e, estore, res)

      doGiveToCatgirl(e, estore, res)

      updateVisuals(e)

    elseif mode == "reveal" then
      local catgirl = findCatgirl(estore)
      revealPuppygirl(e,catgirl)
      e.states.mode.value = "revealing"

    elseif mode == "revealing" then
      if not (e.timers and e.timers.reveal_anim) then
        -- reveal_anim timer has expired
        Debug.println("Done revealing")
        e.states.mode.value = "visible"
        C.assignAsPlayer(e, estore)
        C.viewportFollow(e, estore)
      end

    elseif mode == "hide" then
      local catgirl = findCatgirl(estore)
      startHidingPuppyGirl(e,catgirl)
      e.states.mode.value = "hiding"

    elseif mode == "hiding" then
      if not e.timers or not e.timers.hide_anim or e.timers.hide_anim.alarm then
        C.hideEntity(e)
        e.states.mode.value = "hidden"
      end
    end

  end
)
