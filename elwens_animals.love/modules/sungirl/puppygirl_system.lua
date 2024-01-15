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
  -- {0,1,1,'linear'}
  local dur = 0.5   -- 1 second animation
  local funcName = "inQuart"
  puppygirl:newComp("timer", { name = "reveal_anim", countDown = false, reset = dur, loop = false })
  puppygirl:newComp("tween", {
    subject = "pic",
    target = { sy = { 0.1, 1, dur, funcName } },
    timer = "reveal_anim",
  })
  puppygirl:newComp("tween", {
    subject = "pos",
    target = {
      x = { x, x + 300, dur, funcName },
      y = { y, y - 300, dur, funcName },
    },
    timer = "reveal_anim",
  })
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
        C.applyPlayerControls(e)
      else
        -- halt:
        C.stopMoving(e)
      end

      updateDir(e, estore)
      C.applyMotion(e, input)
      updateVisuals(e)

    elseif mode == "reveal" then
      local catgirl = findEntity(estore, hasName("catgirl"))
      revealPuppygirl(e,catgirl)
      e.states.mode.value = "revealing"

    elseif mode == "revealing" then
      if not (e.timers and e.timers.reveal_anim) then
        Debug.println("Done revealing")
        e.states.mode.value = "visible"
        C.assignAsPlayer(e, estore)
        C.viewportFollow(e, estore)
      end
    end

  end
)
