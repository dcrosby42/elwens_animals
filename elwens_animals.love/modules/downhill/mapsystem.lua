local SliceWidth = 1000
local TerrainRes = 10 -- terrain func step, the smaller, the smoother
local F = require 'modules.plotter.funcs'
local N = require('modules.plotter.noise')
local noise = love.math.noise

-- sine wav
local function terrain_0(x)
  return math.sin(x/50)*50
end

-- A downhill sine wave
local function terrain_1(x)
  return x/2 + math.sin(x/50)*50
end

-- A downhill simplex noise wave
local mag = 500
local function terrain_2(x)
  return x/2 + noise(x/mag)*mag
end

local function terrain_3(x)
  -- octaveNoise(x,  iterations, persistence, frequency, low, high)
  return x/2 + N.octaveNoise(x/mag, 2, 0.3, 1.1, 0, 1) * mag
  -- return x/2 + N.octaveNoise(x/mag, 2, 0.3, 1.2, 0, 2) * mag
end

local function findViewport(estore)
  local viewport
  estore:seekEntity(hasComps('viewport'),function(e)
    viewport = e.viewport
    return true
  end)
  return viewport
end

local function createSlice(parent, n)
  local left = n * SliceWidth
  local right = left + SliceWidth
  local verts = F.genSeries(left, right, TerrainRes, terrain_3)
  parent:newEntity({
    {'name',{name="slice-"..n}},
    {'slice',{number=n}},
    {'body', {dynamic=false, debugDraw=false}},
		{'chainShape', {vertices=verts}},
    {'pos', {x=0,y=0}},
  })
end

local mapSystem = defineUpdateSystem({'map'},function(mapE,estore,input,res)
  -- Find the viewport
  local viewport = findViewport(estore)
  if not viewport then return end

  -- Determine which slices are in view
  local a = math.floor(viewport.x / SliceWidth) - 1
  local b = math.ceil((viewport.x + viewport.w) / SliceWidth) 

  -- Find existing slices that are out-of-view and need to retire
  local sawNumbers = {}
  local kills = {}
  mapE:walkEntities(hasComps('slice'),function(e)
    if e.slice.number < a or e.slice.number > b then
      -- this slice entity is out of range, slate it for retirement
      kills[#kills + 1] = e
    else
      -- track slices that we see in the entity list, that we're gonna keep
      sawNumbers[#sawNumbers + 1] = e.slice.number
    end
  end)
  -- Retire the gone slices
  for i=1,#kills do
    estore:destroyEntity(kills[i])
  end

  -- Build new slices that should exist but do not yet
  for i=a,b do
    if not lcontains(sawNumbers, i) then
      createSlice(mapE, i)
    end
  end


end)

return mapSystem
