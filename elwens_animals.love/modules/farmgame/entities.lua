local Comps = require 'comps'
local Estore = require 'ecs.estore'

local Entities = {}

function Entities.initialEntities(res)
  local estore = Estore:new()

  Entities.zooKeeper(estore, res)

  Entities.floor(estore, res)

  Entities.initial_food_boxes(estore, res)

  Entities.initial_animals(estore,res)

  Entities.buttons(estore, res)

  return estore
end

function Entities.zooKeeper(estore, res)
  return estore:newEntity({
    { 'tag',          { name = "zookeeper" } },
    { 'pic',          { id = 'background1', sx = 1, sy = 1.05 } }, -- zoo_keeper.png is 731px tall, we want to stretch it to 768
    { 'pos',          {} },
    { 'debug',        { name = 'nextAnimal', value = 1 } },
    { 'sound',        { sound = 'bgmusic', loop = true, duration = res.sounds.bgmusic.duration } },
    { 'physicsWorld', { gy = 9.8 * 64, allowSleep = false } },
  })
end

function Entities.animal(estore, res, kind)
  return estore:newEntity({
    { 'tag',            { name = "animal" } },
    { 'pic',            { id = kind, sx = 0.5, sy = 0.5, centerx = 0.5, centery = 0.5 } },
    { 'pos',            {} },
    { 'vel',            {} },
    { 'body',           { debugDraw = false } },
    { 'force',          {} },
    { 'rectangleShape', { x = 0, y = 0, w = 100, h = 100 } },
  })
end

function Entities.floor(estore, res)
  return estore:newEntity({
    { 'name',           { name = "floor" } },
    { 'tag',            { name = 'floor' } },
    { 'body',           { debugDraw = false, dynamic = false } },
    { 'rectangleShape', { w = 1024, h = 50 } },
    -- { 'pos',            { x = 512, y = 793 } },
    { 'pos',            { x = 512, y = 780 } },
  })
end

-- Clickable food selector icons in the upper left of the screen:
function Entities.initial_food_boxes(estore, res)
  w=75
  b=12
  x=(w/2)+b
  y=(w/2)+b
  Entities.food_box(estore, res, "apple_box", "apple_100", x,y)
  x = x + w + b
  Entities.food_box(estore, res, "banana_box", "bananas_100", x,y)
  x = x + w + b
  Entities.food_box(estore, res, "lettuce_box", "lettuce_100", x,y)
end

function Entities.initial_animals(estore, res)
  e = Entities.animal(estore, res, "hippo")
  -- e.body.debugDraw = true
  e.pos.x = 850
  e.pos.y = 700
  e = Entities.animal(estore, res, "cat")
  -- e.body.debugDraw = true
  e.pos.x = 950
  e.pos.y = 700
end

function Entities.food_box(estore, res, name, img_name, x, y)
  estore:newEntity({
    { 'name', { name = name } },
    { 'tag', { name = "food_box" } },
    { 'pic',  { id = img_name, sx = 0.4, sy = 0.4, centerx = 0.5, centery = 0.5, name="food"} },
    { 'pic',  { id = 'wood_box', sx = 0.5, sy = 0.5, centerx = 0.5, centery = 0.5, name="_box"} },
    { 'pos',  { x = x, y = y } },
  })
end

function Entities.food(estore, res, kind)
  return estore:newEntity({
    { 'tag',         { name = "food" } },
    { 'pic',         { id = kind, sx = 0.5, sy = 0.5, centerx = 0.5, centery = 0.5 } },
    { 'pos',         {} },
    { 'vel',         {} },
    { 'body',        { debugDraw = false } },
    { 'force',       {} },
    { 'circleShape', { radius = 18 } },
  })
end


function Entities.buttons(parent, res)
  Entities.nextModeButton(parent, res)
  Entities.quitButton(parent, res)
  Entities.toggleDebugButton(parent, res)
end

function Entities.quitButton(estore, res)
  return estore:newEntity({
    { 'name',   { name = "power_button" } },
    { 'pic',    { id = 'power-button-outline', sx = 0.25, sy = 0.25, centerx = 0.5, centery = 0.5, color = { 1, 1, 1, 0.25 } } },
    { 'pos',    { x = 980, y = 50 } },
    { 'button', { kind = 'hold', eventtype = 'POWER', holdtime = 0.5, radius = 40 } },
  })
end

function Entities.nextModeButton(estore, res)
  return estore:newEntity({
    { 'name',   { name = "skip_button" } },
    { 'pic',    { id = 'skip-button-outline', sx = 0.25, sy = 0.25, centerx = 0.5, centery = 0.5, color = { 1, 1, 1, 0.25 } } },
    { 'pos',    { x = 900, y = 50 } },
    { 'button', { kind = 'hold', eventtype = 'SKIP', holdtime = 0.5, radius = 40 } },
  })
end

function Entities.toggleDebugButton(estore, res)
  return estore:newEntity({
    { 'name',   { name = "toggle_debug_button" } },
    -- {'pic', {id='skip-button-outline', sx=0.25,sy=0.25,centerx=0.5, centery=0.5, color={1,1,1,0.25}}},
    { 'pos',    { x = 500, y = 50 } },
    { 'button', { kind = 'hold', eventtype = 'TOGGLE_DEBUG', holdtime = 0.5, radius = 40 } },
  })
end

function Entities.addSound(e, name, res)
  if not name then return end
  local cfg = res.sounds[name]
  if cfg then
    return e:newComp('sound', {
      sound = name,
      state = 'playing',
      duration = cfg.duration,
      volume = cfg.volume or 1,
    })
  else
    Debug.println("(No sound for " .. tostring(name) .. ")")
    return nil
  end
end

return Entities

-- SCRATCH: potential polygon shapes for animals:
    -- https://www.mathopenref.com/coordpolycalc.html
    -- {'circleShape', {radius=50}},
    -- {'polygonShape', {vertices={ 0,-50, -48,-15, -29,40, 29,40, 48,-15 }}}, -- pentagon r=50
    -- {'polygonShape', {vertices={
    --   19,-46,
    --   -19,-46,
    --   -46,-19,
    --   -46,19,
    --   -19,46,
    --   19,46,
    --   46,19,
    --   46,-19,
    -- }}}, -- octagon r=50
    -- {'polygonShape', {vertices={
    --   35,-35,
    --   -35,-35,
    --   -35,35,
    --   35,35,
    -- }}} -- square r=50