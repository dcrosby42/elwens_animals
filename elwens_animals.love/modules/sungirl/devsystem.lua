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

local function toggleBackgroundMusic(estore)
  local bg = findEntity(estore, allOf(hasName("background"), hasComps("sound")))
  if bg then
    if bg.sound.state == "playing" then
      bg.sound.state = "paused"
    else
      bg.sound.state = "playing"
    end
  end
end

local function toggleMouseDebug(estore)
  local mouseDebug = findEntity(estore, hasName("mouse_debug"))
  if mouseDebug then
    mouseDebug.states.on.value = not mouseDebug.states.on.value
    mouseDebug.label.text = ""
  end
end

local function updateMouseDebug(touch, estore)
  local mouseDebug = findEntity(estore, hasName("mouse_debug"))
  if mouseDebug and mouseDebug.states.on.value == true then
    local worldx, worldy = screenXYToViewport(Entities.getViewport(estore), touch.x, touch.y)
    local text = joinstrings({"screen: ", touch.x, ", ", touch.y, "\n", "world: ", math.round(worldx), ", ", math.round(worldy)})
    mouseDebug.pos.x, mouseDebug.pos.y = touch.x + 13, touch.y
    mouseDebug.label.text = text
  end
end

return function(estore, input, res)
  local viewportE = Entities.getViewport(estore)

  EventHelpers.handle(input.events, 'keyboard', {
    pressed = function(event)
      zoomViewport(viewportE, event, estore)

      -- if event.key == "space" then
      --   C.swapPlayers(estore)
      -- end

      if event.key == "b" then
        toggleBackgroundMusic(estore)
      end

      -- Toggle mouse debug coords
      if event.key == "m" then
        toggleMouseDebug(estore)
      end


    end,
  })

  EventHelpers.handle(input.events, 'touch', {
    moved = function(touch)
      updateMouseDebug(touch, estore)
    end,

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
