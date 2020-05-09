local Comp = require "comps"
local Estore = require "ecs.estore"
local F = require "modules.plotter.funcs"
local Res = require "modules.mario.resources"

local G = love.graphics

local DefaultZoom = 4

local Entities = {}

local mkBrick

function Entities.initialEntities(res)
  local estore = Estore:new()

  Entities.background(estore)
  Entities.mario(estore)
  Entities.locus(estore)
  Entities.platforms(estore)
  Entities.viewport(estore, res)

  -- Entities.kerblock(estore)

  -- mkBrick(estore, 0, 0)
  -- mkBrick(estore, 15, 0)
  -- mkBrick(estore, 30, 0)
  -- mkBrick(estore, 0, 15)
  -- local bg = Entities.background(vp,res)
  -- Entities.map(vp)
  -- Entities.tracker(vp)
  --

  -- local ui = Entities.ui(estore,res)
  -- AnimalEnts.buttons(ui,res)

  return estore
end

Comp.define("mariomap", {"sectors", {}})

function Entities.locus(parent, res)
  -- a thing that follows mario
  local follW = 600
  local follH = 400
  parent:newEntity(
    {
      {"name", {name = "locus"}},
      {"pos", {}},
      {"debugDraw", {on = false, color = {0, 1, 1, 0.5}, pos = true, rects = true, labels = true}},
      {
        "rect",
        {debugonly = true, style = "line", color = {0, 0, 1}, w = follW, h = follH, offx = follW / 2, offy = follH / 2}
      },
      {"label", {debugonly = true, text = "LOCUS", color = {0, 0, 1}, offx = follW / 2, offy = follH / 2}},
      {"follower", {targetname = "ViewFocus"}}
    }
  )

  -- MAP
  parent:newEntity(
    {
      {"name", {name = "mariomap"}},
      {"mariomap", {}}
      -- {"sound", {sound = "bgmusic", loop = true}}
    }
  )
end

function Entities.mario(parent, res)
  local w = 10
  local h = 22
  local left = -w / 2
  local right = left + w
  local bottom = 27 / 2
  local top = bottom - h
  local verts = {left, top, right, top, right, bottom, left, bottom}

  local picCx = 0.5
  local picCy = 0.55
  -- local startX = 200
  -- local startY = 130
  local startX = 30
  local startY = 50

  return parent:newEntity(
    {
      {"name", {name = "mario"}},
      {"mario", {mode = "standing", facing = "right"}},
      {"blockbreaker", {}},
      {"controller", {id = "joystick1"}},
      {"anim", {name = "mario", id = "mario_big_stand_right", centerx = picCx, centery = picCy, drawbounds = false}},
      {"timer", {name = "mario", countDown = false}},
      {"body", {fixedrotation = true, debugDraw = false, mass = 0.1, friction = 0, debugDrawColor = {1, .5, .5}}},
      {"polygonShape", {vertices = verts}},
      {"force", {}},
      {"pos", {x = startX, y = startY}},
      {"vel", {}},
      {"followable", {targetname = "ViewFocus"}},
      {"debugDraw", {on = false, pos = true, bounds = false, color = {0.8, 1, 0.8, 0.5}}}
    }
  )
end

function mkBrick(parent, x, y)
  local id = "brick_standard_shimmer"
  if x % 56 == 0 then
    id = "qblock_standard"
  end
  local w = 16
  local h = 16
  local left = -w / 2
  local right = left + w
  local top = -h / 2
  local bottom = top + h
  local verts = {left, top, right, top, right, bottom, left, bottom}
  return parent:newEntity(
    {
      {"tag", {name = "brick"}},
      {
        "anim",
        {
          name = "shine",
          id = id,
          sx = 1.06,
          sy = 1.06,
          centerx = 0.5,
          centery = 0.5,
          drawbounds = false
        }
      },
      {"timer", {name = "shine", countDown = false}},
      {"pos", {x = x, y = y}},
      {
        "body",
        {
          sensor = true,
          dynamic = false,
          fixedrotation = true,
          mass = 0.1,
          debugDraw = false,
          debugDrawColor = {1, 1, .8}
        }
      },
      {"polygonShape", {vertices = verts}},
      -- {"force", {}},
      {"vel", {}}
    }
  )
end

function Entities.kerblock(parent, res)
  local w = 14
  local h = 14
  local left = -w / 2
  local right = left + w
  local top = -h / 2
  local bottom = top + h
  local verts = {left, top, right, top, right, bottom, left, bottom}

  local picCx = 0.5
  local picCy = 0.5
  local startX = 50
  local startY = 0

  return parent:newEntity(
    {
      {"name", {name = "kerblock"}},
      {
        "anim",
        {
          name = "shine",
          id = "brick_standard_shimmer",
          sx = 1.06,
          sy = 1.06,
          centerx = picCx,
          centery = picCy,
          drawbounds = false
        }
      },
      {"timer", {name = "shine", countDown = false}},
      {"body", {fixedrotation = false, mass = 0.1, debugDraw = false, debugDrawColor = {1, .5, .5}}},
      {"polygonShape", {vertices = verts}},
      {"force", {}},
      {"pos", {x = startX, y = startY, r = 0.7}},
      {"vel", {}},
      {"debugDraw", {on = false, pos = true, bounds = false, color = {0.8, 1, 0.8, 0.5}}}
    }
  )
end

function newPoly(parent, verts)
  return parent:newEntity(
    {
      {"body", {debugDraw = true, dynamic = false, friction = 1}},
      -- {"rectangleShape", {w = BlockW, h = BlockW}},
      {"polygonShape", {vertices = verts}},
      -- {"pos", {x = ((opts.col - 1) * BlockW) + (BlockW / 2), y = ((opts.row - 1) * BlockW) + (BlockW / 2)}}
      {"pos", {x = 0, y = 0}}
    }
  )
end

function emptyGrid(w, c)
end

function Entities.slab(parent, orient, x, y, w, h)
  return parent:newEntity(
    {
      {"slab", {orient = orient}},
      {"body", {debugDraw = true, debugDrawColor = {1, 1, 1}, dynamic = false, friction = 1}},
      {"rectangleShape", {w = w, h = h}},
      {"pos", {x = x, y = y}}
    }
  )
end

local BlockW = 16

local stackup
function Entities.platforms(parent, res)
  local fname = "data/images/mario/testmap1.png"
  local map = love.image.newImageData(fname)
  local w, h = map:getDimensions()
  print("Map " .. fname .. " w: " .. w .. " h: " .. h)
  local detect = function(r, g, b)
    if r == 1 and g == 1 and b == 1 then
      return 1
    end
    return 0
  end
  local grid = {}
  for y = 0, h - 1 do
    local row = y + 1
    grid[y + 1] = {}
    for x = 0, w - 1 do
      grid[y + 1][x + 1] = detect(map:getPixel(x, y))
    end
  end
  for r = 1, #grid do
    for c = 1, #grid[r] do
      if grid[r][c] == 1 then
        grid[r][c] = {r = r, c = c}
        mkBrick(parent, ((c) * 16) - (BlockW / 2), ((r) * 16) - (BlockW / 2))
      end
    end
  end
  local slabs = stackup(grid)
  -- print("BlockW=" .. BlockW)
  -- print(inspect(#slabs) .. " slabs")
  -- print(inspect(slabs))
  for i = 1, #slabs do
    local w, h, orient
    if slabs[i].w then
      orient = "h"
      w = slabs[i].w * BlockW
      h = BlockW
    else
      orient = "v"
      w = BlockW
      h = slabs[i].h * BlockW
    end
    local x = (w / 2) + ((slabs[i].c - 1) * BlockW)
    local y = (h / 2) + ((slabs[i].r - 1) * BlockW)

    Entities.slab(parent, orient, x, y, w, h)
  end
end

function stackup(grid)
  local slabs = {}
  for r = 1, #grid do
    local row = grid[r]
    local slab = false
    for c = 1, #row do
      if slab then
        if row[c] == 0 then
          slab = false
        else
          row[c].slab = #slabs
          slab.w = slab.w + 1
        end
      else
        if row[c] ~= 0 then
          slab = {r = r, c = c, w = 1}
          table.insert(slabs, slab)
          row[c].slab = #slabs
        end
      end
    end
  end

  local stacks = {}
  local stolen = {}
  -- column-wise traversal
  for c = 1, #grid[1] do
    local stack = false
    for r = 1, #grid do
      local cell = grid[r][c]
      if cell ~= 0 then
        if stack then
          if cell.slab and slabs[cell.slab].w == 1 then
            -- extend the stack
            stack.h = stack.h + 1
            stolen[cell.slab] = true
          else
            -- end the stack
            stack = nil
          end
        else
          if cell.slab and slabs[cell.slab].w == 1 then
            -- start a new stack
            stack = {r = r, c = c, h = 1}
            stolen[cell.slab] = true
            table.insert(stacks, stack)
          end
        end
      end
    end
  end

  local rects = {}
  for i = 1, #slabs do
    if not stolen[i] then
      table.insert(rects, slabs[i])
    end
  end
  for i = 1, #stacks do
    table.insert(rects, stacks[i])
  end

  return rects
end

function Entities.viewport(estore)
  local w = G.getWidth()
  local h = G.getHeight()
  local offx = -w / 2
  local offy = -h / 2
  return estore:newEntity(
    {
      {"name", {name = "viewport"}},
      {"viewport", {sx = DefaultZoom, sy = DefaultZoom}},
      {"pos", {}},
      {"rect", {draw = false, w = w, h = h, offx = offx, offy = offy}},
      {"follower", {targetname = "ViewFocus"}}
    }
  )
end

function Entities.tracker(parent, res)
  parent:newEntity(
    {
      {"name", {name = "tracker"}},
      {"viewportTarget", {offx = -love.graphics.getWidth() / 2, offy = -love.graphics.getHeight() / 2 - 000}},
      {"pos", {x = 0, y = 0}}
      -- {'vel', {dx=0,dy=0}},
    }
  )
end

function Entities.background(estore, res)
  return estore:newEntity(
    {
      {"name", {name = "background"}},
      -- {'pic', {id='background1', sx=1, sy=1.05}}, -- zoo_keeper.png is 731px tall, we want to stretch it to 768
      {"pos", {}},
      -- {"sound", {sound = "bgmusic", loop = true, duration = res.sounds.bgmusic.duration}},
      {"physicsWorld", {gy = 9.8 * 64, allowSleep = false}}
    }
  )
end

function Entities.map(parent, res)
  parent:newEntity(
    {
      {"name", {name = "map"}},
      {"map", {slices = {}}}
    }
  )
end

-- function Entities.slice(parent,res,num)
--   parent:newEntity({
--     {'name',{name="slice-"..num}},
--     {'slice',{number=num}},
--   })
-- end

return Entities
