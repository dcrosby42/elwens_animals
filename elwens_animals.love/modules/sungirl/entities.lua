local Estore = require 'ecs.estore'
local Debug = require('mydebug').sub('sungirl.Entities', true, true, true)

local Entities = {}

function Entities.initialEntities(res)
  local estore = Estore:new()

  --
  -- Viewport area
  --
  local targ = Entities.viewportTarget(estore, res, "FollowMe")
  local viewportE = Entities.viewport(estore, res, targ.viewportTarget.name)

  Entities.background(viewportE, res, "background01")

  Entities.sketch_walker(viewportE, res)

  --
  -- UI overlay
  --
  -- local uiE = estore:newEntity({
  --   {"name", {name="ui"}}
  -- })

  return estore
end

function Entities.viewport(estore, res, targetName)
  local w, h = love.graphics.getDimensions()
  return estore:newEntity({
    { 'name',     { name = "viewport" } },
    { 'viewport', { x = 0, y = 0, sx = 1, sy = 1, w = w, h = h, targetName = targetName } },
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
  local w,h = love.graphics.getDimensions()
  local picRes = res.pics[picId]
  local vscale = h / picRes.rect.h
  return parent:newEntity({
    { 'name', { name = "background" } },
    { 'pic',  { id = picId, sx = vscale, sy = vscale } },
    { 'pos',  { x = 0, y = 0 } },
  })
end

function Entities.sketch_walker(estore, res)
  return estore:newEntity({
    { 'name',  { name = "sketchwalker" } },
    { 'pos',   { x = 100, y = 800 } },
    { 'anim',  { name = "walky", id = "sketch_walk_right", centerx = 0.5, centery = 0.5, drawbounds = false } },
    { 'timer', { name = "walky", countDown = false } },
  })
end

  -- local w,h = love.graphics.getDimensions()
  -- local bg = "background1"
  -- local bgRes = res.pics[bg]
  -- local wRatio = w / bgRes.rect.w
  -- local hRatio = h / bgRes.rect.h
  -- local biggerR = math.max(wRatio,hRatio)
  -- return estore:newEntity({
  --   { 'name',         { name = "zookeeper" } },
  --   { 'tag',          { name = "zookeeper" } },
  --   { 'pic',          { id = bg, sx = biggerR, sy = biggerR } }, 
  --   { 'pos',          {} },
  --   -- { 'sound',        { sound = 'bgmusic', loop = true, duration = res.sounds.bgmusic.duration } },
  --   { 'physicsWorld', { gy = 9.8 * 64, allowSleep = false } },
  -- })

return Entities
