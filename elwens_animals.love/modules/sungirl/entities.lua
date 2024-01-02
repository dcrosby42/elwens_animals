local Estore = require 'ecs.estore'
local Debug = require('mydebug').sub('sungirl.Entities', true, true, true)
local Comp = require 'ecs/component'

local Entities = {}

function Entities.initialEntities(res)
  local estore = Estore:new()

  --
  -- Viewport area
  --
  local targ = Entities.viewportTarget(estore, res, "FollowMe")
  local viewportE = Entities.viewport(estore, res, targ.viewportTarget.name)

  Entities.background(viewportE, res, "background01")
  
  Entities.flower(viewportE, res)
  Entities.sun(viewportE, res)

  local player = Entities.sungirl(viewportE, res)
  targ:newComp('follow', { targetName = player.name.name })
  -- Entities.sketch_walker(viewportE, res)


  --
  -- UI overlay
  --
  -- local uiE = estore:newEntity({
  --   {"name", {name="ui"}}
  -- })

  return estore
end

Comp.define('player_control', { 'right', false, 'left', false, 'jump', false })

function Entities.viewport(estore, res, targetName)
  local mapw = 10000
  local maph = 1000

  local w, h = love.graphics.getDimensions()
  local aspect = w / h

  local vh = maph
  local vw = vh * aspect

  local scale = h / vh

  return estore:newEntity({
    { 'name',     { name = "viewport" } },
    { 'viewport', { x = 0, y = 0, sx = scale, sy = scale , w = vw, h = vh, targetName = targetName } },
    { 'bounds', {offx=0,offy=0, w=mapw,h=maph}}
  })
end

function Entities.viewportTarget(parent, res, name)
  local w, h = love.graphics.getDimensions()
  local offx = -(w / 2)
  local offy = -(h / 2)
  name = name or "viewport_target"
  return parent:newEntity({
    { 'viewportTarget', { name = name, offx = offx, offy = offy } },
    { 'pos',            { x = 0, y = 0 } },
    { 'name',           { name = name } },
  })
end

-- Get "the" viewport entity in this world
function Entities.getViewport(estore)
  return findEntity(estore, hasComps('viewport'))
end

function Entities.background(parent, res, picId)
  local scale = 1
  return parent:newEntity({
    { 'name', { name = "background" } },
    { 'pic',  { id = picId, sx = scale, sy = scale } },
    { 'pos',  { x = 0, y = 0 } },
    { 'background', { color = { 0.75, 0.85, 1, 1 } } },
  })
end


function Entities.sungirl(estore, res)
  return estore:newEntity({
    { 'name',  { name = "sungirl" } },
    { 'tag',   { name = 'sungirl' } },
    { 'tag',   { name = 'player' } },
    { 'player_control', {} },
    { 'state', { name = "dir", value="right" } },
    -- { 'state', { name = "animation", value="stand" } },
    { 'anim', {
      name = "sungirl",
      id = "sungirl_stand",
      centerx = 0.5,
      centery = 0.5,
      sx = 0.5,
      sy = 0.5,
      drawbounds = false,
    } },
    { 'timer', { name = "sungirl", countDown = false } },
    { 'pos',   { x = 100, y = 700 } },
    { 'vel',   { } },
  })
end

function Entities.flower(parent, res, picId)
  local scale = 0.5
  return parent:newEntity({
    { 'pic',  { id = "flower1", sx = scale, sy = scale } },
    { 'pos',  { x = 2500, y = 775 } },
  })
end

function Entities.sun(parent, res, picId)
  local scale = 0.5
  return parent:newEntity({
    { 'pic',  { id = "big_sun", sx = scale, sy = scale } },
    { 'pos',  { x = 00, y = 00 } },
  })
end

function Entities.waypoint(parent, name,x,y)
  return parent:newEntity({
    { 'tag',   { name = 'waypoint' } },
    { 'name',  { name = name } },
    { 'pos',  { x = x, y = y } },
    { 'pic',  { id = "down_arrow", centerx = 0.5, centery = 0.5, drawbounds = false } },
  })
end

-- function Entities.sketch_walker(estore, res)
--   return estore:newEntity({
--     { 'name',  { name = "sketchwalker" } },
--     { 'pos',   { x = 100, y = 800 } },
--     { 'anim',  { name = "walky", id = "sketch_walk_right", centerx = 0.5, centery = 0.5, drawbounds = false } },
--     { 'timer', { name = "walky", countDown = false } },
--   })
-- end

return Entities
