-- local EventHelpers = require 'eventhelpers'
local Debug = require('mydebug').sub("Sun")
local Entities = require("modules.sungirl.entities")
local C = require("modules.sungirl.common")
local Vec = require 'vector-light'

local CALM_SCALE = 0.3
local ANGRY_SCALE = 0.7
local MOOD_CONF = {
  {0, "calm"},
  {1, "angry"},
}
local ANGRY_DIST = {x=-350, y=-350}


return defineUpdateSystem(hasName('sun'),
  function(e, estore, input, res)

    local starting_mood = e.states.mood.value
    local catgirl = findEntity(estore, hasTag("catgirl"))
    local numItems = 0
    if catgirl.items then
      numItems = tcount(catgirl.items)
    end
    local new_mood
    for i,tup in ipairs(MOOD_CONF) do
      if numItems >= tup[1] then
        new_mood = tup[2]
      end
    end
    e.states.mood.value = new_mood

    if e.states.mood.value == "calm" then
      local vp = Entities.getViewport(estore)
      e.pos.x = (vp.viewport.x / vp.viewport.sx) + (e.pic.centerx * e.pic.sx * e.pic.srcWidth)
      e.pos.y = (vp.viewport.y / vp.viewport.sy) + (e.pic.centery * e.pic.sy * e.pic.srcHeight)
      e.pic.sx = CALM_SCALE
      e.pic.sy = CALM_SCALE
    elseif e.states.mood.value == "angry" then
      e.pic.sx, e.pic.sy = ANGRY_SCALE, ANGRY_SCALE
      e.pos.x = catgirl.pos.x + ANGRY_DIST.x
      e.pos.y = catgirl.pos.y + ANGRY_DIST.y
    end
  end
)
