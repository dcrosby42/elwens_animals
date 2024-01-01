local Debug = require 'mydebug'
local AnimalScreen = require 'modules/animalscreen'
local FishBowl = require 'modules/fishbowl'
local Christmas = require 'modules/christmas'
local Snowman = require 'modules/snowman'
local Plotter = require 'modules/plotter'
local Downhill = require 'modules/downhill'
local StackingGame = require 'modules/stackinggame'
local FarmGame = require 'modules/farmgame'
local SunGirl = require 'modules/sungirl'
local GC = require 'garbagecollect'

local M = {}

local handleSidefx

M.newWorld = function()
  Debug.setup()
  local w = {}
  w.modes={}
  w.modes["f1"] = function() return { module=StackingGame, state=StackingGame.newWorld() } end
  w.modes["f2"] = function() return { module=FishBowl, state=FishBowl.newWorld() } end
  w.modes["f3"] = function() return { module=Christmas, state=Christmas.newWorld() } end
  w.modes["f4"] = function() return { module=Snowman, state=Snowman.newWorld() } end
  w.modes["f5"] = function() return { module=Plotter, state=Plotter.newWorld() } end
  w.modes["f6"] = function() return { module=Downhill, state=Downhill.newWorld() } end
  w.modes["f7"] = function() return { module=FarmGame, state=FarmGame.newWorld() } end
  w.modes["f8"] = function() return { module=SunGirl, state=SunGirl.newWorld() } end
  -- w.modes["f7"] = function() return { module=AnimalScreen, state=AnimalScreen.newWorld() } end
  -- w.modes["f5"] = function() return { module=SnowScratch, state=SnowScratch.newWorld() } end
  -- w.cycle = {"f1","f2","f3","f4","f6","f7"}
  w.cycle = {"f1","f2","f3","f4","f6","f7","f8"}
  w.current = "f8"

  w.ios = love.system.getOS() == "iOS"
  if w.ios then
    w.showLog = false
  else
    w.showLog = false
  end

  return w
end

local function withCurrentMode(w,func)
  local mode = w.modes[w.current]
  if type(mode) == 'function' then
    -- Lazy-load of mode stuff, replace w result on first use:
    mode = mode()
    w.modes[w.current] = mode
  end
  if mode then func(mode) end
end

local function stopCurrentMode(w)
  withCurrentMode(w, function(mode) 
    if mode.module.stopWorld then
      mode.module.stopWorld(mode.state)
    end
  end)
end

M.updateWorld = function(w,action)
  if action.type == "keyboard" and action.state == "pressed" then
    -- Reload game?
    if action.key == 'r' and action.gui then
      stopCurrentMode(w)
      return w, {{type="crozeng.reloadRootModule"}}
    end

    -- Switch modes?
    local mode = w.modes[action.key]
    if mode then
      if w.current ~= action.key then
        stopCurrentMode(w)
        w.current = action.key
      end
    end
  end

  -- don't pass mouse events to sub module when on ios
  if w.ios and action.type == "mouse" then return w end

  -- Update current submodule
  withCurrentMode(w, function(mode) 
    mode.state, sidefx = mode.module.updateWorld(mode.state, action)
    handleSidefx(w,sidefx)
  end)

  if action.type == "tick" then
    GC.ifNeeded(action.dt)
  end
  return w
end

function handleSidefx(world,sidefx)
  if sidefx and #sidefx > 0 then
    for _,sf in ipairs(sidefx) do
      if sf.type == 'POWER' then
        print("Reset game.")
        stopCurrentMode(world)
        withCurrentMode(world, function(mode) 
          mode.state = mode.module.newWorld()
        end)
        -- Debug.println("Exit game.")
        -- love.event.quit()

      elseif sf.type == 'TOGGLE_DEBUG' then
				world.showLog = not world.showLog
				print("toggled")
      elseif sf.type == 'SKIP' then
        local nextI = 1
        for i=1,#world.cycle do
          if world.cycle[i] == world.current then
            nextI = i+1
            if nextI > #world.cycle then
              nextI = 1
            end
          end
        end
        stopCurrentMode(world)
        world.current = world.cycle[nextI]
        print("Next mode.")
      end
    end
  end
end

M.drawWorld = function(w)
  love.graphics.setBackgroundColor(0,0,0,0)

  withCurrentMode(w, function(mode) 
    mode.module.drawWorld(mode.state)
  end)

  if w.showLog then
    Debug.draw()
  end

end

return M
