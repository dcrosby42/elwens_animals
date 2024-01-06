local EventHelpers = require 'eventhelpers'
local Debug = require('mydebug').sub("TouchNavPlayerControl")
local Entities = require("modules.sungirl.entities")

local function setNavGoal(touch,e,estore)
  local x, y = screenXYToViewport(Entities.getViewport(estore), touch.x, touch.y)
  e.nav_goal.x = x
  e.nav_goal.y = y
end

return defineUpdateSystem(
  allOf(hasTag('player'), hasComps('touch_nav')),
  function(e, estore, input, res)
    EventHelpers.handle(input.events, 'touch', {
      pressed = function(touch)
        if not e.nav_goal then
          e:newComp('nav_goal', {})
        end
        setNavGoal(touch,e,estore)
        Debug.println("nav_goal started: "..e.nav_goal.x .. ", "..e.nav_goal.y)
      end,
      moved = function(touch)
        if e.nav_goal then
          setNavGoal(touch,e,estore)
          Debug.println("nav_goal moved: "..e.nav_goal.x .. ", "..e.nav_goal.y)
        end
      end,
      released = function(touch)
        if e.nav_goal then
          e:removeComp(e.nav_goal)
        end
        Debug.println("nav_goal removed")
      end,
    })
  end
)
