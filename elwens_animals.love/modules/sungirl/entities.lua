local Estore = require 'ecs.estore'
local Debug = require('mydebug').sub('sungirl.Entities', true, true, true)
local Comp = require 'ecs/component'
local C = require 'modules.sungirl.common'

Comp.define('player_control', { 'any',false,'right', false, 'left', false, 'up', false, 'down', false, 'jump', false, 'stickx',0,'sticky',0})
Comp.define('touch_nav', { })
Comp.define('nav_goal', { 'x', 0, 'y', 0 })
Comp.define("speed", { 'pps', 0 })
Comp.define('touch_dpad', {'x',0,'y',0,'inner_radius',10,'radius',50})
Comp.define('drag_nav', {})

local Entities = {}


function Entities.initialEntities(res)
  local estore = Estore:new()

  --
  -- Viewport area
  --

  -- Create the viewport (which acts like a container).
  local viewportE = Entities.viewport(estore, res, "ViewFollow")
  -- Viewport tracks to the position of a viewportTarget 
  -- (this viewportTarget will be configured to follow catgirl below)
  local viewportTargetE = Entities.viewportTarget(estore, res, "ViewFollow")

  Entities.background(viewportE, res, "background01")
  
  local sun = Entities.sun(viewportE, res)
  sun.parent.order = 0

  Entities.flower(viewportE, res)

  local puppygirl = Entities.puppygirl(viewportE, res)
  sun.parent.order = 10 

  local shadow = Entities.shadow(viewportE, res)
  local catgirl = Entities.catgirl(viewportE, res)
  catgirl.parent.order = 11 

  viewportTargetE:newComp('follow', { targetName = catgirl.name.name })
  -- viewportTargetE:newComp('follow', { targetName = puppygirl.name.name })

  -- C.swapPlayers(estore)


  -- Entities.sketch_walker(viewportE, res)

  -- Entities.sun(estore, res)

  --
  -- UI overlay
  --
  local ui = estore:newEntity({
    {"name", {name="ui"}}
  })
  Entities.buttons(ui, res)

  return estore
end


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


function Entities.catgirl(parent, res)
  local catgirl = parent:newEntity({
    { 'name',  { name = "catgirl" } },
    { 'tag',   { name = 'catgirl' } },
    { 'tag',   { name = 'player' } },
    { 'player_control', {} },
    { 'touch_nav',      {} },
    { 'state', { name = "dir", value="right" } },
    { 'timer', { name = "catgirl", countDown = false } },
    { 'pos',   { x = 100, y = 700 } },
    { 'speed',   { pps=600 } },
    { 'vel',   { } },
    { 'anim', {
      name = "catgirl",
      id = "sungirl_stand",
      centerx = 0.5,
      centery = 0.5,
      sx = 0.5,
      sy = 0.5,
      drawbounds = false,
    } },
  })

  return catgirl

end

function Entities.shadow(parent, res)
  local shadow = parent:newEntity({
    { 'name',  { name = "catgirl_shadow" } },
    { 'follow', { targetName = "catgirl", offx=0,offy=250 } },
    {'pos',{}},
    { 'pic', {
      id = 'shadow',
      centerx = 0.5,
      centery = 0.5,
      sx=1, sy=1,
      color={1,1,1,0.4}
    } },
  })
  return shadow
end

function Entities.puppygirl(parent, res)
  local catgirl = parent:newEntity({
    { 'name',           { name = "puppygirl" } },
    { 'tag',            { name = 'puppygirl' } },
    { 'player_control', {} },
    { 'touchable',      { radius = 70 } },
    { 'state',          { name = "dir", value = "right" } },
    { 'pos',            { x = 300, y = 700 } },
    { 'speed',          { pps = 800 } },
    { 'vel',            {} },
    { 'pic', {
      id = "Puppy_Girl-2",
      centerx = 0.5,
      centery = 0.5,
      sx = 1,
      sy = 1,
      drawbounds = false,
      color = { 1, 1, 1, 0.7 }
    } },
  })

  return catgirl

end

function Entities.flower(parent, res, picId)
  local scale = 0.5
  return parent:newEntity({
    { 'tag',   { name = 'flower' } },
    { 'pic',  { id = "flower1", sx = scale, sy = scale } },
    { 'pos',  { x = 2500, y = 775 } },
  })
end

function Entities.sun(parent, res, picId)
  local scale = 0.5
  return parent:newEntity({
    { 'name',  { name = "sun" } },
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

function Entities.buttons(parent, res)
  -- Entities.nextModeButton(parent, res)
  Entities.quitButton(parent, res)
  -- Entities.toggleDebugButton(parent, res)
end

function Entities.quitButton(estore, res)
  local w, h = love.graphics.getDimensions()
  return estore:newEntity({
    { 'name',   { name = "power_button" } },
    { 'pic',    { id = 'power-button-outline', sx = 0.25, sy = 0.25, centerx = 0.5, centery = 0.5, color = { 1, 1, 1, 0.25 } } },
    { 'pos',    { x = w - 44, y = 50 } },
    { 'button', { kind = 'hold', eventtype = 'POWER', holdtime = 0.3, radius = 40 } },
  })
end

-- function Entities.nextModeButton(estore, res)
--   local w, h = love.graphics.getDimensions()
--   return estore:newEntity({
--     { 'name',   { name = "skip_button" } },
--     { 'pic',    { id = 'skip-button-outline', sx = 0.25, sy = 0.25, centerx = 0.5, centery = 0.5, color = { 1, 1, 1, 0.25 } } },
--     { 'pos',    { x = w - 124, y = 50 } },
--     { 'button', { kind = 'hold', eventtype = 'SKIP', holdtime = 0.5, radius = 40 } },
--   })
-- end

-- function Entities.toggleDebugButton(estore, res)
--   local w, h = love.graphics.getDimensions()
--   return estore:newEntity({
--     { 'name',   { name = "toggle_debug_button" } },
--     -- {'pic', {id='skip-button-outline', sx=0.25,sy=0.25,centerx=0.5, centery=0.5, color={1,1,1,0.25}}},
--     { 'pos',    { x = w/2, y = 50 } },
--     { 'button', { kind = 'hold', eventtype = 'TOGGLE_DEBUG', holdtime = 0.5, radius = 40 } },
--   })
-- end

return Entities
