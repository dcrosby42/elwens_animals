local R = require 'resourceloader'
local Anim = require 'anim'
local Debug = require('mydebug').sub("SunGirl.resources")

local Res = {}

local ImgPath = "data/images/"
local SungirlImgPath = "data/images/sungirl/"

local function makePic(opts)
  local path
  if opts.path then
    path = opts.path
  elseif opts.img then
    path = ImgPath .. opts.img .. ".png"
  elseif opts.sungirl_img then
    path = SungirlImgPath .. opts.sungirl_img .. ".png"
  else
    error("modules.sungirl.resources: mapPics requires a table with one of: path, img or sungirl_img")
  end
  return R.makePic(path)
end

local function addPic(res, name_or_opts)
  local opts
  local name
  if type(name_or_opts) == "string" then
    name = name_or_opts
    opts = {sungirl_img=name_or_opts}
  elseif type(name_or_opts) == "table" then
    opts = name_or_opts
    name = opts.name
    if not name then name = opts.sungirl_img end
    if not name then name = opts.img end
  end
  if not name then
    error("modules.sungirl.resources: addPic needs name or sungirl_img or img option")
  end
  local pic = makePic(opts)
  res.pics[name] = pic
  return pic
end

local function addSunGirlAnimations(resources)
  local rate = 1/8

  local runRight = lmap({
    "Sun_girl_animation-3",
    "Sun_girl_animation-4",
    "Sun_girl_animation-5",
    "Sun_girl_animation-6",
  }, function(name) return makePic({sungirl_img=name}) end)
  resources.anims["sungirl_run"] = Anim.makeSimpleAnim(runRight, rate)


  local standPics = {
    makePic({sungirl_img="Sun_girl_animation-2"}), -- eyes closed
    makePic({sungirl_img="Sun_girl_animation-1"}),
  }
  standPics[1].duration = 5
  standPics[2].duration = 0.2
  resources.anims["sungirl_stand"] = Anim.makeSimpleAnim(standPics)

  local sunnyPics = {
    makePic({sungirl_img="Sun_girl_animation-sad1"}), -- too bright
  }
  sunnyPics[1].duration = 5
  resources.anims["sungirl_stand_too_hot"] = Anim.makeSimpleAnim(sunnyPics)
end

local function addPicsAndAnims(resources)
  addPic(resources, "background01")

  addPic(resources, {name="umbrella", sungirl_img="Sungirl_items-1"})
  addPic(resources, {name="flower1", sungirl_img="Sungirl_items-2"})

  addPic(resources, {name="big_sun", sungirl_img="Sungirl_sun-1"})

  addPic(resources, {name="down_arrow", sungirl_img="downArrow_lineLight25"})

  addPic(resources, "shadow")

  addPic(resources, { name = "puppygirl-descend-left", sungirl_img = "Puppy_Girl-1" })
  addPic(resources, { name = "puppygirl-idle-left", sungirl_img = "Puppy_Girl-2" })
  addPic(resources, { name = "puppygirl-rise-right", sungirl_img = "Puppy_Girl-3" })
  addPic(resources, { name = "puppygirl-fly-left", sungirl_img = "Puppy_Girl-4" })

  addSunGirlAnimations(resources)

  addPic(resources, { img = "power-button-outline" })
  addPic(resources, { img = "skip-button-outline" })

  addPic(resources, { name = "house", sungirl_img = "House" })
end

local function addFonts(resources)
  resources.fonts.default = love.graphics.getFont(14)

  -- Some different sizes of the builtin font
  for _, size in ipairs({ 14, 24, 32 }) do
    local font = love.graphics.newFont(size)
    local name = "default_" .. tostring(size)
    resources.fonts[name] = font
  end

  -- Downloaded font
  local file = "data/fonts/goingtodogreatthings.ttf"
  local prefix = "greatthings"
  for _, size in ipairs({ 10, 30, 40, 75 }) do
    local font = love.graphics.newFont(file, size)
    local name = prefix .. "_" .. tostring(size)
    resources.fonts[name] = font
  end
end

local function addSounds(resources)
  resources.sounds["pickup_item"] = {
    file = "data/sounds/sungirl/pickup_item.wav",
    mode = "static",
    volume = 1.0,
  }

  resources.sounds["welcome-to-city"] = {
    file = "data/sounds/sungirl/welcome-to-city.mp3",
    mode = "stream",
    volume = 1.0,
  }

  -- Ensure all our sound configs have data and duration:
  for _, soundCfg in pairs(resources.sounds) do
    if not soundCfg.data then
      soundCfg.data = love.sound.newSoundData(soundCfg.file)
    end
    if not soundCfg.duration or soundCfg.duration == '' then
      soundCfg.duration = soundCfg.data:getDuration()
    end
  end
end

-- cached resources object, populated after Res.load()
local resources

function Res.load()
  if resources then return resources end

  resources = {
    pics={},
    anims={},
    sounds={},
    fonts={},
  }

  addPicsAndAnims(resources)
  addSounds(resources)
  addFonts(resources)

  return resources
end

return Res
