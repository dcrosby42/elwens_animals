-- local EventHelpers = require 'eventhelpers'
local Debug = require('mydebug').sub("Sun")
local Entities = require("modules.sungirl.entities")
local C = require("modules.sungirl.common")
local Vec = require 'vector-light'

-- Mood-based sun scaling:
-- local CALM_SCALE = 0.3
-- local ANGRY_SCALE = 0.7

-- Table: {item_count, mood_state}
local MOOD_CONF = {
  -- {thresh=0, mood="passive", scale=0.3, rel="viewport", dist={0,0}},
  -- {thresh=50, mood="active", scale=0.35, rel="viewport", dist={20,20}},
  -- {thresh=100, mood="angry", scale=0.7, rel="catgirl", dist={-350,-350}},
  { perc = 0, mood = "passive" },
  { perc = 50, mood = "active" },
  { perc = 100, mood = "angry" },
}

-- local ANGRY_DIST = {x=-350, y=-350}

-- property fromVal toVal timeSpan curVal curTime
-- a = { "prop_anim", { prop = { 'pos', 'x' }, valStart = 5, valEnd = 15, timeSpan = 1, timer="pos_x", },
--   "timer", {}
--   "prop_anim", { prop = { 'pos', 'y' }, valStart = 23, valEnd = 400, timeSpan = 1, timer="pos_y", },
-- }

function manageMoodTimers(e)
  local timer
  if e.timers then
    local mood = e.states.mood.value
    local toRem = {}
    for _,tComp in pairs(e.timers) do
      if tComp.name == mood then
        timer = tComp
      else
        table.insert(toRem, tComp)
      end
    end
    -- remove other timers
    for _,tComp in ipairs(toRem) do
      e:removeComp(tComp)
    end
  end
  if not timer then
    e:newComp('timer', {name=e.states.mood.value, countDown=false})
  end
end


local function updateActiveSun(e, vp)
  local t = e.timer.t
  local s = 0.4 + math.sin(2 * t) * 0.05
  local offx = 50 + math.sin(t) * 50
  local offy = 50 + math.cos(t) * 50

  e.pic.sx, e.pic.sy = s, s
  e.pos.x = (vp.viewport.x / vp.viewport.sx) + offx
  e.pos.y = (vp.viewport.y / vp.viewport.sy) + offy
end

local function updateAngrySun(e, catgirl)
  local t = e.timer.t
  local s = 0.7 + math.sin(2 * t) * 0.05
  local offx = -350 - math.sin(t) * 50
  local offy = -350 - math.cos(t) * 50

  e.pic.sx, e.pic.sy = s, s
  e.pos.x = catgirl.pos.x + offx
  e.pos.y = catgirl.pos.y + offy

  catgirl.states.mode.value = "too_hot"
end

return defineUpdateSystem(hasName('sun'),
  function(e, estore, input, res)

    -- Count catgirl's items
    local catgirl = findEntity(estore, hasTag("catgirl"))
    local numItems = 0
    if catgirl.items then
      numItems = tcount(catgirl.items)
    end

    -- compute percentage of items collected 
    local totalItems = 3 -- FIXME hardcoded
    local perc = math.round((numItems / totalItems) * 100)

    -- Use item percentage to calc the sun's mood:
    local mood_conf
    for _,row in ipairs(MOOD_CONF) do
      if perc >= row.perc then
        mood_conf = row
      end
    end
    local mood = mood_conf.mood
    e.states.mood.value = mood

    manageMoodTimers(e)
    
    local vp = Entities.getViewport(estore)
    if mood == "passive" then
      e.pic.sx, e.pic.sy = 0.3, 0.3
      e.pos.x = (vp.viewport.x / vp.viewport.sx)
      e.pos.y = (vp.viewport.y / vp.viewport.sy)

    elseif mood =="active" then
      updateActiveSun(e,vp)

    elseif mood =="angry" then
      -- Get big and follow catgirl very closely
      updateAngrySun(e,catgirl)
    end

    -- e.pic.sx, e.pic.sy = mood_conf.scale, mood_conf.scale

    -- -- Behave according to mood:
    -- -- if e.states.mood.value == "calm" then
    -- if mood_conf.rel == "catgirl" then
    --   -- Get big and follow catgirl very closely
    --   e.pos.x = catgirl.pos.x + mood_conf.dist[1]
    --   e.pos.y = catgirl.pos.y + mood_conf.dist[2]

    -- elseif mood_conf.rel == "viewport" then
    --   -- Float along with the viewport
    --   local vp = Entities.getViewport(estore)
    --   e.pos.x = (vp.viewport.x / vp.viewport.sx)
    --   e.pos.y = (vp.viewport.y / vp.viewport.sy)
    -- end
  end
)
