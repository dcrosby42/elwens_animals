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


return defineUpdateSystem(hasTag('puppygirl'),
  function(e, estore, input,res)
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

  end
)
