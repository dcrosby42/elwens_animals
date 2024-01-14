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
  {thresh=0, mood="calm", scale=0.3, rel="viewport", dist={0,0}},
  {thresh=1, mood="calm", scale=0.35, rel="viewport", dist={20,20}},
  {thresh=3, mood="angry", scale=0.7, rel="catgirl", dist={-350,-350}},
}

-- local ANGRY_DIST = {x=-350, y=-350}


return defineUpdateSystem(hasName('sun'),
  function(e, estore, input, res)

    -- Count catgirl's items
    local catgirl = findEntity(estore, hasTag("catgirl"))
    local numItems = 0
    if catgirl.items then
      numItems = tcount(catgirl.items)
    end

    -- Recompute the sun's mood 
    local mood_conf
    for _,row in ipairs(MOOD_CONF) do
      if numItems >= row.thresh then
        mood_conf = row
      end
    end

    e.pic.sx, e.pic.sy = mood_conf.scale, mood_conf.scale

    -- Behave according to mood:
    -- if e.states.mood.value == "calm" then
    if mood_conf.rel == "catgirl" then
      -- Get big and follow catgirl very closely
      e.pos.x = catgirl.pos.x + mood_conf.dist[1]
      e.pos.y = catgirl.pos.y + mood_conf.dist[2]

    elseif mood_conf.rel == "viewport" then
      -- Float along with the viewport
      local vp = Entities.getViewport(estore)
      -- e.pos.x = (vp.viewport.x / vp.viewport.sx) + (e.pic.centerx * e.pic.sx * e.pic.srcWidth)
      -- e.pos.y = (vp.viewport.y / vp.viewport.sy) + (e.pic.centery * e.pic.sy * e.pic.srcHeight)
      e.pos.x = (vp.viewport.x / vp.viewport.sx)
      e.pos.y = (vp.viewport.y / vp.viewport.sy)
    end
  end
)
