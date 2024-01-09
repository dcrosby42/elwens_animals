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
Comp.define('item', {'kind',''})

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
  sun.parent.order = 2

  Entities.flower(viewportE, 2500)
  Entities.flower(viewportE, 800)

  local puppygirl = Entities.puppygirl(viewportE, res)
  puppygirl.parent.order = 10 

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
    { 'sound',      { sound = 'welcome-to-city', loop = true, duration = res.sounds["welcome-to-city"].duration } },
  })
end


function Entities.catgirl(parent, res)
  -- anim: (620 x 1000)*0.5 -> 310,500
  -- bounds: 
  local bbox_w, bbox_h = 120,390
  local bbox_offx, bbox_offy = bbox_w/2, 140

  local catgirl = parent:newEntity({
    { 'name',           { name = "catgirl" } },
    { 'tag',            { name = 'catgirl' } },
    { 'tag',            { name = 'player' } },
    { 'player_control', {} },
    { 'touchable',      { radius = 70, offy=70 } },
    { 'speed',          { pps = 600 } },
    { 'pos',            { x = 100, y = 700 } },
    { 'vel',            {} },
    { 'state',          { name = "dir", value = "right" } },
    { 'bounds',         { offx = bbox_offx, offy = bbox_offy, w = bbox_w, h = bbox_h, drawbounds=false } },
    { 'anim', {
      name = "catgirl",
      id = "sungirl_stand", -- 620x1000
      centerx = 0.5,
      centery = 0.5,
      sx = 0.5,
      sy = 0.5,
      drawbounds = false,
    } },
    { 'timer', { name = "catgirl", countDown = false } },
    -- { 'circle', {
    --   radius = 70,
    --   fill = false,
    --   offy = 70,
    --   color = { 1, 1, 1, 0.5 }
    -- } },
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

function Entities.getCatgirl(estore)
  return findEntity(estore, hasName('catgirl'))
end

function Entities.puppygirl(parent, res)
  local catgirl = parent:newEntity({
    { 'name',           { name = "puppygirl" } },
    { 'tag',            { name = 'puppygirl' } },
    { 'player_control', {} },
    { 'touchable',      { radius = 70 } },
    { 'state',          { name = "dir", value = "left" } },
    { 'pos',            { x = 300, y = 700 } },
    { 'speed',          { pps = 800 } },
    { 'vel',            {} },
    { 'pic', {
      id = "puppygirl-idle-left",
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

function Entities.flower(parent,x,y)
  local scale = 0.5
  if not y then y = 775 end

  local bbox_w, bbox_h = 45,100
  local bbox_offx, bbox_offy = 0,0--bbox_w/2, bbox_h/2

  return parent:newEntity({
    { 'tag',    { name = 'flower' } },
    { 'tag',    { name = 'pickup' } },
    { 'item',   { kind = 'flower' } },
    { 'pic',    { id = "flower1", sx = scale, sy = scale, drawbounds = false } },
    { 'pos',    { x = x, y = y } },
    { 'bounds', { offx = bbox_offx, offy = bbox_offy, w = bbox_w, h = bbox_h, drawbounds = false } },
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
  Entities.nextModeButton(parent, res)
  Entities.powerButton(parent, res)
  Entities.toggleDebugButton(parent, res)
end

function Entities.powerButton(estore, res)
  local w, h = love.graphics.getDimensions()
  return estore:newEntity({
    { 'name',   { name = "power_button" } },
    { 'pic',    { id = 'power-button-outline', sx = 0.25, sy = 0.25, centerx = 0.5, centery = 0.5, color = { 1, 1, 1, 0.25 } } },
    { 'pos',    { x = w - 44, y = 50 } },
    { 'button', { kind = 'hold', eventtype = 'POWER', holdtime = 0.5, radius = 40 } },
  })
end

function Entities.nextModeButton(estore, res)
  local w, h = love.graphics.getDimensions()
  return estore:newEntity({
    { 'name',   { name = "skip_button" } },
    { 'pic',    { id = 'skip-button-outline', sx = 0.25, sy = 0.25, centerx = 0.5, centery = 0.5, color = { 1, 1, 1, 0.25 } } },
    { 'pos',    { x = w - 124, y = 50 } },
    { 'button', { kind = 'hold', eventtype = 'SKIP', holdtime = 0.5, radius = 40 } },
  })
end

function Entities.toggleDebugButton(estore, res)
  local w, h = love.graphics.getDimensions()
  return estore:newEntity({
    { 'name',   { name = "toggle_debug_button" } },
    {'pic', {id='down_arrow', sx=0.7,sy=0.7,centerx=0.5, centery=0.5, color={1,1,1,0.25}}},
    -- { 'pos',    { x = w/2, y = 50 } },
    { 'pos',    { x = w-35, y = h-35 } },
    { 'button', { kind = 'hold', eventtype = 'TOGGLE_DEBUG', holdtime = 0.4, radius = 40 } },
  })
end

return Entities
