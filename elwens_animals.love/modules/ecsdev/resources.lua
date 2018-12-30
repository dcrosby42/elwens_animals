local R = require 'resourceloader'
local AnimalRes = require 'modules.animalscreen.resources'
local Anim = require 'anim'

local Debug = require 'mydebug'
Debug = Debug.sub("EcsDev resources",true,true)

local Res = {}

local function loadPics()
  local pics = {}
  -- pics["woodsbg"] = R.makePic("data/images/woods.png")
  return pics
end

local function loadAnims()
  local anims = {}
  return anims
end

local function fetchSoundDatas(sounds)
  for name,cfg in pairs(sounds) do
    if not cfg.data then
      cfg.data = R.getSoundData(cfg.file)
    end
    if not cfg.duration or cfg.duration == '' then
      cfg.duration = cfg.data:getDuration()
    end
  end
end

local function loadSounds()
  local sounds = {}
  -- sounds["thud"] = {
  --   file="data/sounds/fx/thud.wav",
  --   mode="static",
  --   volume=1,
  -- }
  fetchSoundDatas(sounds)
  return sounds
end

local cached
function Res.load()
  if not cached then
    local r = {}

    r.pics = loadPics()
    tmerge(r.pics, AnimalRes.loadButtonPics())

    r.anims = loadAnims()
    r.sounds = loadSounds()

    cached = r
  end
  return cached
end

return Res
