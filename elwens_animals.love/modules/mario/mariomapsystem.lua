local function sectorName(r, c)
  return "s-" .. c .. "-" .. r
end

local function getSectorRCs(sw, sh, x, y, rect)
  local left = x - rect.offx
  local top = y - rect.offy
  local right = left + rect.w
  local bottom = top + rect.h
  local sectors = {}
  for sx = math.floor(left / sw), math.floor(right / sw) do
    for sy = math.floor(top / sh), math.floor(bottom / sh) do
      table.insert(sectors, {sx, sy})
      -- {
      --   name = sectorName(r, c),
      --   c = c,
      --   r = r,
      --   x = (c - 1) * cw,
      --   y = (r - 1) * ch,
      --   w = cw,
      --   h = ch
      -- }
    end
  end
  return sectors
end

local SectorW = 320
local SectorH = 240

local system = defineUpdateSystem({"mariomap"},
                                  function(mapE, estore, input, res)
  local locusE = estore:getEntityByName("locus")
  if not locusE then return end

  -- decide what sectors should exist
  local x, y = getPos(locusE)
  local sectors = getSectorRCs(SectorW, SectorH, x, y, locusE.rect)
  mapE.mariomap.sectors = sectors

  -- local chunks = {}
  -- mapE:walkEntities(
  --   hasComp("chunk"),
  --   function(e)
  --     chunks[e.chunk.sectorname] = e
  --   end
  -- )

  -- for i = 1, #sectors do
  --   local s = sectors[i]
  --   sname = sectorName(s[1], s[2])
  -- end

  -- mapE:newChild(
  --   {
  --     {"name", {name = sname}},
  --     {"pos", {x = s.x, y = s.y}},
  --     {"debugDraw", {}},
  --     {"rect", {w = s.w, h = s.h, color = {0.5, 0.5, 0.5}}},
  --     {"label", {text = sname}}
  --   }
  -- )
end)

return {system = system, SectorW = SectorW, SectorH = SectorH}
