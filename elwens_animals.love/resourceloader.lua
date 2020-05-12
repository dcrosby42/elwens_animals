local inspect = require('inspect')
local SoundPool = require "soundpool"
local Debug = require('mydebug').sub("ResourceLoader", true, true)

local R = {}

local Images = {}
local ImageDatas = {}

R.getImageData = memoize1(love.image.newImageData)

R.getImage = memoize1(function(fname)
  return love.graphics.newImage(R.getImageData(fname))
end)

function R.getFont(fname, size)
  -- TODO
  return nil
end

R.getSoundData = memoize1(love.sound.newSoundData)

-- Returns a streaming Source
R.getMusicSource = memoize1(function(fname)
  return love.audio.newSource(fname, "stream")
end)

-- Args:
--   fname:(optional) filename. If omitted, img MUST be given.
--   img: (optional) image object.  If nil, R.getImage will be used w fname param to get it.
--   rect: (optional) {x=,y=,w=,h=} rectangle defining a Quad. If omitted, Quad will be the whole img dimensions.
--   opts: (optional) {sx, sy, duration, frameNum}
--
-- Returned 'pic' structure:
--   filename string
--   image Image
--   quad   Quad
--   rect   {x,y,w,h}
--   duration (default 1/60) (cheating a bit, this is for using Pic inside an Anim)
--   frameNum (default 1) (cheating a bit, this is for using Pic inside an Anim)
--   sx
--   sy
function R.makePic(fname, img, rect, opts)
  rect = rect or {}
  opts = opts or {}

  if fname and not img then img = R.getImage(fname) end
  if not fname and not img then
    error(
        "ResourceLoader.makePic() requires filename or image object, but both were nil")
  end

  local x, y, w, h
  if rect and rect.x then
    x = rect.x
    y = rect.y
    w = rect.w
    h = rect.h
  else
    x, y, w, h = unpack(rect)
  end
  if not x then
    x = 0
    y = 0
  end
  if w == nil then
    w = img:getWidth()
    h = img:getHeight()
  end

  local quad = love.graphics.newQuad(x, y, w, h, img:getDimensions())
  local pic = {
    filename = fname,
    rect = {x = x, y = y, w = w, h = h},
    image = img,
    quad = quad,
    duration = (opts.duration or 1 / 60),
    frameNum = (opts.frameNum or 1),
    sx = (opts.sx or 1),
    sy = (opts.sy or 1),
  }
  return pic
end

--
-- Anim
--

local Anim = {}

-- Assume the image at fname has left-to-right, top-to-bottom
-- uniform sprite frames of w-by-h.
-- opts: (optional) Passed to makePic(). {sx, sy, duration, frameNum}.  Though frameNum doesn't make much sense here.
function Anim.simpleSheetToPics(img, w, h, opts)
  opts = opts or {}
  if type(img) == "string" then
    Debug.println(img)
    img = R.getImage(img)
  end
  local imgw = img:getWidth()
  local imgh = img:getHeight()
  Debug.println("simpleSheetToPics() imgw=" .. imgw .. " imgh=" .. imgh)

  local pics = {}

  for j = 1, imgh / h do
    local y = (j - 1) * h
    for i = 1, imgw / w do
      local x = (i - 1) * w
      local pic = R.makePic(nil, img, {x = x, y = y, w = w, h = h}, opts)
      table.insert(pics, pic)
      Debug.println("Added pic.rect x=" .. x .. " y=" .. y .. " w=" .. w ..
                        " h=" .. h)
    end
  end
  return pics
end

function Anim.makeFrameLookup(anim, opts)
  opts = opts or {}
  return function(t)
    if not opts.extend then t = t % anim.duration end
    local acc = 0
    for i = 1, #anim.pics do
      acc = acc + anim.pics[i].duration
      if t < acc then return anim.pics[i] end
    end
  end
end

function Anim.recalcDuration(anim)
  local d = 0
  for i = 1, #anim.pics do d = d + anim.pics[i].duration end
  anim.duration = d
end

function Anim.makeSimpleAnim(pics, frameDur)
  frameDur = frameDur or 1 / 60
  local anim = {pics = {}, duration = (#pics * frameDur)}
  for i = 1, #pics do
    table.insert(anim.pics, shallowclone(pics[i]))
    -- stamp each frame w duration and frame#
    anim.pics[i].frameNum = i
    anim.pics[i].duration = frameDur
  end
  -- make a frame getter func for this anim
  anim.getFrame = Anim.makeFrameLookup(anim)

  return anim
end

function Anim.makeSinglePicAnim(pic, framwDur)
  frameDur = frameDur or 1
  pic = shallowclone(pic)
  pic.frameNum = 1
  pic.duration = frameDur
  local anim = {pics = {pic}, duration = pic.duration}
  -- make a frame getter func for this anim
  anim.getFrame = function(t)
    return pic
  end

  return anim
end

--
-- ResourceSet and ResourceRoot 
--
local ResourceSet = {}

function ResourceSet:new()
  local o = {}
  setmetatable(o, self)
  self.__index = self
  return o
end

function ResourceSet:put(name, obj)
  self[name] = obj
  return obj
end

function ResourceSet:get(name)
  return self[name]
end

local ResourceRoot = {}

function ResourceRoot:new()
  local o = {}
  setmetatable(o, self)
  self.__index = self
  return o
end

function ResourceRoot:get(name)
  local resSet = self[name]
  if resSet == nil then
    resSet = ResourceSet:new()
    self[name] = resSet
  end
  return resSet
end

function ResourceRoot:debugString()
  local s = "ResourceRoot\n"
  for setName, resSet in pairs(self) do
    s = s .. "\t" .. setName .. ":\n"
    for key, _ in pairs(resSet) do s = s .. "\t\t" .. key .. "\n" end
  end
  return s
end

--
-- Loaders
--

local Loaders = {}

-- Construct and add a new 'anim' resource from a picStrip.
-- res: ResourceRoot
-- name: anim name and key in root.anims[key]
-- pics: the array of pics loaded from a picStrip
-- data: {pics (list of ints = pic indexes), sx, sy (scale x and y, optional), frameDuration, frameDurations}
function Loaders.picStrip_anim(res, pics, name, data)
  local anim
  if data.pics then
    if #data.pics == 1 then
      -- simpler form of anim
      anim = Anim.makeSinglePicAnim(pics[data.pics[1]])
    else
      local myPics = map(data.pics, function(picIndex)
        return pics[picIndex]
      end)
      local duration = data.frameDuration
      if data.frameDurations and #data.frameDurations > 0 then
        -- Apply durations per frame, according to data.frameDurations.
        -- If data.frameDurations has fewer entries than anim.pics, that last duration is copied out to the end.
        anim = Anim.makeSimpleAnim(myPics)
        for i = 1, #anim.pics do
          anim.pics[i].duration = data.frameDurations[i] or
                                      anim.pics[i - 1].duration -- assumes there's at least 1 to fall back on
        end
        -- update overall anim duration
        Anim.recalcDuration(anim)
      else
        -- standard duration on all frames
        anim = Anim.makeSimpleAnim(myPics, data.frameDuration) -- dur may be nil here
      end
    end
    if data.sx then anim.sx = data.sx end
    if data.sy then anim.sy = data.sy end
    res:get('anims'):put(name, anim)
  end
end

function Loaders.picStrip(res, picStrip)
  local data = Loaders.getData(picStrip)
  local pics = Anim.simpleSheetToPics(R.getImage(data.path), data.picWidth,
                                      data.picHeight, data.picOptions)
  res:get('picStrips'):put(picStrip.name, pics)

  if data.pics then
    local rset = res:get('pics')
    for name, index in pairs(data.pics) do rset:put(name, pics[index]) end
  end
  if data.anims then
    for name, animData in pairs(data.anims) do
      Loaders.picStrip_anim(res, pics, name, animData)
    end
  end
end

-- soundConfig: {type,name, data:{file,type=[music|sound], duration(optional), volume=(optional)}}
function Loaders.sound(res, sound)
  local cfg = Loaders.getData(sound)
  if cfg.type == "music" then
    -- Music sounds are loaded as a streaming Source and reused
    cfg.pool = SoundPool.music({file = cfg.file})
  else
    -- Regular soundfx load and store SoundData for creating many Sources later on
    cfg.pool = SoundPool.soundEffect({data = R.getSoundData(cfg.file)})
  end
  cfg.duration = cfg.duration or cfg.pool:getSourceDuration()
  cfg.volume = cfg.volume or 1
  res:get('sounds'):put(sound.name, cfg)
end

local function loadDataFile(f)
  -- TODO: support json, yaml, other?
  return loadfile(f)()
end

function Loaders.getData(obj)
  if obj.data then
    return obj.data
  elseif obj.datafile then
    return loadDataFile(obj.datafile)
  else
    error(
        "Loader: cannot get data from object, need 'data' or 'datafile': obj=" ..
            inspect(obj))
  end
end

function Loaders.settings(res, settings)
  res:get('settings'):put(settings.name, Loaders.getData(settings))
end

function Loaders.loadConfig(res, config, loaders)
  loaders = loaders or Loaders
  local loader = loaders[config.type]
  assert(loader, "Loaders.loadConfig: no Loader found for type '" ..
             tostring(config and config.type) .. "': " .. inspect(config))
  loader(res, config)
  return res
end

function Loaders.copy()
  return shallowclone(Loaders)
end

function Loaders.loadConfigs(res, configs, loaders)
  for i = 1, #configs do Loaders.loadConfig(res, configs[i], loaders) end
  return res
end

function R.newResourceRoot(loaders)
  return ResourceRoot:new()
end

function R.buildResourceRoot(configs, loaders)
  return Loaders.loadConfigs(ResourceRoot:new(), configs, loaders)
end

R.Loaders = Loaders

R.Anim = Anim

return R
