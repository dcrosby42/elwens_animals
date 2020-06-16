local Debug = require("mydebug").sub("mario_entities")
local Comp = require "comps"
local Estore = require "ecs.estore"
local F = require "modules.plotter.funcs"
local Res = require "modules.mario.resources"
local inspect = require "inspect"
local sti = require "vendor/sti"
local Const = require "modules.mario.const"
local BlockW = Const.BlockW
local BlockW2 = Const.BlockW2
local BlockW4 = Const.BlockW4

local G = love.graphics

local DefaultZoom = 4

local Entities = {}

local stackup

function Entities.initialEntities(res)
  Debug.println("debug settings: " .. inspect(res.settings.mario.debug))

  local estore = Estore:new()

  local mapName = res.data.maps.firstMap
  local mapData = res.data:get(mapName)
  local map = Entities.map(estore, mapData, res)

  if res.settings.mario.debug.drawMarioMap then
    map:newComp("debugDraw", {on = true})
  end
  if res.settings.mario.debug.playBgMusic then
    map:newComp("sound", {sound = "bgmusic", loop = true})
  end
  local marioSpawn = lfindby(mapData.layers.objectgroup.Spawns.objects, 'type',
                             'mario')

  Entities.mario(map, res, marioSpawn)
  -- Entities.coin(map, res, 0, 160)
  -- Entities.platforms(res, map)
  Entities.locus(map, res)
  Entities.viewport(map, res)

  sti("modules/mario/maps/proto1.lua")
  return estore
end

function Entities.map(parent, mapData, res)
  local name = "The Map"
  if mapData and mapData.properties and mapData.properties.name then
    name = mapData.properties.name
  end
  local map = parent:newEntity({
    {"name", {name = name}},
    {"pos", {}},
    {"mariomap", {}},
    {"rect", {w = mapData.width, h = mapData.height}},
    {"physicsWorld", {gy = 9.8 * 64, allowSleep = false}},
  })

  -- custommap
  -- {
  --   layers={
  --     tilelayer={
  --       [name]={
  --         {
  --           name="Blocks",
  --           type="tilelayer",
  --           data={0,0,0,0,0...},
  --           grid={{0,0,0,0,0},{0,0,0,0,0}},
  --           ...
  --         }
  --       }
  --     },
  --     objectgroup={
  --       ?
  --     }
  --   },
  --   tiles={(exported tiled lua data from file)}
  -- }
  function inflateCells(grid)
    for r = 1, #grid do
      for c = 1, #grid[r] do
        if grid[r][c] ~= 0 then
          grid[r][c] = {code = grid[r][c], r = r, c = c}
        end
      end
    end
    return grid
  end

  local grid = mapData.layers.tilelayer.Blocks.grid
  inflateCells(grid)

  function attachObjects(grid, objects)
    for _, obj in ipairs(objects) do
      local c = (obj.x / BlockW) + 1
      local r = (obj.y / BlockW) + 1
      if grid[r][c] then
        if type(grid[r][c]) == 'table' then
          if not grid[r][c].objects then grid[r][c].objects = {} end
          table.insert(grid[r][c].objects, obj)
        else
          Debug.println(
              "grid[" .. r .. "][" .. c .. "] is not a table, it's " ..
                  tostring(
                      grid[r][c] .. ", so I cannot attach object to it: " ..
                          inspect(obj)))
        end
      end
    end
  end
  local objects = mapData.layers.objectgroup.Items.objects
  attachObjects(grid, objects)

  function generateBricks(res, grid, parent)
    for r = 1, #grid do
      for c = 1, #grid[r] do
        if grid[r][c] ~= 0 then Entities.brick(res, parent, grid[r][c]) end
      end
    end
  end
  generateBricks(res, grid, parent)

  local slabs = stackup(grid)
  function generateSlabs(res, grid, parent)
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

      Entities.slab(res, parent, orient, x, y, w, h)
    end
  end
  generateSlabs(res, grid, parent)

  return map

end

function Entities.locus(parent, res)
  -- a thing that follows mario
  local follW = 600
  local follH = 400
  parent:newEntity({
    {"name", {name = "locus"}},
    {"pos", {}},
    {
      "debugDraw",
      {
        on = res.settings.mario.debug.drawLocus,
        color = {0, 1, 1, 0.5},
        pos = true,
        rects = true,
        labels = true,
      },
    },
    {
      "rect",
      {
        debugonly = true,
        style = "line",
        color = {0, 0, 1},
        w = follW,
        h = follH,
        offx = follW / 2,
        offy = follH / 2,
      },
    },
    {
      "label",
      {
        debugonly = true,
        text = "LOCUS",
        color = {0, 0, 1},
        offx = follW / 2,
        offy = follH / 2,
      },
    },
    {"follower", {targetname = "ViewFocus"}},
  })

end

function Entities.rectangleVerts(w, h, cx, cy)
  cx = cx or 0.5
  cy = cy or 0.5
  local left = -(w * cx)
  local right = left + w
  local top = -(h * cy)
  local bottom = top + h
  return {left, top, right, top, right, bottom, left, bottom}
end

function Entities.mario(parent, res, marioSpawn)
  local picCx = 0.5
  local picCy = 0.55
  -- local startX = 200
  -- local startY = 130
  local startX = 87
  local startY = 210
  if marioSpawn then
    startX = marioSpawn.x + BlockW2
    startY = marioSpawn.y - BlockW + 1
  end

  local verts = Entities.rectangleVerts(10, 22, 0.5, 0.3865)
  return parent:newEntity({
    {"name", {name = "mario"}},
    {"mario", {}},
    {
      "blockbreaker",
      {
        fragstyle = res.settings.mario.debug.brickFragmentStyle,
        fraglife = res.settings.mario.debug.brickFragmentLife,
      },
    },
    {"controller", {id = "joystick1"}},
    {
      "anim",
      {
        name = "mario",
        id = "mario_big_stand_right",
        centerx = picCx,
        centery = picCy,
        drawbounds = false,
      },
    },
    {"timer", {name = "mario", countDown = false}},
    {
      "body",
      {
        fixedrotation = true,
        debugDraw = res.settings.mario.debug.drawMarioBody,
        mass = 0.1,
        friction = 0,
        debugDrawColor = {1, .5, .5},
      },
    },
    {"polygonShape", {vertices = verts}},
    {"force", {}},
    {"pos", {x = startX, y = startY}},
    {"vel", {}},
    {"followable", {targetname = "ViewFocus"}},
    {
      "debugDraw",
      {
        on = res.settings.mario.debug.drawMario,
        pos = true,
        bounds = false,
        color = {0.8, 1, 0.8, 0.5},
      },
    },
    {"var", {name = "points", value = 0}},
    {"var", {name = "coins", value = 0}},
    {"var", {name = "supermario", value = false}},
  })
end

local BlockDecoder = {
  [1] = {kind = "brick", anim = "brick_standard_shimmer"},
  [2] = {kind = "block", anim = "block_standard"},
  [3] = {kind = "qblock", anim = "qblock_standard"},
  [4] = {kind = "ground", anim = "ground_dirt_left"},
  [5] = {kind = "ground", anim = "ground_dirt"},
  [6] = {kind = "ground", anim = "ground_dirt_right"},
}

local BlockVerts
do
  local left = -BlockW2
  local right = left + BlockW
  local top = -BlockW2
  local bottom = top + BlockW
  BlockVerts = {left, top, right, top, right, bottom, left, bottom}
end

function Entities.brick(res, parent, cell)
  -- call {r,c,code,slab}

  local x = (cell.c) * BlockW - BlockW2
  local y = (cell.r) * BlockW - BlockW2
  local btype = BlockDecoder[cell.code]
  assert(btype, "Couldn't decode block code for cell. " .. inspect(cell))
  local contents = ""
  -- if btype.kind == 'qblock' then contents = "coin" end
  if cell.objects then
    for _, obj in ipairs(cell.objects) do
      if obj.type == 'coin' then
        contents = 'coin'
      elseif obj.type == 'mushroom' then
        contents = 'mushroom'
      elseif obj.type == 'oneup' then
        contents = 'oneup'
      end
    end
  end
  return parent:newEntity({
    {"block", {kind = btype.kind, contents = contents}},
    {
      "anim",
      {
        name = "atimer",
        id = btype.anim,
        sx = 1.06,
        sy = 1.06,
        centerx = 0.5,
        centery = 0.5,
        drawbounds = false,
      },
    },
    {"timer", {name = "atimer", countDown = false}},
    {"pos", {x = x, y = y}},
    {
      "body",
      {
        sensor = true,
        dynamic = false,
        fixedrotation = true,
        mass = 0.1,
        debugDraw = res.settings.mario.debug.drawBrickBody,
        debugDrawColor = {1, 1, .8},
      },
    },
    {"polygonShape", {vertices = BlockVerts}},
  })
end

function Entities.old_brick(parent, x, y)
  local kind = "brick"
  local contents = ""
  local animid = "brick_standard_shimmer"
  if x % 56 == 0 then
    kind = "qblock"
    animid = "qblock_standard"
    contents = "coin"
  end
  local w = 16
  local h = 16
  local left = -w / 2
  local right = left + w
  local top = -h / 2
  local bottom = top + h
  local verts = {left, top, right, top, right, bottom, left, bottom}
  return parent:newEntity({
    {"block", {kind = kind, contents = contents}},
    {
      "anim",
      {
        name = "atimer",
        id = animid,
        sx = 1.06,
        sy = 1.06,
        centerx = 0.5,
        centery = 0.5,
        drawbounds = false,
      },
    },
    {"timer", {name = "atimer", countDown = false}},
    {"pos", {x = x, y = y}},
    {
      "body",
      {
        sensor = true,
        dynamic = false,
        fixedrotation = true,
        mass = 0.1,
        debugDraw = res.settings.mario.debug.drawBrickBody,
        debugDrawColor = {1, 1, .8},
      },
    },
    {"polygonShape", {vertices = verts}},
  })
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

  return parent:newEntity({
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
        drawbounds = false,
      },
    },
    {"timer", {name = "shine", countDown = false}},
    {
      "body",
      {
        fixedrotation = false,
        mass = 0.1,
        debugDraw = res.settings.mario.debug.drawBrickBody,
        debugDrawColor = {1, .5, .5},
      },
    },
    {"polygonShape", {vertices = verts}},
    {"force", {}},
    {"pos", {x = startX, y = startY, r = 0.7}},
    {"vel", {}},
    {
      "debugDraw",
      {on = false, pos = true, bounds = false, color = {0.8, 1, 0.8, 0.5}},
    },
  })
end

function emptyGrid(w, c)
end

function Entities.slab(res, parent, orient, x, y, w, h)
  return parent:newEntity({
    {"slab", {orient = orient}},
    {
      "body",
      {
        debugDraw = res.settings.mario.debug.drawSlabBody,
        debugDrawColor = {1, 1, 1},
        dynamic = false,
        friction = 1,
      },
    },
    {"rectangleShape", {w = w, h = h}},
    {"pos", {x = x, y = y}},
  })
end

-- function Entities.platforms(res, parent)
--   local fname = "modules/mario/maps/testmap1.png"
--   local map = love.image.newImageData(fname)
--   local w, h = map:getDimensions()
--   Debug.println("Map " .. fname .. " w: " .. w .. " h: " .. h)
--   local detect = function(r, g, b)
--     if r == 1 and g == 1 and b == 1 then return 1 end
--     return 0
--   end
--   local grid = {}
--   for y = 0, h - 1 do
--     local row = y + 1
--     grid[y + 1] = {}
--     for x = 0, w - 1 do grid[y + 1][x + 1] = detect(map:getPixel(x, y)) end
--   end
--   for r = 1, #grid do
--     for c = 1, #grid[r] do
--       if grid[r][c] == 1 then
--         grid[r][c] = {r = r, c = c}
--         Entities.old_brick(parent, ((c) * 16) - (BlockW / 2),
--                            ((r) * 16) - (BlockW / 2))
--       end
--     end
--   end
--   local slabs = stackup(grid)
--   for i = 1, #slabs do
--     local w, h, orient
--     if slabs[i].w then
--       orient = "h"
--       w = slabs[i].w * BlockW
--       h = BlockW
--     else
--       orient = "v"
--       w = BlockW
--       h = slabs[i].h * BlockW
--     end
--     local x = (w / 2) + ((slabs[i].c - 1) * BlockW)
--     local y = (h / 2) + ((slabs[i].r - 1) * BlockW)

--     Entities.slab(res, parent, orient, x, y, w, h)
--   end
-- end

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
  for i = 1, #slabs do if not stolen[i] then table.insert(rects, slabs[i]) end end
  for i = 1, #stacks do table.insert(rects, stacks[i]) end

  return rects
end

function Entities.viewport(estore)
  -- Use the screen's current width and height as w/h for this viewport. TODO: improve?
  local w = G.getWidth()
  local h = G.getHeight()
  -- The viewport's rect offx and offy values are used by viewportdraw.
  -- Using w/2 and h/2 lets us copy x/y from our follow target and treat it like it's at the center of our focus.
  local offx = -w / 2
  local offy = -h / 2
  return estore:newEntity({
    {"name", {name = "viewport"}},
    {"viewport", {sx = DefaultZoom, sy = DefaultZoom}},
    {"pos", {}},
    {"rect", {draw = false, w = w, h = h, offx = offx, offy = offy}},
    {"follower", {targetname = "ViewFocus"}},
  })
end

function Entities.tracker(parent, res)
  parent:newEntity({
    {"name", {name = "tracker"}},
    {
      "viewportTarget",
      {
        offx = -love.graphics.getWidth() / 2,
        offy = -love.graphics.getHeight() / 2 - 000,
      },
    },
    {"pos", {x = 0, y = 0}},
    -- {'vel', {dx=0,dy=0}},
  })
end

function Entities.background(estore, res)
  return estore:newEntity({
    {"name", {name = "background"}},
    -- {'pic', {id='background1', sx=1, sy=1.05}}, -- zoo_keeper.png is 731px tall, we want to stretch it to 768
    {"pos", {}},
    -- {"sound", {sound = "bgmusic", loop = true, duration = res.sounds.bgmusic.duration}},
    {"physicsWorld", {gy = 9.8 * 64, allowSleep = false}},
  })
end

function Entities.coin(parent, res, x, y)
  local e = parent:newEntity({
    {
      "anim",
      {
        name = "atimer",
        id = "coin_spin",
        centerx = 0.5,
        centery = 0.5,
        drawbounds = false,
      },
    },
    {"timer", {name = "atimer", countDown = false}},
    {"pos", {x = x, y = y}},
    -- {
    --   "body",
    --   {
    --     sensor = true,
    --     dynamic = false,
    --     fixedrotation = true,
    --     mass = 0.1,
    --     debugDraw = res.settings.mario.debug.drawBrickBody,
    --     debugDrawColor = {1, 1, .8},
    --   },
    -- },
    -- {"polygonShape", {vertices = BlockVerts}},
  })
  tagEnt(e, 'coin')
  return e
end

function Entities.coin_from_block(estore, blockE, res)

  local parent = blockE:getParent()
  local x, y = getPos(blockE)
  y = y - BlockW
  local e = Entities.coin(estore, res, x, y)
  e:newComp('coinbumpanim', {orig = e.pos.y})
  e:newComp('sound', {sound = 'coin'})
end

return Entities
