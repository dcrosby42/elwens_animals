local Debug = require('mydebug').sub("DevSystem",true,true,true)
local Entities = require 'modules.sungirl.entities'
local EventHelpers = require 'eventhelpers'
local C = require('modules.sungirl.common')

local function zoomViewport(viewportE, event, estore)
  local zstep = 0.2
  local dzoom
  if event.key == "=" then
    dzoom = zstep
  elseif event.key == "-" then
    dzoom = -zstep
  end
  if dzoom then
    viewportE.viewport.sx = viewportE.viewport.sx + (dzoom or 0)
    viewportE.viewport.sy = viewportE.viewport.sy + (dzoom or 0)
  end
end

-- local function removePlayerTag(e)
--   if e.tags.player then
--     e:removeComp(e.tags.player)
--   end
-- end

-- local function addPlayerTag(e)
--   if not e.tags.player then
--     e:newComp('tag', {name='player'})
--   end
-- end

-- local function resetControls(e)
--   for _,attr in ipairs({'left','right','up','down','jump'}) do
--     e.player_control[attr] = false
--   end
-- end
-- local function swapOrder(e1,e2)
--   local o1 = e1.parent.order
--   local o2 = e2.parent.order
--   e1.parent.order = o2
--   e2.parent.order = o1
-- end

-- local function swapPlayers(event, estore)
--   if event.key == "space" then
--     local puppygirl = findEntity(estore, hasTag("puppygirl"))
--     local catgirl = findEntity(estore, hasTag("catgirl"))

--     resetControls(puppygirl)
--     resetControls(catgirl)

--     if puppygirl.tags.player then
--       removePlayerTag(puppygirl)
--       addPlayerTag(catgirl)
--       swapOrder(catgirl, puppygirl)
--       Debug.println('controlling catgirl')
--     elseif catgirl.tags.player then
--       removePlayerTag(catgirl)
--       addPlayerTag(puppygirl)
--       swapOrder(catgirl, puppygirl)
--       Debug.println('controlling puppygirl')
--     end

--     local parentE = estore:getEntity(catgirl.parent.parentEid)
--     parentE:resortChildren()
--   end
-- end

return function(estore, input, res)
  local viewportE = Entities.getViewport(estore)

  EventHelpers.handle(input.events, 'keyboard', {
    pressed = function(event)
      zoomViewport(viewportE, event, estore)

      if event.key == "space" then
        C.swapPlayers(estore)
      end
      -- movePlayer(event,estore,input,res)
    end,
  })

  EventHelpers.handle(input.events, 'touch', {
    -- scrolled = function(touchAction)
    --   -- 
    --   -- Scrolling view left/right:
    --   --
    --   local x = touchAction.x
    --   if x ~= 0 then
    --     local scrollStep = 10
    --     if touchAction.shift then scrollStep = 50 end
    --     viewportE.viewport.x = viewportE.viewport.x + (x * scrollStep)
    --   end
    -- end,

    -- pressed = function(touch)
    --   local x = touch.x + viewportE.viewport.x
    --   local y = touch.y + viewportE.viewport.y
    --   Debug.println("Click: "..touch.x..", "..touch.y.." -- "..x..", "..y)
    -- end
  })
end
